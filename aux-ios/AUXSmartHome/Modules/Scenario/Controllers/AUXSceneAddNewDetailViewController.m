//
//  AUXSceneAddNewDetailViewController.m
//  AUXSmartHome
//
//  Created by AUX on 2019/4/8.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXSceneAddNewDetailViewController.h"
#import "AUXSceneAddNewDetailTableViewCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "AUXSceneAddDeviceTableViewCell.h"
#import "AUXSceneSelectDeviceListViewController.h"
#import "AUXDeviceInfo.h"
#import "AUXUser.h"
#import "AUXNetworkManager.h"
#import "AUXSceneAddHeaderTableViewCell.h"
#import "AUXTimeQuantumTableViewCell.h"
#import "UIColor+AUXCustom.h"
#import "AUXSceneTimeQuantumViewController.h"
#import "AUXSceneMapViewController.h"
#import "AUXSceneCommonModel.h"
#import "AUXSceneAddByTimeViewController.h"
#import "AUXNetworkManager.h"
#import "AUXSceneDetailModel.h"
#import "AUXSceneSetCenterControlViewController.h"
#import "AUXSceneResetSceneViewController.h"
#import "AUXAlertCustomView.h"
#import "LMJScrollTextView.h"
#import "AUXCommonAlertView.h"
#import "AUXScenePlaceQueue.h"
#import "AUXAlertCustomView.h"
#import "AUXSceneAddLocationViewController.h"


@interface AUXSceneAddNewDetailViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveItem;
@property (weak, nonatomic) IBOutlet UITableView *listTableview;
@property (nonatomic, strong) NSMutableArray<AUXDeviceInfo *> *deviceInfoArray;
@property (nonatomic, strong) NSMutableArray *deviceInfoArray1;
@property (nonatomic,assign) BOOL isExistE;
@property (nonatomic,strong)NSString *imageNameStr;
@property (nonatomic,strong)NSString *firstStr;
@property (nonatomic,strong)NSString *seccondStr;
@property (nonatomic,strong)NSString *effectiveTime;
@property (nonatomic,strong) AUXSceneAddModel *sceneAddModel;
@property (nonatomic,strong) AUXSceneDetailModel *sceneDetailModel;
@property (nonatomic,strong)NSString *Bartitle;
@property (nonatomic,strong) LMJScrollTextView *scrollTextView;
@property (nonatomic,strong)NSString *addNewDevice;
@end

@implementation AUXSceneAddNewDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.listTableview registerNib:[UINib nibWithNibName:@"AUXSceneAddNewDetailTableViewCell" bundle:nil] forCellReuseIdentifier:@"AUXSceneAddNewDetailTableViewCell"];
    [self.listTableview registerNib:[UINib nibWithNibName:@"AUXSceneAddDeviceTableViewCell" bundle:nil] forCellReuseIdentifier:@"AUXSceneAddDeviceTableViewCell"];
    [self.listTableview registerNib:[UINib nibWithNibName:@"AUXSceneAddHeaderTableViewCell" bundle:nil] forCellReuseIdentifier:@"AUXSceneAddHeaderTableViewCell"];
    [self.listTableview registerNib:[UINib nibWithNibName:@"AUXTimeQuantumTableViewCell" bundle:nil] forCellReuseIdentifier:@"AUXTimeQuantumTableViewCell"];
    self.view.backgroundColor = [UIColor colorWithHexString:@"F7F7F7"];
    self.listTableview.backgroundColor = [UIColor colorWithHexString:@"F7F7F7"];
    self.listTableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.customBackAtcion = YES;
}

