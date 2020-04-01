//
//  AUXSceneCenterControlSelectViewController.m
//  AUXSmartHome
//
//  Created by AUX on 2019/4/18.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXSceneCenterControlSelectViewController.h"
#import "AUXCenterControlTableViewCell.h"
#import "AUXUser.h"
#import "AUXSceneDetailModel.h"
#import "AUXSceneCommonModel.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "AUXNetworkManager.h"
#import "AUXDeviceInfoAlertView.h"
#import "AUXDeviceControlViewController.h"
#import "UIColor+AUXCustom.h"
#import "AUXAlertCustomView.h"
#import "AUXCommonAlertView.h"
#import "AUXSceneExecuteDeviceViewController.h"
#import "AUXDeviceStateInfo.h"



@interface AUXSceneCenterControlSelectViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property (nonatomic, strong) NSMutableArray<AUXDeviceInfo *> *deviceInfoArray;
@property (nonatomic, strong) NSMutableArray<AUXDeviceInfo *> *dataArray;
@property (nonatomic, strong) NSDictionary<NSString *, AUXACDevice *> *deviceDictionary;
@property (weak, nonatomic) IBOutlet UIButton *allselectButton;
@property (nonatomic, copy) NSString* sceneName;
@property (nonatomic, copy) NSString* sceneid;

@property (weak, nonatomic) IBOutlet UIImageView *selectImageview;
@property (nonatomic, strong) NSMutableArray *originaldataArray;

@end

@implementation AUXSceneCenterControlSelectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableview registerNib:[UINib nibWithNibName:@"AUXCenterControlTableViewCell" bundle:nil] forCellReuseIdentifier:@"AUXCenterControlTableViewCell"];
    self.tableview.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    self.tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.view.backgroundColor = [UIColor colorWithHexString:@"F7F7F7"];
    self.tableview.backgroundColor = [UIColor colorWithHexString:@"F7F7F7"];
}


#pragma mark 获取数据
- (NSMutableArray<AUXDeviceInfo *> *)deviceInfoArray {
    _deviceInfoArray = [[AUXUser defaultUser].deviceInfoArray mutableCopy];
    return _deviceInfoArray;
}

- (NSMutableArray<AUXDeviceInfo *> *)dataArray {
    if (!_dataArray) {
        self.dataArray = [[NSMutableArray alloc]init];
    }
    return _dataArray;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    
    [self.dataArray removeAllObjects];
    AUXSceneCommonModel *commonModel = [AUXSceneCommonModel shareAUXSceneCommonModel];
    NSMutableArray *tmpArray = commonModel.deviceActionDtoList.mutableCopy;
    self.originaldataArray = tmpArray;
    
    for (AUXSceneDeviceModel *model in tmpArray) {
        for (AUXDeviceInfo *info in self.deviceInfoArray) {
            if ([info.deviceId isEqualToString:model.deviceId]) {
                info.isSelected = YES;
            }
        }
    }
    
    for (AUXDeviceInfo *info in self.deviceInfoArray) {
        if (info.suitType !=1) {
            
            if (commonModel.deviceActionDtoList.count==0) {
                info.isSelected = NO;
            }
            [self.dataArray addObject:info];
        }
    }
    
    if (tmpArray.count == self.dataArray.count) {
        [self allSelectButtonAction:self.allselectButton];
    }
    [self.tableview reloadData];
}

#pragma mark  tableview 每个cell显示什么内容
- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    AUXDeviceInfo *info = self.dataArray[indexPath.row];
    AUXCenterControlTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AUXCenterControlTableViewCell" forIndexPath:indexPath];
    
    AUXDeviceStateInfo *deviceStateinfo = [AUXDeviceStateInfo shareAUXDeviceStateInfo];
    BOOL iscontain = [deviceStateinfo.dataArray containsObject:info.deviceId];
    if (iscontain) {
        cell.lineStateLabel.text = @"";
        cell.outOnlineImagView.hidden = YES;
    }else{
        cell.lineStateLabel.text = @"(离线)";
        cell.outOnlineImagView.hidden = NO;
    }
    cell.model = info;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (indexPath.row==self.dataArray.count-1) {
        cell.underLineView.hidden = YES;
    }else{
        cell.underLineView.hidden = NO;
    }
    return cell;
}

