//
//  AUXSceneAddNewViewController.m
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2018/8/8.
//  Copyright © 2018年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXSceneAddNewViewController.h"
#import "AUXSceneAddSceneTableViewCell.h"
#import "UITableView+AUXCustom.h"
#import "AUXLocateTool.h"
#import "AUXSceneSelectDeviceListViewController.h"
#import "AUXSceneAddByTimeViewController.h"
#import "AUXSceneAddLocationViewController.h"
#import "AUXSceneCommonModel.h"
#import "AUXSceneCenterControlSelectViewController.h"
#import "UIColor+AUXCustom.h"
#import "AUXAlertCustomView.h"

@interface AUXSceneAddNewViewController ()<UITableViewDelegate , UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,strong) NSArray *dataArray;
@end

@implementation AUXSceneAddNewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerCellWithNibName:@"AUXSceneAddSceneTableViewCell"];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.view.backgroundColor = [UIColor colorWithHexString:@"F7F7F7"];
    self.tableView.backgroundColor = [UIColor colorWithHexString:@"F7F7F7"];
    self.tableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    [self setData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    AUXSceneCommonModel *commonModel = [AUXSceneCommonModel shareAUXSceneCommonModel];
    [commonModel reSetValue];
}

#pragma mark  重置数据
- (void)setData {
    self.dataArray = @[@{@"titleText":@"手动触发",@"describe":@"手动执行指定动作",@"image":@"scene_icon_hand"},
                       @{@"titleText":@"位置触发",@"describe":@"进入/离开指定区域后执行指定动作",@"image":@"scene_icon_place"},
                       @{@"titleText":@"时间触发",@"describe":@"在指定时间执行指定动作",@"image":@"scene_icon_time"},
                       @{@"titleText":@"集中控制",@"describe":@"同时控制多台设备",@"image":@"scene_icon_focus"},
                       ];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AUXSceneAddSceneTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AUXSceneAddSceneTableViewCell" forIndexPath:indexPath];
    cell.titleTextLabel.text = self.dataArray[indexPath.row][@"titleText"];
    cell.describeLabel.text = self.dataArray[indexPath.row][@"describe"];
    cell.iconImageView.image = [UIImage imageNamed:self.dataArray[indexPath.row][@"image"]];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.dataArray1.count==0) {
        [self showToastshortWithmessageinCenter:@"无可添加设备"];
        return;
    }
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (indexPath.row == 1) {
        if (![AUXLocateTool whtherOpenLocalionPermissions]) {
            [AUXAlertCustomView alertViewWithMessage:@"请先开启定位服务" confirmAtcion:^{
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
            } cancleAtcion:^{
            }];
             return ;
        }
        AUXSceneAddLocationViewController *sceneAddLocationViewController = [AUXSceneAddLocationViewController instantiateFromStoryboard:kAUXStoryboardNameScene];
        sceneAddLocationViewController.sceneType = AUXSceneTypeOfPlace;
        sceneAddLocationViewController.isNewAdd =@"新增场景";
        [self.navigationController pushViewController:sceneAddLocationViewController animated:YES];
        
    } else if (indexPath.row == 0) {
        AUXSceneSelectDeviceListViewController *selectDeviceListViewController = [AUXSceneSelectDeviceListViewController instantiateFromStoryboard:kAUXStoryboardNameScene];
        selectDeviceListViewController.sceneType = AUXSceneTypeOfManual;
        selectDeviceListViewController.isNewAdd = @"新增场景";
        [self.navigationController pushViewController:selectDeviceListViewController animated:YES];
        
    } else if (indexPath.row == 2) {
        AUXSceneAddByTimeViewController *sceneAddByTimeViewControlle = [AUXSceneAddByTimeViewController instantiateFromStoryboard:kAUXStoryboardNameScene];
        sceneAddByTimeViewControlle.sceneType = AUXSceneTypeOfTime;
        sceneAddByTimeViewControlle.isNewAdd = @"新增场景";
        [self.navigationController pushViewController:sceneAddByTimeViewControlle animated:YES];
    } else if (indexPath.row == 3) {
        AUXSceneCenterControlSelectViewController *sceneCenterControlSelectViewController = [AUXSceneCenterControlSelectViewController instantiateFromStoryboard:kAUXStoryboardNameScene];
        sceneCenterControlSelectViewController.isCreatCentrol = YES;
        sceneCenterControlSelectViewController.isNewAdd = @"新增场景";

        [self.navigationController pushViewController:sceneCenterControlSelectViewController animated:YES];
    }
    
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row==3) {
        return 104;
    }
    return 94;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.001;
}


@end