-(NSMutableArray *)deviceInfoArray1{
    if (!_deviceInfoArray1) {
        self.deviceInfoArray1 = [[NSMutableArray alloc]init];
    }
    
    return _deviceInfoArray1;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    self.customBackAtcion = YES;
    AUXSceneCommonModel *commonModel = [AUXSceneCommonModel shareAUXSceneCommonModel];
    self.sceneAddModel = commonModel;
    if (commonModel.deviceActionDtoList.count!=1) {
        NSMutableArray *array = commonModel.deviceActionDtoList.mutableCopy;
        for (AUXSceneDeviceModel *model in commonModel.deviceActionDtoList) {
            if (model.deviceId.length ==0 ) {
                if ([array containsObject:model]) {
                    [array removeObject:model];
                }
            }
        }
        self.sceneAddModel.deviceActionDtoList = array.mutableCopy;
    }
    if ([self.titleStr isEqualToString:@"新增场景"] ||[self.titleStr isEqualToString:@"推荐场景"]) {
        self.saveItem.title = @"确定";
        self.saveItem.image =  [[UIImage imageNamed:@"nil"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        self.title = self.titleStr;
    }else{
        NSString * isSceneEdit = [MyDefaults objectForKey:kIsSceneEdit];
        if ([isSceneEdit isEqualToString:@"1"]) {
            self.saveItem.title = @"保存";
            self.saveItem.image =  [[UIImage imageNamed:@"nil"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        }else{
            self.saveItem.image =  [[UIImage imageNamed:@"device_nav_btn_info"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
            self.saveItem.title = @"";
        }
        self.title = commonModel.sceneName;
    }
    
    if (self.sceneType == AUXSceneTypeOfManual) {
        self.imageNameStr = @"scene_icon_hand";
    }else if (self.sceneType == AUXSceneTypeOfTime) {
        self.firstStr = [NSString stringWithFormat:@"定时：%@",self.sceneAddModel.actionTime];
        self.seccondStr = [self resetStr:self.sceneAddModel.repeatRule];
        self.imageNameStr = @"scene_icon_time";
    }else if (self.sceneType == AUXSceneTypeOfPlace){
        self.firstStr = self.sceneAddModel.actionType==1?@"离开":@"到达";
        self.seccondStr =[NSString stringWithFormat:@"%@",self.sceneAddModel.address];
        self.imageNameStr = @"scene_icon_place";
    }else{
    }
    [self.listTableview reloadData];
}


#pragma mark  tableview 每个分区显示多少cell
- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (self.sceneType == AUXSceneTypeOfPlace) {
        if (section==0) {
            return 1;
        }else if(section==2){
            return self.sceneAddModel.deviceActionDtoList.count+1;
        }else if(section==1){
            return 1;
        }
    }else{
        if (section==0) {
            return 1;
        }else if(section==1){
            return self.sceneAddModel.deviceActionDtoList.count+1;
        }else if(section==2){
            return 1;
        }
    }
    return 0;
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        AUXSceneAddHeaderTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AUXSceneAddHeaderTableViewCell" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.iconImageView.image = [UIImage imageNamed:self.imageNameStr];
        if (self.sceneType == AUXSceneTypeOfManual) {
            cell.thirdLabel.text = @"手动点击执行";
            cell.firstLabel.hidden = YES;
            cell.seccondLabel.hidden = YES;
            cell.thirdLabel.hidden = NO;
            cell.backImageview.hidden = YES;
        }else{
             cell.backImageview.hidden = NO;
            cell.firstLabel.text = self.firstStr;
            if (self.sceneType == AUXSceneTypeOfPlace) {
                NSString *str = self.sceneAddModel.actionType==1?@"离开":@"进入";
                cell.seccondLabel.font = [UIFont systemFontOfSize:16];
                self.scrollTextView.hidden = NO;
                cell.seccondLabel.hidden = YES;
                if (self.scrollTextView) {
                    [self.scrollTextView removeFromSuperview];
                }
                self.scrollTextView = [[LMJScrollTextView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth-101, 20) textScrollModel:LMJTextScrollContinuous direction:LMJTextScrollMoveLeft];
                self.scrollTextView.backgroundColor = [UIColor whiteColor];
                [self.scrollTextView startScrollWithText:[NSString stringWithFormat:@"%@%@%ld米  ",str,self.seccondStr,(long)self.sceneAddModel.distance] textColor:[UIColor colorWithHexString:@"333333"] font:[UIFont systemFontOfSize:16]];
                [cell.seccondLabel addSubview:self.scrollTextView];
            }else{
                
                if ([self.seccondStr isEqualToString:@"不重复"]||[self.seccondStr isEqualToString:@"每天"]||[self.seccondStr isEqualToString:@"双休日"]||[self.seccondStr isEqualToString:@"工作日"]) {
                    cell.seccondLabel.text = self.seccondStr;
                }else if (self.seccondStr.length==0){
                    cell.seccondLabel.text = @"不重复";
                }else{
                    cell.seccondLabel.text = [NSString stringWithFormat:@"每周%@",self.seccondStr];
                }
            }
            cell.firstLabel.hidden = NO;
            cell.seccondLabel.hidden = NO;
            cell.thirdLabel.hidden = YES;
        }
        return cell;
    }else if (indexPath.section ==1){
        if (self.sceneType == AUXSceneTypeOfPlace) {
            AUXTimeQuantumTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AUXTimeQuantumTableViewCell" forIndexPath:indexPath];
            if (([self.sceneAddModel.repeatRule isEqualToString:@"每天"] && [self.sceneAddModel.effectiveTime isEqualToString:@"00:00-24:00"])||(self.sceneAddModel.repeatRule.length==0 && self.sceneAddModel.effectiveTime.length==0)||([self.sceneAddModel.repeatRule isEqualToString:@"1,2,3,4,5,6,7"] && [self.sceneAddModel.effectiveTime isEqualToString:@"00:00-24:00"])) {
                cell.timeLabel.text = @"始终";
                cell.timeLabel.hidden = NO;
                cell.timeBackView.hidden = YES;
            }else {
                cell.timeLabel.hidden = YES;
                cell.timeBackView.hidden = NO;
                cell.shiduanLabel.text = self.sceneAddModel.effectiveTime;
                NSString *str = [self resetStr:self.sceneAddModel.repeatRule];
                if ([str isEqualToString:@"一,二,三,四,五,六,日"]||[str isEqualToString:@"每天"]) {
                    cell.dateLabel.text = @"每天";
                }else if ([str isEqualToString:@"一,二,三,四,五"]||[str isEqualToString:@"工作日"]) {
                    cell.dateLabel.text = @"工作日";
                }else if ([str isEqualToString:@"六,日"]||[str isEqualToString:@"双休日"]) {
                    cell.dateLabel.text = @"双休日";
                }else if ([str isEqualToString:@"不重复"]||str.length==0) {
                    cell.dateLabel.text = @"不重复";
                }else{
                    cell.dateLabel.text = [NSString stringWithFormat:@"每周%@ ",str];
                }
            }
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }else{
            
            
            if (indexPath.row > self.sceneAddModel.deviceActionDtoList.count-1 || self.sceneAddModel.deviceActionDtoList.count==0) {
                AUXSceneAddDeviceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AUXSceneAddDeviceTableViewCell" forIndexPath:indexPath];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                return cell;
            }else{
                AUXSceneDeviceModel *model = self.sceneAddModel.deviceActionDtoList[indexPath.row];
                AUXSceneAddNewDetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AUXSceneAddNewDetailTableViewCell" forIndexPath:indexPath];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.nameLabel.text = model.deviceName;
                NSString *str = @"";
                if ([model.mode isEqualToString:@"0"]) {
                    str  = @"自动";
                }else if([model.mode isEqualToString:@"1"]){
                    str  = @"制冷";
                }else if([model.mode isEqualToString:@"2"]){
                    str  = @"除湿";
                }else if([model.mode isEqualToString:@"4"]){
                    str  = @"制热";
                }else if([model.mode isEqualToString:@"6"]){
                    str  = @"送风";
                }
                NSString *onoff = model.onOff == 1?@"开机":@"关机";
                NSString *temperature = model.temperature.length==0?@"":[NSString stringWithFormat:@"%@°C",model.temperature];
                if (model.onOff) {
                    NSString*tmp = [NSString stringWithFormat:@"%@，%@%@",onoff,str,temperature];
                    if ([tmp hasSuffix:@"，"]) {
                        tmp = [tmp substringToIndex:tmp.length-1];
                    }
                    cell.stateLabel.text = tmp;
                }else{
                    cell.stateLabel.text = @"关机";
                }
                [cell.iconImageView sd_setImageWithURL:[NSURL URLWithString:model.imageUrl] placeholderImage:[UIImage imageNamed:@"scene_icon_device_initial"]];
                
                if ([model.deviceName isEqualToString:@"空调"] && model.onOff == 0 && model.imageUrl.length==0) {
                    cell.selectLabel.hidden = NO;
                }else{
                    cell.selectLabel.hidden = YES;
                }
                
                if (indexPath.row==self.sceneAddModel.deviceActionDtoList.count-1) {
                    cell.ViewLabelLeading.constant=0;
                }else{
                     cell.ViewLabelLeading.constant=80;
                }
                
                return cell;
            }
        }
    }else{
        if (indexPath.row > self.sceneAddModel.deviceActionDtoList.count-1 ||self.sceneAddModel.deviceActionDtoList.count==0) {
            AUXSceneAddDeviceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AUXSceneAddDeviceTableViewCell" forIndexPath:indexPath];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }else{
            AUXSceneDeviceModel *model = self.sceneAddModel.deviceActionDtoList[indexPath.row];
            AUXSceneAddNewDetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AUXSceneAddNewDetailTableViewCell" forIndexPath:indexPath];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.nameLabel.text = model.deviceName;
            NSString *str = @"";
            if ([model.mode isEqualToString:@"0"]) {
                str  = @"自动";
            }else if([model.mode isEqualToString:@"1"]){
                str  = @"制冷";
            }else if([model.mode isEqualToString:@"2"]){
                str  = @"除湿";
            }else if([model.mode isEqualToString:@"4"]){
                str  = @"制热";
            }else if([model.mode isEqualToString:@"6"]){
                str  = @"送风";
            }
            NSString *onoff = model.onOff == 1?@"开机":@"关机";
            NSString *temperature = model.temperature.length==0?@"":[NSString stringWithFormat:@"%@°C",model.temperature];
            if (model.onOff) {
                NSString*tmp = [NSString stringWithFormat:@"%@，%@%@",onoff,str,temperature];
                if ([tmp hasSuffix:@"，"]) {
                    tmp = [tmp substringToIndex:tmp.length-1];
                }
                cell.stateLabel.text = tmp;
            }else{
                cell.stateLabel.text = @"关机";
            }
            [cell.iconImageView sd_setImageWithURL:[NSURL URLWithString:model.imageUrl] placeholderImage:[UIImage imageNamed:@"scene_icon_device_initial"]];
            
            if ([model.deviceName isEqualToString:@"空调"] && model.onOff == 0 && model.imageUrl.length==0) {
                cell.selectLabel.hidden = NO;
            }else{
                cell.selectLabel.hidden = YES;
            }
            if (indexPath.row==self.sceneAddModel.deviceActionDtoList.count-1) {
                cell.ViewLabelLeading.constant=0;
            }else{
                cell.ViewLabelLeading.constant=80;
            }
            return cell;
        }
    }
}

#pragma mark - 每个cell的高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section ==0) {
        
        if (self.sceneType == AUXSceneTypeOfManual) {
             return 80;
        }else{
          return 96;
        }
    }else if (indexPath.section == 1){
        
        if (self.sceneType == AUXSceneTypeOfPlace) {
            return 60;
        }else{
            if (indexPath.row > self.sceneAddModel.deviceActionDtoList.count-1 ||self.sceneAddModel.deviceActionDtoList.count==0) {
                return 58;
            }else{
                return 80;
            }
        }
    }else{
        if (indexPath.row > self.sceneAddModel.deviceActionDtoList.count-1||self.sceneAddModel.deviceActionDtoList.count==0) {
            return 58;
        }else{
            return 80;
        }
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.sceneType == AUXSceneTypeOfPlace) {
        return 3;
    }
    return 2;
}

#pragma mark  cell的点击事件
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section==0) {
        if (self.sceneType == AUXSceneTypeOfPlace) {
            
            
            AUXSceneAddLocationViewController *sceneAddLocationViewController = [AUXSceneAddLocationViewController instantiateFromStoryboard:kAUXStoryboardNameScene];
            sceneAddLocationViewController.sceneType = AUXSceneTypeOfPlace;
            sceneAddLocationViewController.isNewAdd =self.isNewAdd;
            sceneAddLocationViewController.markType = @"changeplace";
            sceneAddLocationViewController.location = self.sceneAddModel.location;
            [self.navigationController pushViewController:sceneAddLocationViewController animated:YES];
            
        }else  if (self.sceneType == AUXSceneTypeOfTime) {
            AUXSceneAddByTimeViewController *sceneAddByTimeViewControlle = [AUXSceneAddByTimeViewController instantiateFromStoryboard:kAUXStoryboardNameScene];
            sceneAddByTimeViewControlle.sceneType = AUXSceneTypeOfTime;
            sceneAddByTimeViewControlle.markType = @"changetime";
            sceneAddByTimeViewControlle.gobackBlock = ^{
                self.Bartitle = @"确定";
                [self.listTableview reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
            };
            [self.navigationController pushViewController:sceneAddByTimeViewControlle animated:YES];
        }
    }else if (indexPath.section==1) {
        
        if (self.sceneType == AUXSceneTypeOfPlace) {
            AUXSceneTimeQuantumViewController *sceneTimeQuantumViewController = [AUXSceneTimeQuantumViewController instantiateFromStoryboard:kAUXStoryboardNameScene];
            sceneTimeQuantumViewController.isNewAdd = self.isNewAdd;
            
            sceneTimeQuantumViewController.gobackBlock = ^(NSDictionary * _Nonnull dic) {
                AUXSceneCommonModel *commonModel = [AUXSceneCommonModel shareAUXSceneCommonModel];
                commonModel.repeatRule = dic[@"repetition"];
                commonModel.effectiveTime = dic[@"time"];
                self.Bartitle = @"确定";
                self.effectiveTime = [NSString stringWithFormat:@"%@ %@",dic[@"repetition"],dic[@"time"]];
                NSIndexSet *indexSet=[[NSIndexSet alloc]initWithIndex:2];
                [self.listTableview reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
            };
            [self.navigationController pushViewController:sceneTimeQuantumViewController animated:YES];
        }else{
            
            if (self.sceneType == AUXSceneTypeOfPlace) {
                if ([self.sceneAddModel.address isEqualToString:@"尚无指定区域"] ||self.sceneAddModel.address.length==0) {
                    [self showToastshortWithmessageinCenter:@"请添加指定区域"];
                    return;
                }
            }
            if (indexPath.row > self.sceneAddModel.deviceActionDtoList.count-1 ||self.sceneAddModel.deviceActionDtoList.count==0) {
                self.addNewDevice = @"添加新设备";
                [self ishaveDevice];
            }else{
                
                AUXSceneDeviceModel *model = self.sceneAddModel.deviceActionDtoList[indexPath.row];
                if (model.deviceId.length==0) {
                    [self ishaveDevice];
                }else{
                    AUXSceneResetSceneViewController *sceneResetSceneViewController = [AUXSceneResetSceneViewController instantiateFromStoryboard:kAUXStoryboardNameScene];
                    sceneResetSceneViewController.sceneType = self.sceneType;
                    sceneResetSceneViewController.addnewDevice = self.addNewDevice;
                    sceneResetSceneViewController.from = self.from;
                    sceneResetSceneViewController.deviceId = model.deviceId;
                    sceneResetSceneViewController.titleStr = model.deviceName;
                    sceneResetSceneViewController.isNewAdd = self.isNewAdd;
                    sceneResetSceneViewController.sceneName = self.sceneName;
                    NSString *indexStr = [NSString stringWithFormat:@"%ld",indexPath.row];
                    NSLog(@"%@",indexStr);
                    sceneResetSceneViewController.index = indexStr;
                    sceneResetSceneViewController.goBlock = ^{
                        self.Bartitle = @"确定";
                    };
                    [self.navigationController pushViewController:sceneResetSceneViewController animated:YES];
                }
            }
        }
    }else if (indexPath.section==2){
        if (self.sceneType == AUXSceneTypeOfPlace) {
            if ([self.sceneAddModel.address isEqualToString:@"尚无指定区域"] ||self.sceneAddModel.address.length==0) {
                [self showToastshortWithmessageinCenter:@"请添加指定区域"];
                return;
            }
        }
        if (indexPath.row > self.sceneAddModel.deviceActionDtoList.count-1||self.sceneAddModel.deviceActionDtoList.count==0) {
            [self ishaveDevice];
        }else{
            
            AUXSceneDeviceModel *model = self.sceneAddModel.deviceActionDtoList[indexPath.row];
            if (model.deviceId.length==0) {
                [self ishaveDevice];
            }else{
                    AUXSceneResetSceneViewController *sceneResetSceneViewController = [AUXSceneResetSceneViewController instantiateFromStoryboard:kAUXStoryboardNameScene];
                    sceneResetSceneViewController.sceneType = self.sceneType;
                    sceneResetSceneViewController.from = self.from;
                    sceneResetSceneViewController.deviceId = model.deviceId;
                    sceneResetSceneViewController.titleStr = model.deviceName;
                    sceneResetSceneViewController.isNewAdd = self.isNewAdd;
                NSString *indexStr = [NSString stringWithFormat:@"%ld",(long)indexPath.row];
                    NSLog(@"%@",indexStr);
                    sceneResetSceneViewController.index = indexStr;
                    sceneResetSceneViewController.addnewDevice = self.addNewDevice;
                    sceneResetSceneViewController.goBlock = ^{
                        self.Bartitle = @"确定";
                    };
                [self.navigationController pushViewController:sceneResetSceneViewController animated:YES];
            }
        }
    }
}


- (void)ishaveDevice {
    for (AUXDeviceInfo *info in self.deviceInfoArray) {
        if (info.suitType != AUXDeviceSuitTypeGateway) {
            [self.deviceInfoArray1 addObject:info];
        }
    }
    NSArray *tempArray = self.sceneAddModel.deviceActionDtoList;
    for (AUXDeviceInfo *info in tempArray) {
        NSString *deviceID = info.deviceId;
        for (AUXDeviceInfo *model in self.deviceInfoArray) {
            if ([model.deviceId isEqualToString:deviceID]) {
                if ([self.deviceInfoArray1 containsObject:model]) {
                    [self.deviceInfoArray1 removeObject:model];
                }
            }
        }
    }
    if (self.deviceInfoArray1.count== 0) {
        self.isExistE = NO;
    }else{
        self.isExistE = YES;
    }
    if (self.isExistE) {
         AUXSceneSelectDeviceListViewController *selectDeviceListViewController = [AUXSceneSelectDeviceListViewController instantiateFromStoryboard:kAUXStoryboardNameScene];
        selectDeviceListViewController.sceneType = self.sceneAddModel.sceneType;
        selectDeviceListViewController.isFromScenehomepage = YES;
        if ([self.from isEqualToString:@"sceneMy"]) {
        }else if([self.from isEqualToString:@"Myrecommend"]){
            selectDeviceListViewController.isNewAdd= self.isNewAdd;
            selectDeviceListViewController.sceneName1 = self.sceneName;
        } else{
            selectDeviceListViewController.isNewAdd = self.isNewAdd;
            selectDeviceListViewController.sceneName1 = self.sceneName;

        }
        [self.navigationController pushViewController:selectDeviceListViewController animated:YES];
    }else{
        [self showToastshortWithmessageinCenter:@"无可添加设备"];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *backView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 40)];
    backView.backgroundColor = [UIColor clearColor];
    UILabel *tipLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 10, 200, 20)];
    tipLabel.textAlignment = NSTextAlignmentLeft;
    tipLabel.textColor = [UIColor colorWithHexString:@"8E959D"];
    tipLabel.font = [UIFont systemFontOfSize:14];
    tipLabel.backgroundColor = [UIColor clearColor];
    [backView addSubview:tipLabel];
    if (self.sceneType == AUXSceneTypeOfPlace) {
        if (section ==0) {
            tipLabel.text = @"执行条件";
        }else if (section == 2){
            
            tipLabel.frame = CGRectMake(20, 20, 200, 20);
            
            tipLabel.text = @"执行动作";
        }else{
            tipLabel.text = @"";
        }
    }else{
        if (section ==0) {
            tipLabel.text = @"执行条件";
        }else if (section == 1){
            tipLabel.frame = CGRectMake(20, 20, 200, 20);
            tipLabel.text = @"执行动作";
        }else{
            tipLabel.text = @"";
        }
    }
    return backView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (self.sceneType == AUXSceneTypeOfPlace) {
        if (section==0) {
            return 40;
        }else if(section==1){
            return 12;
        }else{
           return 50;
        }

    }else{
        if (section == 0) {
            return 40;
        }else{
            return 50;
        }
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.0001;
}