#pragma mark  tableview 每个分区显示多少cell
- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

#pragma mark - 每个cell的高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

#pragma mark  每个分区头的高度
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 12;
}
#pragma mark  cell的点击事件
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    AUXDeviceInfo *info = self.dataArray[indexPath.row];
    info.isSelected = !info.isSelected;
    [self isAllselect];
    [self.tableview reloadData];
}

- (void)isAllselect{
    BOOL isAllselect = NO;
    for (AUXDeviceInfo *deviceModel in self.dataArray) {
        if (deviceModel.isSelected == 0) {
            isAllselect = NO;
            break;
        }else{
            isAllselect = YES;
        }
    }
    if (isAllselect) {
        self.selectImageview.image = [UIImage imageNamed:@"common_btn_selected"];
        self.allselectButton.selected = YES;
    }else{
        self.selectImageview.image = [UIImage imageNamed:@"common_btn_unselected"];
        self.allselectButton.selected = NO;
    }
}

#pragma mark  确定按钮的点击事件
- (IBAction)ensureButtonAction:(id)sender {
    NSMutableArray *tempArray = [[NSMutableArray alloc]init];
    NSMutableArray *tempArray1 = [[NSMutableArray alloc]init];
    
    for (AUXDeviceInfo *deviceModel in self.dataArray) {
        if (deviceModel.isSelected==1) {
            [tempArray addObject:deviceModel.deviceId];
            [tempArray1 addObject:deviceModel];
        }
    }
    AUXSceneCommonModel *commonModel = [AUXSceneCommonModel shareAUXSceneCommonModel];
    commonModel.deviceActionDtoList = tempArray1.mutableCopy;
    if (self.isCreatCentrol) {
        if (tempArray.count==0) {
            [self showToastshortWithmessageinCenter:@"请选择有效设备"];
            return;
        }
        
        
        
        if (self.sceneName.length == 0) {
            if (self.isfromHomepage) {
                @weakify(self);
                [AUXCommonAlertView alertViewWithnameType:AUXNamingTypeSceneName nameLabelText:@"场景名称" detailLabelText:@"多设备快捷控制" confirm:^(NSString *name) {
                    @strongify(self);
                    self.sceneName = name;
                    NSDictionary *dict = @{@"deviceList":tempArray,
                                           @"homePageFlag":@false,
                                           @"sceneName":self.sceneName,
                                           };
                    [self saveCenterControlDic:dict];
                } close:^{
                    NSLog(@"点击了取消按钮");
                }];
            }else{
                @weakify(self);
                [AUXCommonAlertView alertViewWithnameType:AUXNamingTypeSceneName nameLabelText:@"场景名称" detailLabelText:self.sceneName confirm:^(NSString *name) {
                    @strongify(self);
                    self.sceneName = name;
                    NSDictionary *dict = @{@"deviceList":tempArray,
                                           @"homePageFlag":@false,
                                           @"sceneName":self.sceneName,
                                           };
                    NSLog(@"点击了确认按钮%@",self.sceneName);
                    [self saveCenterControlDic:dict];
                } close:^{
                    NSLog(@"点击了取消按钮");
                }];
            }
        }else{
            NSDictionary *dict = @{@"deviceList":tempArray,
                                   @"homePageFlag":@false,
                                   @"sceneName":self.sceneName,
                                   };
            [self saveCenterControlDic:dict];
        }
        
    }else{
        
        if (tempArray.count==0) {
             [self showToastshortWithmessageinCenter:@"请选择有效设备"];
            return;
        }
        
        
        self.sceneName = commonModel.sceneName;
        NSDictionary *dict = @{@"deviceList":tempArray,
                               @"homePageFlag":@false,
                               @"sceneName":self.sceneName,
                               };
        
        if (self.tmpDict!=nil) {
            self.sceneName = self.tmpDict[@"data"][@"sceneName"];
        }else{
            self.sceneName = commonModel.sceneName;
        }
        
        if (self.tmpDict!=nil) {
             self.sceneid = self.tmpDict[@"data"][@"sceneId"];
        }else{
            self.sceneid = commonModel.sceneId;
        }
        
        [self reSetCenterControlSceneid:self.sceneid Dic:dict];
    }
}


