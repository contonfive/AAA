//
//  AUXSceneViewController.m
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2018/8/1.
//  Copyright © 2018年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXSceneViewController.h"
#import "AUXSceneAddNewViewController.h"
#import "AUXUser.h"
#import "AUXNetworkManager.h"
#import "AUXScenePlaceQueue.h"
#import "AUXLocateTool.h"
#import "AUXMySceneTableViewCell.h"
#import "AUXSceneViewListTableViewCell.h"
#import "UIColor+AUXCustom.h"
#import "AUXSceneAddNewDetailViewController.h"
#import "AUXSceneCommonModel.h"
#import "AUXSceneLogViewController.h"
#import "AUXSceneSetCenterControlViewController.h"
#import "AUXDeviceControlViewController.h"
#import "AUXAlertCustomView.h"
#import "AUXSceneCenterControlSelectViewController.h"

#import "AUXCurrentNoDataView.h"


@interface AUXSceneViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,strong) NSMutableArray<AUXSceneDetailModel *> *handMovemenModelList;
@property (nonatomic,strong) NSMutableArray<AUXSceneDetailModel *> *automaticModelList;
@property (weak, nonatomic) IBOutlet UIButton *recommendButton;
@property (weak, nonatomic) IBOutlet UIButton *myButton;
@property (weak, nonatomic) IBOutlet UIView *underLineLabel;
@property (weak, nonatomic) IBOutlet UITableView *listTableView;
@property (nonatomic,strong)NSString *tableviewType;
@property (nonatomic,strong)NSArray *recommendArray;
@property (nonatomic,strong) NSMutableArray*dataArray;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *logItem;
@property (nonatomic, strong) NSMutableArray<AUXDeviceInfo *> *deviceInfoArray;
@property (nonatomic,strong) AUXCurrentNoDataView *noDataView;

@end

@implementation AUXSceneViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.logItem.image = [[UIImage imageNamed:@"scene_nav_btn_log"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [self.listTableView registerNib:[UINib nibWithNibName:@"AUXMySceneTableViewCell" bundle:nil] forCellReuseIdentifier:@"AUXMySceneTableViewCell"];
    [self.listTableView registerNib:[UINib nibWithNibName:@"AUXSceneViewListTableViewCell" bundle:nil] forCellReuseIdentifier:@"AUXSceneViewListTableViewCell"];
    self.listTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableviewType = @"recommend";
    self.recommendArray = @[@{@"title":@"回家（手动）",@"description":@"如：到家后打开客厅空调",@"image":@"scene_bg_commend1",@"textColor":@"557249"},
                            @{@"title":@"离家（手动）",@"description":@"如：离家后关闭卧室空调",@"image":@"scene_bg_commend2",@"textColor":@"447183"},
                            @{@"title":@"多设备快捷控制",@"description":@"如：同时关闭多台空调",@"image":@"scene_bg_commend3",@"textColor":@"534D49"},
                            ];
    self.recommendButton.frame = CGRectMake(22, 0, 60, 40);
    self.myButton.frame = CGRectMake(106, 11, 40, 25);
    self.underLineLabel.frame = CGRectMake(24, 42, 30, 3);
    self.underLineLabel.layer.masksToBounds = YES;
    self.underLineLabel.layer.cornerRadius = 1.5;
    self.listTableView.backgroundColor = [UIColor whiteColor];
    self.recommendButton.titleLabel.font = [UIFont boldSystemFontOfSize:28];
    self.myButton.titleLabel.font = [UIFont systemFontOfSize:18];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTableView:) name:@"ReturnMySceneList" object:nil];
}