#pragma mark 获取数据
- (NSMutableArray<AUXDeviceInfo *> *)deviceInfoArray {
    _deviceInfoArray = [[AUXUser defaultUser].deviceInfoArray mutableCopy];
    return _deviceInfoArray;
}

#pragma mark  保存按钮的点击事件
- (IBAction)saveItemAction:(UIBarButtonItem *)sender {
    if ([self.titleStr isEqualToString:@"推荐场景"]) {
        if (self.sceneType == AUXSceneTypeOfPlace) {
            if ([self.sceneAddModel.address isEqualToString:@"尚无指定区域"] ||self.sceneAddModel.address.length==0) {
                [self showToastshortWithmessageinCenter:@"请添加指定区域"];
                return;
            }
        }
    }
    NSString *repeatRule = self.sceneAddModel.repeatRule;
    self.sceneAddModel.repeatRule =  [self weekToNumberWithweekstr:repeatRule];
    if (self.sceneAddModel.repeatRule.length ==0) {
        self.sceneAddModel.repeatRule  = @"1,2,3,4,5,6,7";
        self.sceneAddModel.effectiveTime = @"00:00-24:00";
    }
    
    if ([self.titleStr isEqualToString:@"新增场景"] ||[self.titleStr isEqualToString:@"推荐场景"]) {
        if (self.sceneAddModel.deviceActionDtoList.firstObject.deviceId.length==0) {
            [self showToastshortWithmessageinCenter:@"请选择有效设备"];
            return;
        }
        if (self.sceneAddModel.sceneName.length == 0) {
            if ([self.isNewAdd isEqualToString:@"推荐场景"]) {
                self.sceneAddModel.sceneName = self.sceneName;
            }
            
            NSString *str;
            if (self.sceneName.length!=0) {
                str = self.sceneName;
            }else{
                str =self.sceneAddModel.sceneName;
            }
            @weakify(self);
            [AUXCommonAlertView alertViewWithnameType:AUXNamingTypeSceneName nameLabelText:@"场景名称" detailLabelText:str confirm:^(NSString *name) {
                @strongify(self);
                self.sceneAddModel.sceneName = name;
                [self saveScene];
            } close:^{
                self.sceneAddModel.sceneName = @"";
                
            }];
            
        }else{
            [self saveScene];
        }
    }else{
        NSString * isSceneEdit = [MyDefaults objectForKey:kIsSceneEdit];
        if ([isSceneEdit isEqualToString:@"1"]) {
            [self editScene];
        }else{
            AUXSceneSetCenterControlViewController *sceneSetCenterControlViewController = [AUXSceneSetCenterControlViewController instantiateFromStoryboard:kAUXStoryboardNameScene];
            sceneSetCenterControlViewController.form = @"sceneMy";
            [self.navigationController pushViewController:sceneSetCenterControlViewController animated:YES];
        }
    }
}

