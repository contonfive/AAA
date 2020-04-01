//
//  AUXSceneExecuteDeviceViewController.m
//  AUXSmartHome
//
//  Created by AUX on 2019/4/15.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXSceneExecuteDeviceViewController.h"
#import "AUXSceneSelectDeviceListTableViewCell.h"
#import "AUXCenterControlTableViewCell.h"
#import "AUXSceneCommonModel.h"
#import "AUXUser.h"
#import "AUXSceneDetailModel.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "AUXSceneCenterControlSelectViewController.h"
#import "AUXDeviceStateInfo.h"
#import "UIColor+AUXCustom.h"


@interface AUXSceneExecuteDeviceViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property (nonatomic, strong) NSMutableArray<AUXDeviceInfo *> *deviceInfoArray;
@property (nonatomic, strong) NSMutableArray<AUXDeviceInfo *> *dataArray;
@property (nonatomic, strong) NSDictionary<NSString *, AUXACDevice *> *deviceDictionary;

@end

@implementation AUXSceneExecuteDeviceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableview registerNib:[UINib nibWithNibName:@"AUXSceneSelectDeviceListTableViewCell" bundle:nil] forCellReuseIdentifier:@"AUXSceneSelectDeviceListTableViewCell"];
    self.tableview.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    self.tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.customBackAtcion = YES;
}

- (void)backAtcion{
    if (self.backBlock) {
        self.backBlock(self.dataArray.mutableCopy);
    }
    [self.navigationController popViewControllerAnimated:YES];

}


- (NSMutableArray<AUXDeviceInfo *> *)dataArray {
    if (!_dataArray) {
        self.dataArray = [[NSMutableArray alloc]init];
    }
    return _dataArray;
}



#pragma mark 获取数据
- (NSMutableArray<AUXDeviceInfo *> *)deviceInfoArray
{
    _deviceInfoArray = [[AUXUser defaultUser].deviceInfoArray mutableCopy];
    return _deviceInfoArray;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    [self.dataArray removeAllObjects];
    AUXSceneCommonModel *commonModel = [AUXSceneCommonModel shareAUXSceneCommonModel];
    NSMutableArray *tmpArray = commonModel.deviceActionDtoList.mutableCopy;
    for (AUXSceneDeviceModel *model in tmpArray) {
        
        for (AUXDeviceInfo *info in self.deviceInfoArray) {
            if ([info.deviceId isEqualToString:model.deviceId]) {
                [self.dataArray addObject:info];
            }
        }
    }
    [self.tableview reloadData];
}

#pragma mark  tableview 每个cell显示什么内容
- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    AUXDeviceInfo *info = self.dataArray[indexPath.row];
    AUXSceneSelectDeviceListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AUXSceneSelectDeviceListTableViewCell" forIndexPath:indexPath];
    cell.IconImageview.image = [UIImage imageNamed:@"scene_icon_device_initial"];
    [cell.IconImageview sd_setImageWithURL: [NSURL URLWithString:info.deviceMainUri] placeholderImage:nil];
    cell.nameLabel.text = info.alias;
    
    
    AUXDeviceStateInfo *deviceStateinfo = [AUXDeviceStateInfo shareAUXDeviceStateInfo];
    BOOL iscontain = [deviceStateinfo.dataArray containsObject:info.deviceId];
    if (iscontain) {
        cell.lineStateLabel.text = @"";
        cell.lineStateImageview.hidden = YES;
    }else{
        cell.lineStateLabel.text = @"(离线)";
        cell.lineStateImageview.hidden = NO;
    }
    
    
    if (indexPath.row == self.dataArray.count-1) {
        cell.underLinView.hidden = YES;
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
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 12;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *vie = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 12)];
    vie.backgroundColor = [UIColor colorWithHexString:@"F7F7F7"];
    return vie;
}

- (IBAction)editItemAction:(id)sender {
    AUXSceneCenterControlSelectViewController *sceneCenterControlSelectViewController = [AUXSceneCenterControlSelectViewController instantiateFromStoryboard:kAUXStoryboardNameScene];
    sceneCenterControlSelectViewController.tmpDict = self.tmpDict;
    sceneCenterControlSelectViewController.isEdicenterol = YES;
    [self.navigationController pushViewController:sceneCenterControlSelectViewController animated:YES];
}

#pragma mark getter
- (NSDictionary<NSString *, AUXACDevice *> *)deviceDictionary {
    return [AUXUser defaultUser].deviceDictionary;
}
@end