- (void)refreshTableView: (NSNotification *) notification {
    [self myButtonAction:self.myButton];
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    self.tabBarController.tabBar.hidden = NO;
    AUXSceneCommonModel *commonModel = [AUXSceneCommonModel shareAUXSceneCommonModel];
    [commonModel reSetValue];
    NSString *tabbarSetect = [MyDefaults objectForKey:kTabbarIndex];
    NSString *mysceneSelect = [MyDefaults objectForKey:kMySceneSelect];
    if ([tabbarSetect isEqualToString:@"1"]&&[mysceneSelect isEqualToString:@"1"]) {
        self.tableviewType = @"myScene";
        [self myButtonAction:self.myButton];

     }
    if ([self.tableviewType isEqualToString:@"myScene"]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self requestSceneList];
        });
    }
}

#pragma mark 网络请求
- (void)requestSceneList {
    [[AUXNetworkManager manager] homePagelistSceneCompletion:^(NSArray<AUXSceneDetailModel *> * _Nonnull detailModelList, NSError * _Nonnull error) {
        switch (error.code) {
            case AUXNetworkErrorNone:
                [self resetData:detailModelList];
                break;
            case AUXNetworkErrorAccountCacheExpired:
                [self alertAccountCacheExpiredMessage];
                break;
            default:
                [self showToastshortWitherror:error];
                break;
        }
    }];
}


-(void)resetData:(NSArray *)detailModelList{
    if (detailModelList.count > 0) {
        [self.dataArray removeAllObjects];
        [self.automaticModelList removeAllObjects];
        [self.handMovemenModelList removeAllObjects];
        for (AUXSceneDetailModel*model in detailModelList) {
            if (model.sceneType==3 || model.sceneType== 4 ) {
                [self.handMovemenModelList addObject:model];
            }else{
                [self.automaticModelList addObject:model];
            }
        }
        if (self.handMovemenModelList.count!=0) {
            [self.dataArray addObject:self.handMovemenModelList];
        }
        if (self.automaticModelList.count !=0) {
            [self.dataArray addObject:self.automaticModelList];
        }
        [self tableViewReload];
    }
}

- (void)tableViewReload {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.listTableView reloadData];
        if ([self.tableviewType isEqualToString:@"myScene"]) {
            if (self.dataArray.count==0) {
                self.noDataView.hidden = NO;
                self.listTableView.hidden = YES;
            }else{
                self.noDataView.hidden = YES;
                self.listTableView.hidden = NO;
            }
        }else{
            self.noDataView.hidden = YES;
            self.listTableView.hidden = NO;
        }
        
    });
    
}

#pragma mark getter
- (NSMutableArray<AUXSceneDetailModel *> *)handMovemenModelList {
    if (!_handMovemenModelList) {
        _handMovemenModelList = [NSMutableArray array];
    }
    return _handMovemenModelList;
}

#pragma mark getter
- (NSMutableArray<AUXSceneDetailModel *> *)automaticModelList {
    if (!_automaticModelList) {
        _automaticModelList = [NSMutableArray array];
    }
    return _automaticModelList;
}

#pragma mark getter
- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