-(void)saveScene{
    if (self.sceneAddModel.deviceActionDtoList.firstObject.deviceId.length==0) {
        [self showToastshortWithmessageinCenter:@"请选择有效设备"];
        return;
    }
    
    
    [[AUXScenePlaceQueue sharedInstance] requestOpenPlaceScene];
    
    if ([self.sceneAddModel.repeatRule isEqualToString:@"不重复"]) {
        self.sceneAddModel.repeatRule = @"";
    }
    [[AUXNetworkManager manager] createSceneWith:self.sceneAddModel completion:^(AUXSceneDetailModel * _Nonnull detailModel, NSError *error) {
        if (detailModel.sceneId) {
            self.progressHUDImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"common_icon_success"]];
            [self showToastshortWithmessageinCenter:@"保存成功"];
            AUXSceneCommonModel *commonModel = [AUXSceneCommonModel shareAUXSceneCommonModel];
            [commonModel reSetValue];
            [self refreshDevice];
            if ([self.isNewAdd isEqualToString:@"推荐场景"]) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"ReturnMySceneList" object:nil];
            }
            [self.navigationController popToRootViewControllerAnimated:YES];
        } else {
            if (error.code == 311014) {
                [self showToastshortWithmessageinCenter:@"位置场景上限数量为4个"];
            } else {
                [self showToastshortWitherror:error];
            }
        }
    }];
}