#pragma mark  创建集中控制
-(void)saveCenterControlDic:(NSDictionary*)dic{
    AUXSceneCommonModel *commonModel = [AUXSceneCommonModel shareAUXSceneCommonModel];
    commonModel.sceneName = self.sceneName;
    [self showLoadingHUD];
    [[AUXNetworkManager manager] saveSceneCenterontrolWithDic:dic compltion:^(BOOL result, NSError * _Nonnull error, NSDictionary * _Nonnull dict) {
          [self hideLoadingHUD];
                if (error == nil) {
                    [self pushToDeviceControlVCWithDict:dict];
                }else{
                    [self showToastshortWitherror:error];
                }
    }];
    
}



- (void)pushToDeviceControlVCWithDict:(NSDictionary*)dic {
    AUXSceneCommonModel *commonModel = [AUXSceneCommonModel shareAUXSceneCommonModel];
    NSMutableArray *tmpArry = [[NSMutableArray alloc]init];
    for (AUXSceneDeviceModel *model in commonModel.deviceActionDtoList) {
        for (AUXDeviceInfo *info in self.deviceInfoArray) {
            if ([model.deviceId isEqualToString:info.deviceId]) {
                [tmpArry addObject:info];
            }
        }
    }
    AUXDeviceControlViewController *deviceControllerViewController = [AUXDeviceControlViewController instantiateFromStoryboard:kAUXStoryboardNameDeviceControl];
    deviceControllerViewController.isfromHomepage = self.isfromHomepage;
    deviceControllerViewController.controlType = AUXDeviceControlTypeSceneMultiDevice;
    deviceControllerViewController.deviceInfoArray = tmpArry;
    deviceControllerViewController.isNewAdd = self.isNewAdd;
    deviceControllerViewController.tmpDict = dic;
    [self.navigationController pushViewController:deviceControllerViewController animated:YES];
}


- (void)reSetCenterControlSceneid:(NSString*)sceneid Dic:(NSDictionary*)dic {
    [[AUXNetworkManager manager] reSetSceneCenterontrolWithSceneId:sceneid Dic:dic compltion:^(BOOL result, NSError * _Nonnull error) {
        if (error == nil) {
            for (AUXDeviceInfo *deviceModel in self.dataArray) {
                if (deviceModel.isSelected==1) {
                    deviceModel.isSelected =0;
                }
            }
            [self showToastshortWithmessageinCenter:@"修改成功"];
            
            if (self.isEdicenterol) {
                AUXSceneExecuteDeviceViewController *sceneExecuteDeviceViewController = nil;
                for (AUXBaseViewController *tempVc in self.navigationController.viewControllers) {
                    if ([tempVc isKindOfClass:[AUXSceneExecuteDeviceViewController class]]) {
                        sceneExecuteDeviceViewController = (AUXSceneExecuteDeviceViewController*)tempVc;
                        [self.navigationController popToViewController:sceneExecuteDeviceViewController animated:YES];
                    }
                }
            }else{
                [self.navigationController popToRootViewControllerAnimated:YES];
            }
            
        }else{
            [self showToastshortWitherror:error];
        }
    }];
}

- (IBAction)allSelectButtonAction:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (sender.selected) {
        for (AUXDeviceInfo *deviceModel in self.dataArray) {
            deviceModel.isSelected =1;
        }
        [self.tableview reloadData];
        self.selectImageview.image = [UIImage imageNamed:@"common_btn_selected"];
    }else{
        for (AUXDeviceInfo *deviceModel in self.dataArray) {
            deviceModel.isSelected =0;
        }
        [self.tableview reloadData];
        self.selectImageview.image = [UIImage imageNamed:@"common_btn_unselected_round"];
    }
}

#pragma mark getter
- (NSDictionary<NSString *, AUXACDevice *> *)deviceDictionary {
    return [AUXUser defaultUser].deviceDictionary;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 12)];
    view.backgroundColor = [UIColor colorWithHexString:@"F7F7F7"];
    return view;
}

@end