#pragma mark  推荐按钮的点击事件
- (IBAction)recommendButtonAction:(UIButton *)sender {
    [MyDefaults setObject:@"0" forKey:kMySceneSelect];
    self.tableviewType = @"recommend";
    [self tableViewReload];
    self.recommendButton.titleLabel.font = [UIFont boldSystemFontOfSize:28];
    [UIView animateWithDuration:0.25 animations:^{
        sender.selected = YES;
        self.myButton.selected = NO;
        self.recommendButton.frame = CGRectMake(22, 0, 60, 40);
        self.myButton.frame = CGRectMake(106, 11, 40, 25);
        self.underLineLabel.frame = CGRectMake(24, 42, 30, 3);
        self.recommendButton.titleLabel.font = [UIFont boldSystemFontOfSize: 28.0];
        self.myButton.titleLabel.font = [UIFont systemFontOfSize: 18.0];
        [self.recommendButton setTitleColor:[UIColor colorWithHexString:@"333333"] forState:UIControlStateNormal];
        [self.myButton setTitleColor:[UIColor colorWithHexString:@"666666"] forState:UIControlStateNormal];
        [self.view layoutIfNeeded];
    }];
    if (self.dataArray.count>0) {
        [self.listTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
    
    
}
#pragma mark  我的按钮的点击事件
- (IBAction)myButtonAction:(UIButton *)sender {
    [MyDefaults setObject:@"1" forKey:kMySceneSelect];
    AUXUser *user = [AUXUser defaultUser];
    if (user.uid && user.accessToken) {
        [self requestSceneList];
        self.tableviewType = @"myScene";
        [UIView animateWithDuration:0.25 animations:^{
            sender.selected = YES;
            self.recommendButton.frame = CGRectMake(22, 14, 40, 25);
            self.myButton.frame = CGRectMake(86, 0, 60, 40);
            self.underLineLabel.frame = CGRectMake(88, 42, 30, 3);
            self.recommendButton.selected = NO;
            self.myButton.titleLabel.font = [UIFont boldSystemFontOfSize: 28.0];
            self.recommendButton.titleLabel.font = [UIFont systemFontOfSize: 18.0];
            [self.myButton setTitleColor:[UIColor colorWithHexString:@"333333"] forState:UIControlStateNormal];
            [self.recommendButton setTitleColor:[UIColor colorWithHexString:@"666666"] forState:UIControlStateNormal];
            [self.view layoutIfNeeded];
        }];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:AUXAccountCacheDidExpireNotification object:nil];
    }
    
    [self.listTableView reloadData];
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    if ([self.tableviewType isEqualToString:@"myScene"]) {
        AUXSceneDetailModel *model = self.dataArray[indexPath.section][indexPath.row];
        static NSString * CellIdentifier1 = @"AUXMySceneTableViewCell";
        AUXMySceneTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier1];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.sceneDetailModel = model;
        if (model.sceneType==3 || model.sceneType== 4 ) {
            if (model.sceneType ==AUXSceneTypeOfCenterControl) {
                cell.handMovementView.hidden = YES;
                cell.automaticView.hidden  = YES;
            }else{
                cell.handMovementView.hidden = NO;
                cell.automaticView.hidden  = YES;
            }
        }else{
            cell.handMovementView.hidden = YES;
            cell.automaticView.hidden  = NO;
        }
        
        cell.manualPerfomBlock = ^(AUXSceneDetailModel *detailModel) {
            [self requestManualPower:model];
        };
        cell.autoPerformBlock = ^(AUXSceneDetailModel *detailModel, BOOL status) {
            [self requestAutoPower:detailModel status:status];
        };
        if (model.sceneType==1) {
            cell.headerImageview.image = [UIImage imageNamed:@"scene_icon_place"];
        }else if (model.sceneType==2){
            cell.headerImageview.image = [UIImage imageNamed:@"scene_icon_time"];
            
        }else if (model.sceneType==3){
            cell.headerImageview.image = [UIImage imageNamed:@"scene_icon_hand"];
        }else{
            cell.headerImageview.image = [UIImage imageNamed:@"scene_icon_focus"];
        }
        return cell;
    }else{
        static NSString * CellIdentifier = @"AUXSceneViewListTableViewCell";
        AUXSceneViewListTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        cell.nameLabel.text = self.recommendArray[indexPath.row][@"title"];
        cell.describeLabel.text = self.recommendArray[indexPath.row][@"description"];
        cell.backImageView.image = [UIImage imageNamed:self.recommendArray[indexPath.row][@"image"]];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        if (indexPath.row ==0) {
            cell.nameLabel.textColor = [UIColor colorWithHexString:@"557249"];
        }else  if (indexPath.row ==1) {
            cell.nameLabel.textColor = [UIColor colorWithHexString:@"447183"];
        }else{
            cell.nameLabel.textColor = [UIColor colorWithHexString:@"534D49"];
        }
        return cell;
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if ([self.tableviewType isEqualToString:@"myScene"]) {
        return [self.dataArray[section] count];
    }else{
        return self.recommendArray.count;
    }
}

#pragma mark  tableview 每行的高度
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([self.tableviewType isEqualToString:@"myScene"]) {
        return 94;
    }else{
        return 162;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if ([self.tableviewType isEqualToString:@"myScene"]) {
        return self.dataArray.count;
    }else{
        return 1;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if ([self.tableviewType isEqualToString:@"myScene"]) {
        UIView *backView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 20)];
        backView.backgroundColor = [UIColor clearColor];
        UILabel *tipLabel = [[UILabel alloc]init];
        if (section==0) {
            tipLabel.frame = CGRectMake(20, 10, 34, 20);
        }else{
             tipLabel.frame = CGRectMake(20, 0, 34, 20);
        }
        tipLabel.textAlignment = NSTextAlignmentCenter;
        tipLabel.textColor = [UIColor colorWithHexString:@"8E959D"];
        tipLabel.layer.masksToBounds = YES;
        tipLabel.layer.borderWidth = 1;
        tipLabel.layer.cornerRadius = 2;
        tipLabel.layer.borderColor = [UIColor colorWithHexString:@"E5E5E5"].CGColor;
        tipLabel.font = [UIFont systemFontOfSize:12];
        if (self.handMovemenModelList.count !=0 && self.recommendArray.count !=0) {
            if (section==0) {
                tipLabel.text = @"手动";
            }else{
                tipLabel.text = @"自动";
            }
        }else if (self.handMovemenModelList.count !=0 && self.recommendArray.count ==0){
            tipLabel.text = @"手动";
        }else if (self.handMovemenModelList.count ==0 && self.recommendArray.count !=0){
            tipLabel.text = @"自动";
        }
        [backView addSubview:tipLabel];
        return backView;
    }else{
        return nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if ([self.tableviewType isEqualToString:@"myScene"]) {
        if (section==0) {
            return 30;
        }else{
         return 20;
        }
        
    }else{
        return 0.001;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.0001;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([self.tableviewType isEqualToString:@"myScene"]) {
        AUXSceneDetailModel *model = self.dataArray[indexPath.section][indexPath.row];
        [self getSceneDetailWith:model.sceneId];
        [MyDefaults setObject:@"0" forKey:kIsSceneEdit];
        
    }else{
        if (indexPath.row==0 || indexPath.row==1) {
            AUXSceneDeviceModel *model = [[AUXSceneDeviceModel alloc]init];
            model.deviceName = @"空调";
            model.onOff = 0;
            AUXSceneCommonModel *commonModel = [AUXSceneCommonModel shareAUXSceneCommonModel];
            commonModel.address = @"尚无指定区域";
            commonModel.actionType = indexPath.row==1?1:2;
            commonModel.sceneType = AUXSceneTypeOfManual;
            commonModel.deviceActionDtoList = @[model].mutableCopy;
            AUXSceneAddNewDetailViewController *sceneAddNewDetailViewController = [AUXSceneAddNewDetailViewController instantiateFromStoryboard:kAUXStoryboardNameScene];
            sceneAddNewDetailViewController.sceneType = AUXSceneTypeOfManual;
            sceneAddNewDetailViewController.from = @"Myrecommend";
            sceneAddNewDetailViewController.titleStr = @"推荐场景";
            sceneAddNewDetailViewController.isNewAdd = @"推荐场景";
            
            if (indexPath.row==0) {
                sceneAddNewDetailViewController.sceneName = @"回家（手动）";
            }else{
                sceneAddNewDetailViewController.sceneName = @"离家（手动）";
            }
            [self.navigationController pushViewController:sceneAddNewDetailViewController animated:YES];
        }else{
            
            
            NSMutableArray *tmpArray = [[NSMutableArray alloc]init];
            for (AUXDeviceInfo *info in self.deviceInfoArray) {
                if (info.suitType !=1) {
                    [tmpArray addObject:info];
                }
            }
            if (tmpArray.count==0) {
                [self showToastshortWithmessageinCenter:@"无可添加设备"];
                return;
            }
            AUXSceneCenterControlSelectViewController *sceneCenterControlSelectViewController = [AUXSceneCenterControlSelectViewController instantiateFromStoryboard:kAUXStoryboardNameScene];
            sceneCenterControlSelectViewController.isCreatCentrol = YES;
            sceneCenterControlSelectViewController.isfromHomepage = YES;
            [self.navigationController pushViewController:sceneCenterControlSelectViewController animated:YES];
        }
    }
}

#pragma mark  上传开关状态
- (void)requestAutoPower:(AUXSceneDetailModel *)sceneDetailModel status:(BOOL)status {
    [self showLoadingHUD];
    [[AUXNetworkManager manager] powerSceneWithSceneId:sceneDetailModel.sceneId state:status completion:^(AUXSceneDetailModel * _Nonnull detailModel, NSError * _Nonnull error) {
        [self hideLoadingHUD];
        switch (error.code) {
            case AUXNetworkErrorNone:
                break;
            case AUXNetworkErrorAccountCacheExpired:
                [self alertAccountCacheExpiredMessage];
                break;
            default:
                break;
        }
    }];
}

#pragma mark  手动执行
- (void)requestManualPower:(AUXSceneDetailModel *)sceneDetailModel {
    [self showLoadingHUD];
    [[AUXNetworkManager manager] manualSceneWithSceneId:sceneDetailModel.sceneId completion:^(BOOL result, NSError * _Nonnull error) {
        [self hideLoadingHUD];
        switch (error.code) {
            case AUXNetworkErrorNone:
                [self showToastshortWithmessageinCenter:@"执行成功"];
                break;
            case AUXNetworkErrorAccountCacheExpired:
                [self alertAccountCacheExpiredMessage];
                break;
            default:
                [self showToastshortWithmessageinCenter:@"执行失败"];
                break;
        }
    }];
}

#pragma mark  新增场景点击事件
- (IBAction)addSceneItemAction:(id)sender {
    [self requestSceneList];
    AUXUser *user = [AUXUser defaultUser];
    if (user.uid && user.accessToken) {
        AUXSceneAddNewViewController *sceneNewViewController = [AUXSceneAddNewViewController instantiateFromStoryboard:kAUXStoryboardNameScene];
        NSMutableArray *tmpArray = [[NSMutableArray alloc]init];
        for (AUXDeviceInfo *info in self.deviceInfoArray) {
            if (info.suitType != AUXDeviceSuitTypeGateway) {
                [tmpArray addObject:info];
            }
        }
        sceneNewViewController.dataArray1 = tmpArray;
        [self.navigationController pushViewController:sceneNewViewController animated:YES];
    }else{
        [[NSNotificationCenter defaultCenter] postNotificationName:AUXAccountCacheDidExpireNotification object:nil];
    }
}

#pragma mark  日志按钮的点击事件
- (IBAction)logItemAction:(id)sender {
    AUXSceneLogViewController *sceneNewViewController = [AUXSceneLogViewController instantiateFromStoryboard:kAUXStoryboardNameScene];
    [self.navigationController pushViewController:sceneNewViewController animated:YES];
}



- (void)getSceneDetailWith:(NSString*)sceneId {
    @weakify(self);
    [self showLoadingHUD];
    [[AUXNetworkManager manager] detailSceneWithSceneId:sceneId completion:^(AUXSceneDetailModel * _Nonnull detailModel, NSError * _Nonnull error) {
        @strongify(self);
        if (detailModel.sceneId) {
            AUXSceneCommonModel *commonModel = [AUXSceneCommonModel shareAUXSceneCommonModel];
            commonModel.actionDescription = detailModel.actionDescription;
            commonModel.actionTime = detailModel.actionTime;
            commonModel.actionType = detailModel.actionType;
            commonModel.deviceActionDtoList = detailModel.deviceActionVoList.mutableCopy;
            commonModel.distance = detailModel.distance;
            commonModel.effectiveTime = detailModel.effectiveTime;
            commonModel.location = detailModel.location;
            commonModel.address = detailModel.address;
            commonModel.repeatRule = detailModel.repeatRule;
            commonModel.sceneName = detailModel.sceneName;
            commonModel.sceneType = detailModel.sceneType;
            commonModel.state = detailModel.state;
            commonModel.uid = detailModel.uid;
            commonModel.sceneId = detailModel.sceneId;
            commonModel.whetherInitFlag = detailModel.whetherInitFlag;
            [self setDeviceImage];
        } else {
            [self showErrorViewWithMessage:@"获取场景详情失败"];
        }
    }];
}

- (void)setDeviceImage{
    AUXSceneCommonModel *commonModel = [AUXSceneCommonModel shareAUXSceneCommonModel];
    NSMutableArray *tmparray = commonModel.deviceActionDtoList.mutableCopy;
    NSMutableArray *tmparray2 = [[NSMutableArray alloc]init];
    for (AUXSceneDeviceModel *model in tmparray) {
        for (AUXDeviceInfo *info in self.deviceInfoArray) {
            if ([info.deviceId isEqualToString:model.deviceId]) {
                model.imageUrl = info.deviceMainUri;
                [tmparray2 addObject:model];
            }
        }
    }
    
    if (tmparray2.count ==0) {
        AUXSceneDeviceModel *model = [[AUXSceneDeviceModel alloc]init];
        model.deviceName = @"空调";
        model.onOff = 0;
        commonModel.deviceActionDtoList = @[model].mutableCopy;
    }else{
        commonModel.deviceActionDtoList = tmparray2.mutableCopy;
    }
    [self hideLoadingHUD];
    if (commonModel.sceneType != AUXSceneTypeOfCenterControl) {
        AUXSceneAddNewDetailViewController *sceneAddNewDetailViewController = [AUXSceneAddNewDetailViewController instantiateFromStoryboard:kAUXStoryboardNameScene];
        commonModel.isEdit = YES;
        sceneAddNewDetailViewController.sceneType = commonModel.sceneType;
        sceneAddNewDetailViewController.titleStr = commonModel.sceneName;
        sceneAddNewDetailViewController.from = @"sceneMy";
        [self.navigationController pushViewController:sceneAddNewDetailViewController animated:YES];
    }else{
        NSMutableArray *tmpArry = [[NSMutableArray alloc]init];
        for (AUXSceneDeviceModel *model in commonModel.deviceActionDtoList) {
            for (AUXDeviceInfo *info in self.deviceInfoArray) {
                if ([model.deviceId isEqualToString:info.deviceId]) {
                    [tmpArry addObject:info];
                }
            }
        }
        AUXDeviceControlViewController *deviceControllerViewController = [AUXDeviceControlViewController instantiateFromStoryboard:kAUXStoryboardNameDeviceControl];
        deviceControllerViewController.controlType = AUXDeviceControlTypeSceneMultiDevice;
        deviceControllerViewController.deviceInfoArray = tmpArry;
        [self.navigationController pushViewController:deviceControllerViewController animated:YES];
    }
}

#pragma mark 获取数据
- (NSMutableArray<AUXDeviceInfo *> *)deviceInfoArray {
    _deviceInfoArray = [[AUXUser defaultUser].deviceInfoArray mutableCopy];
    return _deviceInfoArray;
}




-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([self.tableviewType isEqualToString:@"myScene"]) {
        return @"删除";
    }
    return @"";
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([self.tableviewType isEqualToString:@"myScene"]) {
        return UITableViewCellEditingStyleDelete;
    }
    return UITableViewCellEditingStyleNone;
}

- (void)tableView:(UITableView*)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath*)indexPath {
    
    if ([self.tableviewType isEqualToString:@"myScene"]) {
        if (editingStyle == UITableViewCellEditingStyleDelete) {
            tableView.editing = NO;
            AUXSceneDetailModel *detailModel= self.dataArray[indexPath.section][indexPath.row];
            [self deleteScene:detailModel];
        }
    }
}