- (void)editScene{
    
    AUXSceneCommonModel *commonModel = [AUXSceneCommonModel shareAUXSceneCommonModel];
    self.sceneAddModel = commonModel;
    
    if (self.sceneAddModel.deviceActionDtoList.firstObject.deviceId.length==0) {
        [self showToastshortWithmessageinCenter:@"请选择有效设备"];
        return;
    }
    NSString *repeatRule = self.sceneAddModel.repeatRule;
    self.sceneAddModel.repeatRule = [self weekToNumberWithweekstr:repeatRule];
    if (self.sceneAddModel.repeatRule.length ==0) {
        self.sceneAddModel.repeatRule  = @"1,2,3,4,5,6,7";
        self.sceneAddModel.effectiveTime = @"00:00-24:00";
    }
    
    if ([commonModel.repeatRule isEqualToString:@"不重复"]) {
        commonModel.repeatRule =  self.sceneAddModel.repeatRule;
        self.sceneAddModel.repeatRule = @"";
        commonModel.effectiveTime =  self.sceneAddModel.effectiveTime;
    }else{
        commonModel.repeatRule =  self.sceneAddModel.repeatRule;
        commonModel.effectiveTime =  self.sceneAddModel.effectiveTime;
    }
    [self showLoadingHUD];
    [[AUXNetworkManager manager] editSceneWithSceneId:commonModel.sceneId sceneAddModel:self.sceneAddModel completion:^(AUXSceneDetailModel * _Nonnull detailModel, NSError *error) {
        [self hideLoadingHUD];
        if (detailModel.sceneId) {
            AUXSceneCommonModel *commonModel = [AUXSceneCommonModel shareAUXSceneCommonModel];
            [commonModel reSetValue];
            [self showToastshortWithmessageinCenter:@"修改成功"];
            [MyDefaults setObject:@"0" forKey:kIsSceneEdit];
            [self refreshDevice];
            [self.navigationController popToRootViewControllerAnimated:YES];
        } else {
            [self showToastshortWithmessageinCenter:@"修改失败"];
        }
    }];
}

