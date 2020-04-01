//
//  AUXSceneSelectDeviceListViewController.m
//  AUXSmartHome
//
//  Created by AUX on 2019/4/8.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXSceneSelectDeviceListViewController.h"
#import "AUXSceneSelectDeviceListTableViewCell.h"
#import "AUXDeviceInfo.h"
#import "AUXUser.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "AUXSceneResetSceneViewController.h"
#import "AUXSceneCommonModel.h"
#import "AUXCenterControlTableViewCell.h"
#import "AUXDeviceInfoAlertView.h"
#import "AUXNetworkManager.h"
#import "UIColor+AUXCustom.h"
#import "LMJScrollTextView.h"
#import "AUXDeviceStateInfo.h"


@interface AUXSceneSelectDeviceListViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UIButton *actionButton;
@property (weak, nonatomic) IBOutlet UITableView *deviceListTableview;
@property (nonatomic, strong) NSMutableArray<AUXDeviceInfo *> *deviceInfoArray;
@property (nonatomic, strong) NSMutableArray *deviceInfoArray1;
@property (nonatomic,strong) AUXSceneAddModel *sceneAddModel;
@property (nonatomic,strong)NSString *sceneName;
@property (nonatomic, strong) NSDictionary<NSString *, AUXACDevice *> *deviceDictionary;
@property (weak, nonatomic) IBOutlet UIView *detaliView;
@property (weak, nonatomic) IBOutlet UIButton *actionCenterButton;
@property (nonatomic,strong) LMJScrollTextView *scrollTextView;
@end

@implementation AUXSceneSelectDeviceListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.deviceListTableview registerNib:[UINib nibWithNibName:@"AUXSceneSelectDeviceListTableViewCell" bundle:nil] forCellReuseIdentifier:@"AUXSceneSelectDeviceListTableViewCell"];
    [self.deviceListTableview registerNib:[UINib nibWithNibName:@"AUXCenterControlTableViewCell" bundle:nil] forCellReuseIdentifier:@"AUXCenterControlTableViewCell"];
    self.deviceListTableview.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    self.deviceListTableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.view.backgroundColor = [UIColor colorWithHexString:@"F7F7F7"];
    self.deviceListTableview.backgroundColor = [UIColor colorWithHexString:@"F7F7F7"];
//    self.customBackAtcion = YES;
}

//- (void)backAtcion{
//    if (self.isFromScenehomepage) {
////        AUXSceneCommonModel *commonModel = [AUXSceneCommonModel shareAUXSceneCommonModel];
////        if (commonModel.deviceActionDtoList.count ==0) {
////            AUXSceneDeviceModel *model = [[AUXSceneDeviceModel alloc]init];
////            model.deviceName = @"空调";
////            model.onOff = 0;
////            AUXSceneCommonModel *commonModel = [AUXSceneCommonModel shareAUXSceneCommonModel];
////            commonModel.deviceActionDtoList = @[model].mutableCopy;
////        }
//    }
//    [self.navigationController popViewControllerAnimated:YES];
//}

- (NSMutableArray *)deviceInfoArray1 {
    if (!_deviceInfoArray1) {
        self.deviceInfoArray1 = [[NSMutableArray alloc]init];
    }
    return _deviceInfoArray1;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    [self.deviceInfoArray1 removeAllObjects];
    AUXSceneCommonModel *commonModel = [AUXSceneCommonModel shareAUXSceneCommonModel];
    self.sceneAddModel = commonModel;
    for (AUXDeviceInfo *info in self.deviceInfoArray) {
        if (info.suitType != AUXDeviceSuitTypeGateway) {
            [self.deviceInfoArray1 addObject:info];
        }
    }
    if (self.sceneAddModel != nil) {
        NSArray *temparray = self.sceneAddModel.deviceActionDtoList;
        for (AUXDeviceInfo *info in temparray) {
            NSString *deviceID = info.deviceId;
            for (AUXDeviceInfo *model in self.deviceInfoArray) {
                if ([model.deviceId isEqualToString:deviceID]) {
                    if ([self.deviceInfoArray1 containsObject:model]) {
                        [self.deviceInfoArray1 removeObject:model];
                    }
                }
            }
        }
    }
    [self.deviceListTableview reloadData];
    [self setheader];
}