- (void)deleteScene:(AUXSceneDetailModel *)sceneDetailModel {
    
    if (sceneDetailModel.sceneId  && sceneDetailModel.whetherInitFlag == 0) {
        [self requestDeleteScene:sceneDetailModel];
    }else{
        [self showFailure:@"默认场景不允许删除"];
    }
}


#pragma mark  删除场景
- (void)requestDeleteScene:(AUXSceneDetailModel *)sceneDetailModel {
    NSString *alertMessage = [NSString stringWithFormat:@"是否确认删除'%@'?",sceneDetailModel.sceneName];
    @weakify(self);
    [AUXAlertCustomView alertViewWithMessage:alertMessage confirmAtcion:^{
         @strongify(self);
        [self showLoadingHUD];
        [[AUXNetworkManager manager] deleteSceneWithSceneId:sceneDetailModel.sceneId completion:^(BOOL result, NSError * _Nonnull error) {
              @strongify(self);
            [self hideLoadingHUD];
            if (error.code==200) {
                [self reSetTabelview:sceneDetailModel];
                
//                [self showSuccessWithAttributedString:[[NSAttributedString alloc]initWithString:@"场景删除成功!" attributes:@{NSForegroundColorAttributeName : [UIColor blackColor]}] completion:^{
//
//                }];
                
                [self showToastshortWithmessageinCenter:@"删除成功"];
            } else {
//                [self showErrorViewWithError:error defaultMessage:@"场景删除失败!"];
                 [self showToastshortWithmessageinCenter:@"删除失败"];
            }
        }];
    } cancleAtcion:^{
        
    }];
}