#pragma mark  星期转数字

- (NSString*)weekToNumberWithweekstr:(NSString*)weekstr {
    if ([weekstr isEqualToString:@"每天"]) {
        weekstr = @"1,2,3,4,5,6,7";
    }else if([weekstr isEqualToString:@"双休日"]){
        weekstr= @"6,7";
    }else if([weekstr isEqualToString:@"工作日"]){
        weekstr = @"1,2,3,4,5";
    }else{
        NSString *dateStr =[weekstr stringByReplacingOccurrencesOfString:@"一" withString:@"1"];
        NSString *dateStr2 =[dateStr stringByReplacingOccurrencesOfString:@"二" withString:@"2"];
        NSString *dateStr3 =[dateStr2 stringByReplacingOccurrencesOfString:@"三" withString:@"3"];
        NSString *dateStr4 =[dateStr3 stringByReplacingOccurrencesOfString:@"四" withString:@"4"];
        NSString *dateStr5 =[dateStr4 stringByReplacingOccurrencesOfString:@"五" withString:@"5"];
        NSString *dateStr6 =[dateStr5 stringByReplacingOccurrencesOfString:@"六" withString:@"6"];
        NSString *dateStr7 =[dateStr6 stringByReplacingOccurrencesOfString:@"日" withString:@"7"];
        weekstr =  dateStr7;
    }
    return weekstr;
}