- (void)setheader {
    if (self.sceneType == AUXSceneTypeOfManual ||self.sceneType == AUXSceneTypeOfCenterControl) {
        self.actionButton.hidden = YES;
        self.detaliView.hidden = YES;
        self.actionCenterButton.hidden = NO;
        [self.actionCenterButton setTitle:@" 执行条件：手动点击执行" forState:UIControlStateNormal];
        [self.actionCenterButton setImage:[UIImage imageNamed:@"scene_log_icon_hand"] forState:UIControlStateNormal];
        
    }else if (self.sceneType == AUXSceneTypeOfTime) {
        self.detaliView.hidden = YES;
        self.actionButton.hidden = YES;
        self.actionCenterButton.hidden = NO;
        
        if ([self.sceneAddModel.repeatRule isEqualToString:@"每天"]||[self.sceneAddModel.repeatRule isEqualToString:@"不重复"]||[self.sceneAddModel.repeatRule isEqualToString:@"双休日"]||[self.sceneAddModel.repeatRule isEqualToString:@"工作日"]) {
            [self.actionCenterButton setTitle:[NSString stringWithFormat:@" 执行条件：%@%@",self.sceneAddModel.repeatRule,self.sceneAddModel.actionTime] forState:UIControlStateNormal];

        }else{
            [self.actionCenterButton setTitle:[NSString stringWithFormat:@" 执行条件：每周%@%@",self.sceneAddModel.repeatRule,self.sceneAddModel.actionTime] forState:UIControlStateNormal];

        }
        
        [self.actionCenterButton setImage:[UIImage imageNamed:@"scene_log_icon_time"] forState:UIControlStateNormal];
    } else if (self.sceneType == AUXSceneTypeOfPlace){
        NSString *str = self.sceneAddModel.actionType==1?@"离开":@"进入";
        CGFloat widh = [self floatWithtext:[NSString stringWithFormat:@"%@ %@ %ld米",str,self.sceneAddModel.address,(long)self.sceneAddModel.distance] fontsize:16 needsize:CGSizeMake(MAXFLOAT, 30)];
        if (widh > kScreenWidth-120) {
            self.detaliView.hidden = NO;
            self.actionCenterButton.hidden = YES;
            self.actionButton.hidden = NO;
            [self.actionButton setImage:[UIImage imageNamed:@"scene_log_icon_palce"] forState:UIControlStateNormal];
            self.scrollTextView = [[LMJScrollTextView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth-120, 30) textScrollModel:LMJTextScrollContinuous direction:LMJTextScrollMoveLeft];
            self.scrollTextView.backgroundColor = [UIColor whiteColor];
            [self.detaliView addSubview:self.scrollTextView];
            [self.scrollTextView startScrollWithText:[NSString stringWithFormat:@"    %@%@ %ld米   %@%@ %ld米",str,self.sceneAddModel.address,(long)self.sceneAddModel.distance,str,self.sceneAddModel.address,(long)self.sceneAddModel.distance] textColor:[UIColor colorWithHexString:@"8E959D"] font:[UIFont systemFontOfSize:16]];
        }else{
            self.detaliView.hidden = YES;
            self.actionButton.hidden = YES;
            self.actionCenterButton.hidden = NO;
            [self.actionCenterButton setTitle:[NSString stringWithFormat:@" 执行条件： %@%@ %ld米",str,self.sceneAddModel.address,(long)self.sceneAddModel.distance] forState:UIControlStateNormal];
            [self.actionCenterButton setImage:[UIImage imageNamed:@"scene_log_icon_palce"] forState:UIControlStateNormal];
        }
    }
}

#pragma mark 获取数据
- (NSMutableArray<AUXDeviceInfo *> *)deviceInfoArray {
    _deviceInfoArray = [[AUXUser defaultUser].deviceInfoArray mutableCopy];
    return _deviceInfoArray;
}