- (void)reSetTabelview:(AUXSceneDetailModel *)sceneDetailModel {
    [self.dataArray removeAllObjects];
    NSMutableArray *array1 = self.handMovemenModelList.mutableCopy;
    NSMutableArray *array2 = self.automaticModelList.mutableCopy;
    if (sceneDetailModel.sceneType==3 || sceneDetailModel.sceneType== 4 ) {
        for (AUXSceneDetailModel *model in array1) {
            if ([model.sceneId isEqualToString:sceneDetailModel.sceneId]) {
                if ([self.handMovemenModelList containsObject:sceneDetailModel]) {
                     [self.handMovemenModelList removeObject:sceneDetailModel];
                }
            }
        }
    }else{
        for (AUXSceneDetailModel *model in array2) {
            if ([model.sceneId isEqualToString:sceneDetailModel.sceneId]) {
                if ([self.automaticModelList containsObject:sceneDetailModel]) {
                     [self.automaticModelList removeObject:sceneDetailModel];
                }
               
            }
        }
    }
    if (self.handMovemenModelList.count!=0) {
        [self.dataArray addObject:self.handMovemenModelList];
    }
    if (self.automaticModelList.count !=0) {
        [self.dataArray addObject:self.automaticModelList];
    }
    [self.listTableView reloadData];
    [[AUXScenePlaceQueue sharedInstance] requestOpenPlaceScene];
    
}


- (AUXCurrentNoDataView *)noDataView {
    if (!_noDataView) {
        _noDataView = [[NSBundle mainBundle]loadNibNamed:@"AUXCurrentNoDataView" owner:self options:nil].firstObject;
        _noDataView.iconImageView.image = [UIImage imageNamed:@"scene_img_noscene"];
        _noDataView.titleLabel.text = @"暂无场景";
        _noDataView.frame = CGRectMake(0, self.listTableView.frame.origin.y, kAUXScreenWidth, self.listTableView.frame.size.height);
        [self.view addSubview:_noDataView];
        
        _noDataView.topLayoutConstraint.constant = 0;
        _noDataView.hidden = YES;
    }
    return _noDataView;
}


@end