-(NSString *)resetStr:(NSString*)str{
    NSString *result = @"";
    if ([str isEqualToString: @"1,2,3,4,5,6,7"]) {
        result = @"每天";
    }else if ([str isEqualToString: @"6,7"]) {
        result = @"双休日";
    }else if ([str isEqualToString: @"1,2,3,4,5"]){
        result = @"工作日";
    }else{
        NSString *dateStr =[str stringByReplacingOccurrencesOfString:@"1" withString:@"一"];
        NSString *dateStr2 =[dateStr stringByReplacingOccurrencesOfString:@"2" withString:@"二"];
        NSString *dateStr3 =[dateStr2 stringByReplacingOccurrencesOfString:@"3" withString:@"三"];
        NSString *dateStr4 =[dateStr3 stringByReplacingOccurrencesOfString:@"4" withString:@"四"];
        NSString *dateStr5 =[dateStr4 stringByReplacingOccurrencesOfString:@"5" withString:@"五"];
        NSString *dateStr6 =[dateStr5 stringByReplacingOccurrencesOfString:@"6" withString:@"六"];
        NSString *dateStr7 =[dateStr6 stringByReplacingOccurrencesOfString:@"7" withString:@"日"];
        result = dateStr7;
    }
    return result;
}

- (void)backAtcion {
    if ([self.titleStr isEqualToString:@"新增场景"] ) {
        [self showAlert];
    }else if ([self.titleStr isEqualToString:@"推荐场景"]){
        AUXSceneCommonModel *commonModel = [AUXSceneCommonModel shareAUXSceneCommonModel];
        AUXSceneAddModel *model = (AUXSceneAddModel*)commonModel;
        if (model.deviceActionDtoList.count==0) {
             [self showAlert];
        }else{
            if (model.deviceActionDtoList.firstObject.deviceId.length==0) {
                [self.navigationController popViewControllerAnimated:YES];
            }else{
                [self showAlert];
            }
        }
    }else{
        NSString * isSceneEdit = [MyDefaults objectForKey:kIsSceneEdit];
        if ([isSceneEdit isEqualToString:@"1"]) {
            [self showAlert];
        }else{
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

-(void)showAlert{
    [AUXAlertCustomView alertViewWithMessage:@"是否放弃编辑？" confirmAtcion:^{
        AUXSceneCommonModel *commonModel = [AUXSceneCommonModel shareAUXSceneCommonModel];
        [commonModel reSetValue];
        [self.navigationController popToRootViewControllerAnimated:YES];
    } cancleAtcion:^{
        
    }];
}

- (void)refreshDevice{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[AUXScenePlaceQueue sharedInstance] requestOpenPlaceScene];
    });
}