#pragma mark  tableview 每个cell显示什么内容
- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    AUXDeviceInfo *deviceModel = self.deviceInfoArray1[indexPath.row];
    
    if (self.sceneType != AUXSceneTypeOfCenterControl) {
        AUXSceneSelectDeviceListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AUXSceneSelectDeviceListTableViewCell" forIndexPath:indexPath];
        cell.nameLabel.text = deviceModel.alias;
        
        AUXDeviceStateInfo *deviceStateinfo = [AUXDeviceStateInfo shareAUXDeviceStateInfo];
        BOOL iscontain = [deviceStateinfo.dataArray containsObject:deviceModel.deviceId];
        if (iscontain) {
            cell.lineStateLabel.text = @"";
            cell.lineStateImageview.hidden = YES;
        }else{
            cell.lineStateLabel.text = @"(离线)";
            cell.lineStateImageview.hidden = NO;
        }
        
        [cell.IconImageview sd_setImageWithURL: [NSURL URLWithString:deviceModel.deviceMainUri] placeholderImage:nil];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        if (indexPath.row == self.deviceInfoArray1.count-1) {
            cell.underLinView.hidden = YES;
        }else{
            cell.underLinView.hidden = NO;
            
        }
        
        return cell;
    }else{
        AUXCenterControlTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AUXCenterControlTableViewCell" forIndexPath:indexPath];
        cell.model = deviceModel;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
}

#pragma mark  tableview 每个分区显示多少cell
- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.deviceInfoArray1.count;
}

#pragma mark - 每个cell的高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 81;
}

#pragma mark  每个分区头的高度
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 12;
}

#pragma mark  cell的点击事件
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    AUXDeviceInfo *deviceModel = self.deviceInfoArray1[indexPath.row];
    
    if (self.sceneType == AUXSceneTypeOfCenterControl) {
        deviceModel.isSelected = !deviceModel.isSelected;
        [self.deviceListTableview reloadData];
        
    }else{
        AUXDeviceInfo *deviceModel = self.deviceInfoArray1[indexPath.row];
        if ((self.sceneType == AUXSceneTypeOfPlace)) {
            if (deviceModel.userTag == AUXDeviceShareTypeMaster) {
                [self pushViewControllerwithmodel:deviceModel];
                return;
            }else{
                [self showToastshortWithmessageinCenter:@"他人分享的设备不能用于位置场景"];
                return;
            }
        }else{
            [self pushViewControllerwithmodel:deviceModel];
            return;
        }
    }
}


- (void)pushViewControllerwithmodel:(AUXDeviceInfo*)deviceModel {
    AUXSceneDeviceModel *model = [[AUXSceneDeviceModel alloc]init];
    model.deviceName = deviceModel.alias;
    model.deviceId = deviceModel.deviceId;
    model.dst = deviceModel.suitType;
    model.productKey = deviceModel.productKey;
    model.imageUrl = deviceModel.deviceMainUri;
    AUXSceneCommonModel *commonModel = [AUXSceneCommonModel shareAUXSceneCommonModel];
    NSMutableArray *tempArray = [[NSMutableArray alloc]initWithArray: commonModel.deviceActionDtoList];
    [tempArray addObject:model];
    commonModel.deviceActionDtoList = tempArray;
    AUXSceneResetSceneViewController *sceneResetSceneViewController = [AUXSceneResetSceneViewController instantiateFromStoryboard:kAUXStoryboardNameScene];
    sceneResetSceneViewController.sceneType = self.sceneType;
    sceneResetSceneViewController.titleStr = model.deviceName;
    sceneResetSceneViewController.isNewAdd = self.isNewAdd;
    sceneResetSceneViewController.sceneName = self.sceneName1;
    sceneResetSceneViewController.delectLastobject = YES;
    [self.navigationController pushViewController:sceneResetSceneViewController animated:YES];
}


#pragma mark getter
- (NSDictionary<NSString *, AUXACDevice *> *)deviceDictionary {
    return [AUXUser defaultUser].deviceDictionary;
}

@end