#pragma mark  删除设备的方法


-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.sceneType == AUXSceneTypeOfPlace) {
        if (indexPath.section==2) {
            if (self.sceneAddModel.deviceActionDtoList.count==1) {
                if (indexPath.row==0) {
                    return @"删除";
                }
            }else if(self.sceneAddModel.deviceActionDtoList.count>1){
                if (indexPath.row != self.self.sceneAddModel.deviceActionDtoList.count-1) {
                    return @"删除";
                }
            }
        }
    }else{
        if (indexPath.section==1) {
            return @"删除";
        }
    }
    return @"";
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (self.sceneType == AUXSceneTypeOfPlace) {
        if (indexPath.section==2) {
            if (self.sceneAddModel.deviceActionDtoList.count==1) {
                if (indexPath.row==0) {
                    return UITableViewCellEditingStyleDelete;
                }
            }else if(self.sceneAddModel.deviceActionDtoList.count>1){
                if (indexPath.row != self.self.sceneAddModel.deviceActionDtoList.count) {
                    return UITableViewCellEditingStyleDelete;
                }
            }
        }
    }else{
        if (indexPath.section==1) {
            if (self.sceneAddModel.deviceActionDtoList.count==1) {
                if (indexPath.row==0) {
                    return UITableViewCellEditingStyleDelete;
                }
            }else if(self.sceneAddModel.deviceActionDtoList.count>1){
                if (indexPath.row != self.self.sceneAddModel.deviceActionDtoList.count) {
                    return UITableViewCellEditingStyleDelete;
                }
            }
        }
    }
    return UITableViewCellEditingStyleNone;
}

- (void)tableView:(UITableView*)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath*)indexPath {
    AUXSceneDeviceModel *model = self.sceneAddModel.deviceActionDtoList[indexPath.row];
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        tableView.editing = NO;
        NSString *alertMessage = [NSString stringWithFormat:@"是否确认删除'%@'?",model.deviceName];
        @weakify(self);
        [AUXAlertCustomView alertViewWithMessage:alertMessage confirmAtcion:^{
             @strongify(self);
            NSMutableArray *tmparray = self.sceneAddModel.deviceActionDtoList.mutableCopy;
            if ([tmparray containsObject:model]) {
               [tmparray removeObject:model];
            }
            self.sceneAddModel.deviceActionDtoList = tmparray.mutableCopy;
            [self.listTableview reloadData];
            self.saveItem.title = @"保存";
            self.saveItem.image =  [[UIImage imageNamed:@"nil"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
            [MyDefaults setObject:@"1" forKey:kIsSceneEdit];
        } cancleAtcion:^{
        }];
    }
}




@end











