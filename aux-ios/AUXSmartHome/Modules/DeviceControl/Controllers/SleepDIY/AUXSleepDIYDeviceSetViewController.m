//
//  AUXSleepDIYDeviceSetViewController.m
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2019/4/13.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXSleepDIYDeviceSetViewController.h"
#import "AUXSleepDIYListViewController.h"
#import "AUXSleepDIYSetViewController.h"
#import "AUXSleepDIYTimeViewController.h"

#import "AUXDeviceSetTableViewCell.h"
#import "AUXSubtitleTableViewCell.h"
#import "AUXSleepDIYCurveView.h"
#import "AUXSleepDIYAlertView.h"
#import "AUXSleepDIYPointAdjustView.h"
#import "AUXDeviceInfoAlertView.h"
#import "AUXModeAndSpeedView.h"
#import "AUXPeakVallyFooterView.h"
#import "AUXAlertCustomView.h"

#import "AUXSleepDIYEditTableView.h"
#import "UITableView+AUXCustom.h"
#import "UIColor+AUXCustom.h"
#import "NSString+AUXCustom.h"
#import "NSDate+AUXCustom.h"
#import "AUXConfiguration.h"
#import "AUXNetworkManager.h"

/// 将数组下标转换为时间
typedef NSInteger (^AUXIndexToHourBlock) (NSInteger index, NSInteger startHour);

@interface AUXSleepDIYDeviceSetViewController ()<UITableViewDelegate, UITableViewDataSource , AUXSleepDIYCurveViewDelegate>
@property (weak, nonatomic) IBOutlet AUXSleepDIYEditTableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIView *backView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewTop;

@property (nonatomic, assign) CGFloat curveCellOriginY;     // 曲线图cell的 origin.y
@property (nonatomic, weak) AUXSleepDIYCurveView *curveView;    // 睡眠DIY曲线
@property (nonatomic, weak) UILabel *windSpeedLabel;
@property (nonatomic, strong) AUXSleepDIYPointAdjustView *pointAdjustView;  // 睡眠DIY曲线每个节点风速、温度调节界面

@property (nonatomic, strong) NSMutableArray<AUXDeviceFunctionItem  *> *windSpeedArray;
@property (nonatomic,strong) NSMutableArray <NSNumber *>*windSpeedSupportArray;

@property (nonatomic, strong) UIBarButtonItem *moreButtonItem;
@property (nonatomic, strong) UIBarButtonItem *sureBarButtonItem;

@property (nonatomic,strong) AUXSleepDIYAlertView *alertView;

@property (nonatomic, copy) AUXSleepDIYModel *lastSleepDIYModel;
@end

@implementation AUXSleepDIYDeviceSetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    NSString *modeName = [AUXConfiguration getServerModeName:self.mode];
    self.title = [NSString stringWithFormat:@"%@睡眠DIY",  modeName];
    
    [self.tableView registerCellWithNibName:@"AUXSubtitleTableViewCell"];
    [self.tableView registerCellWithNibName:@"AUXDeviceSetTableViewCell"];
    
    if (!self.addSleepDIY) {
        self.navigationItem.rightBarButtonItem = self.moreButtonItem;
        
        self.backView.hidden = YES;
        self.tableViewTop.constant = 0;
        
        if (!AUXWhtherNullString(self.sleepDIYModel.name)) {
            self.title = self.sleepDIYModel.name;
        }
        
        [self.view layoutIfNeeded];
    } else {
        
        self.timeLabel.text = [self performPeroidTime];
        self.navigationItem.rightBarButtonItem = self.sureBarButtonItem;
    }
    
    CGFloat height = self.tableView.frame.origin.y;
    
    if (!self.addSleepDIY) {
        height = height + 60 + 74 + 20;
    } else {
        height -= 35;
    }
    
    self.curveCellOriginY = height;
    self.customBackAtcion = YES;
    
    [self updateSleepDIYPoints];
    
    self.lastSleepDIYModel = [self.sleepDIYModel copy];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
   
}


- (NSDictionary<NSNumber *,NSDictionary *> *)defaultServerWindsDictionary {
    
    return @{
             @(AUXServerWindSpeedMute): @{@"title": @"静音", @"type": @(AUXServerWindSpeedMute)},
             
             @(AUXServerWindSpeedLow): @{@"title": @"低风", @"type": @(AUXServerWindSpeedLow)},
             
             @(AUXServerWindSpeedMid): @{@"title": @"中风", @"type": @(AUXServerWindSpeedMid)},
             
             @(AUXServerWindSpeedHigh): @{@"title": @"高风", @"type": @(AUXServerWindSpeedHigh)},
             
             @(AUXServerWindSpeedTurbo): @{@"title": @"强力", @"type": @(AUXServerWindSpeedTurbo)}
             };
}

- (void)initSubviews {
    [super initSubviews];
    
    NSDictionary<NSNumber *, NSDictionary *> *totalWindsDict = [self defaultServerWindsDictionary];
    
    for (NSNumber *funcType in self.windSpeedSupportArray) {
        
        AUXDeviceFunctionItem *item = [[AUXDeviceFunctionItem alloc]init];
        
        NSDictionary *funcDict = totalWindsDict[funcType];
        item = [AUXDeviceFunctionItem yy_modelWithDictionary:funcDict];
        [self.windSpeedArray addObject:item];
    }
    
    self.pointAdjustView = [AUXSleepDIYPointAdjustView instantiateFromNib];
    self.pointAdjustView.windSpeedArray = self.windSpeedSupportArray;
}

- (void)reloadData {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

- (void)updatePointModelHour {
    // 旧设备没有开始时间，pointModel.hour 从当前时间为开始时间开始累加(比如当前时间是 三点半，那么当前时间是三点)
    AUXIndexToHourBlock indexToOldHour = ^ (NSInteger index, NSInteger startHour) {
        return (startHour + index) % 24;
    };
    
    // 新设备有开始时间，pointModel.hour 从开始时间开始累加
    AUXIndexToHourBlock indexToNewHour = ^ (NSInteger index, NSInteger startHour) {
        return (startHour + index) % 24;
    };
    
    AUXIndexToHourBlock indexToHour;
    
    NSInteger startHour = [NSDate nowhh].integerValue;
    
    if (self.oldDevice) {
        indexToHour = indexToOldHour;
    } else {
        indexToHour = indexToNewHour;
        startHour = self.sleepDIYModel.startHour;
    }
    
    [self.sleepDIYModel.pointModelList enumerateObjectsUsingBlock:^(AUXSleepDIYPointModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.hour = indexToHour(idx, startHour);
    }];
}

/// 更新设备睡眠曲线的节点个数
- (void)updateSleepDIYPoints {
    
    // 温度默认为26摄氏度
    CGFloat temperature = 26.0;
    // 如果当前风速为“自定义”，新增节点的风速为“低风”
    AUXServerWindSpeed windSpeed = self.sleepDIYModel.windSpeed == AUXServerWindSpeedCustom ? AUXServerWindSpeedLow : self.sleepDIYModel.windSpeed;
    
    NSMutableArray<AUXSleepDIYPointModel *> *pointArray;
    
    if (self.sleepDIYModel.pointModelList) {
        pointArray = [self.sleepDIYModel.pointModelList mutableCopy];
    } else {
        pointArray = [[NSMutableArray alloc] init];
    }
    
    // 修改了睡眠时间
    
    if (pointArray.count > self.sleepDIYModel.definiteTime) {
        // 移掉多出来的节点
        NSInteger location = self.sleepDIYModel.definiteTime;
        NSInteger length = pointArray.count - self.sleepDIYModel.definiteTime;
        [pointArray removeObjectsInRange:NSMakeRange(location, length)];
    } else if (pointArray.count < self.sleepDIYModel.definiteTime) {
        // 当前节点个数小于睡眠时间，增加缺少的节点。
        for (NSUInteger i = pointArray.count; i < self.sleepDIYModel.definiteTime; i++) {
            AUXSleepDIYPointModel *pointModel = [[AUXSleepDIYPointModel alloc] init];
            pointModel.temperature = temperature;
            pointModel.windSpeed = windSpeed;
            [pointArray addObject:pointModel];
        }
    }
    
    self.sleepDIYModel.pointModelList = pointArray;
    [self updatePointModelHour];
    [self reloadData];
}

- (BOOL)isModelAlreadyExisting:(AUXSleepDIYModel *)sleepDIYModel {
    
    for (AUXSleepDIYModel *existedModel in self.existedModelList) {
        if (sleepDIYModel.sleepDiyId && [sleepDIYModel.sleepDiyId isEqualToString:existedModel.sleepDiyId]) {
            continue;
        }
        
        if ([existedModel isEqualToSleepDIYModel:sleepDIYModel]) {
            return YES;
        }
    }
    
    return NO;
}

- (void)editStatus {
    self.navigationItem.rightBarButtonItem = self.sureBarButtonItem;
}

- (NSString *)performPeroidTime {
    NSString *timeStr;
    if (self.oldDevice) {
        
        timeStr = [NSString stringWithFormat:@"睡眠时间：睡眠DIY开启后的%ld个小时" , self.sleepDIYModel.definiteTime];
    } else {
        timeStr = [NSString stringWithFormat:@"睡眠时间：%@" , self.sleepDIYModel.timePeriod];
    }
    
    return timeStr;
}

#pragma mark getter
- (UIBarButtonItem *)moreButtonItem {
    if (!_moreButtonItem) {
        _moreButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"device_nav_btn_info"] style:UIBarButtonItemStylePlain target:self action:@selector(moreAtcion)];
    }
    
    return _moreButtonItem;
}

- (UIBarButtonItem *)sureBarButtonItem {
    if (!_sureBarButtonItem) {
        _sureBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(actionSaveSleepDIY)];
    }
    
    return _sureBarButtonItem;
}

- (NSMutableArray *)windSpeedSupportArray {
    if (!_windSpeedSupportArray) {
        
        NSArray<NSNumber *> *windSpeedArray = @[@(AUXServerWindSpeedMute) , @(AUXServerWindSpeedLow), @(AUXServerWindSpeedMid), @(AUXServerWindSpeedHigh), @(AUXServerWindSpeedTurbo)];
        _windSpeedSupportArray = [NSMutableArray arrayWithArray:windSpeedArray];
    }
    return _windSpeedSupportArray;
}

- (NSMutableArray<AUXDeviceFunctionItem *> *)windSpeedArray {
    if (!_windSpeedArray) {
        _windSpeedArray = [NSMutableArray array];
    }
    return _windSpeedArray;
}

#pragma mark atcion

- (void)actionSaveSleepDIY {
    
    if (self.deviceInfo.virtualDevice) {
        [self showFailure:kAUXLocalizedString(@"VirtualAletMessage")];
        return ;
    }
    
    [self eidtSleepDIY];
}

- (void)moreAtcion {
    AUXSleepDIYSetViewController *sleepDIYSetVC = [AUXSleepDIYSetViewController instantiateFromStoryboard:kAUXStoryboardNameDeviceControl];
    sleepDIYSetVC.mode = self.mode;
    sleepDIYSetVC.addSleepDIY = self.addSleepDIY;
    sleepDIYSetVC.deviceInfo = self.deviceInfo;
    sleepDIYSetVC.sleepDIYModel = self.sleepDIYModel;
    sleepDIYSetVC.existedModelList = self.existedModelList;
    sleepDIYSetVC.controlType = self.controlType;
    
    sleepDIYSetVC.updateSleepDIYNameBlock = ^(NSString * _Nonnull name) {
        if (!AUXWhtherNullString(name)) {
            self.navigationItem.title = name;
        }
    };
    
    [self.navigationController pushViewController:sleepDIYSetVC animated:YES];
}

- (void)backAtcion {
    [super backAtcion];
    
    if (![self.sleepDIYModel isEqualToSleepDIYModel:self.lastSleepDIYModel]) {
        [AUXAlertCustomView alertViewWithMessage:@"是否放弃更改?" confirmAtcion:^{
            [self.navigationController popViewControllerAnimated:YES];
        } cancleAtcion:^{
            
        }];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}

- (void)eidtSleepDIY {
    
    if (!self.addSleepDIY) {
        [self updateSleepDIYByServer];
    } else {
        AUXDeviceInfoAlertView *alertView = [AUXDeviceInfoAlertView alertViewWithNameType:AUXNamingTypeSleepDIY deviceInfo:self.deviceInfo device:nil address:nil content:self.sleepDIYModel.name confirm:^(NSString *name) {
            [self checkSleepData:name];
            
        } close:^{
            
        }];
        alertView.currentVC = self;
    }
    
}

- (void)checkSleepData:(NSString *)name {
    if (self.controlType == AUXDeviceControlTypeVirtual) {
        return ;
    }
    
    if (!self.deviceInfo) {
        return;
    }
    
    if (!AUXWhtherNullString(name)) {
        if ([name length] == 0) {
            [self showErrorViewWithMessage:@"名称不能为空"];
            return;
        }
        self.sleepDIYModel.name = name;
    }
    
    if (self.sleepDIYModel.smart) {
        for (NSInteger index = 0; index < self.sleepDIYModel.pointModelList.count - 1; index++) {
            AUXSleepDIYPointModel *pointModel = self.sleepDIYModel.pointModelList[index];
            AUXSleepDIYPointModel *nextPointModel = self.sleepDIYModel.pointModelList[index + 1];
            if (pointModel.temperature - nextPointModel.temperature > 2 || nextPointModel.temperature - pointModel.temperature > 2) {
                [self showErrorViewWithMessage:@"相邻控制点温度差需控制在2°C以内"];
                return ;
            }
        }
    }
    
    // 旧设备，限制不能添加两条相似的睡眠DIY
    if (self.oldDevice && [self isModelAlreadyExisting:self.sleepDIYModel]) {
        [self showErrorViewWithMessage:@"当前睡眠曲线已存在"];
        return;
    }
    
    
    if (self.addSleepDIY) {
        [self addSleepDIYByServer];
    }
}

#pragma mark 网络请求
- (void)addSleepDIYByServer {
    
    self.sleepDIYModel.deviceId = self.deviceInfo.deviceId;
    [[AUXNetworkManager manager] addSleepDIYWithModel:self.sleepDIYModel completion:^(NSString * _Nullable sleepDiyId, NSError * _Nonnull error) {
        [self hideLoadingHUD];
        switch (error.code) {
            case AUXNetworkErrorNone: {
                self.sleepDIYModel.sleepDiyId = sleepDiyId;
                
                @weakify(self);
                [self showSuccess:@"添加成功" completion:^{
                    @strongify(self);
                    for (AUXBaseViewController *vc in self.navigationController.viewControllers) {
                        if ([vc isKindOfClass:[AUXSleepDIYListViewController class]]) {
                            [self.navigationController popToViewController:vc animated:YES];
                            return ;
                        }
                    }
                }];
            }
                break;
                
            case AUXNetworkErrorAccountCacheExpired:
                
                [self alertAccountCacheExpiredMessage];
                break;
                
            default:
                
                [self showErrorViewWithError:error defaultMessage:@"保存失败"];
                break;
        }
    }];
}

- (void)updateSleepDIYByServer {
    
    self.sleepDIYModel.deviceId = self.deviceInfo.deviceId;
    [[AUXNetworkManager manager] updateSleepDIYWithModel:self.sleepDIYModel completion:^(NSError * _Nonnull error) {
        [self hideLoadingHUD];
        switch (error.code) {
            case AUXNetworkErrorNone: {
                @weakify(self);
                [self showSuccess:@"修改成功" completion:^{
                    @strongify(self);
                    [self.navigationController popViewControllerAnimated:YES];
                }];
            }
                break;
                
            case AUXNetworkErrorAccountCacheExpired:
                
                [self alertAccountCacheExpiredMessage];
                break;
                
            default:
                
                [self showErrorViewWithError:error defaultMessage:@"修改失败"];
                break;
        }
    }];
}

#pragma mark 私有方法
/// 在 pointAdjustView 上选择了风速
- (void)didChangeWindSpeedOfPoint:(AUXSleepDIYPointModel *)pointModel windSpeed:(AUXServerWindSpeed)windSpeed {
    self.sleepDIYModel.windSpeed = AUXServerWindSpeedCustom;
    
    if (self.windSpeedLabel) {
        self.windSpeedLabel.text = [AUXConfiguration getServerWindSpeedName:self.sleepDIYModel.windSpeed];
    }
}

/// 隐藏 pointAdjustView
- (void)hidePointAdjustView {
    if (self.pointAdjustView.superview) {
        [UIView animateWithDuration:0.25 animations:^{
            self.pointAdjustView.alpha = 0;
        } completion:^(BOOL finished) {
            self.pointAdjustView.alpha = 1;
            [self.pointAdjustView removeFromSuperview];
        }];
    }
    
    self.pointAdjustView.temperatureChangedBlock = nil;
    self.pointAdjustView.windSpeedChangedBlock = nil;
}

- (void)actionTapTableView {
    
    // 隐藏 pointAdjustView
    [self hidePointAdjustView];
    
    self.tableView.scrollEnabled = YES;
    
    [self.curveView cancelHighlightedState];
}

#pragma mark - UITableViewDelegate & UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    if (!self.addSleepDIY) {
        return 2;
    } else {
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (!self.addSleepDIY) {
        if (section == 1) {
            return 2;
        } else {
            return 1;
        }
    }
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 12;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    
    if (!self.addSleepDIY && section == 0) {
        return 0.5;
    }
    
    return 45;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height;
    
    if (!self.addSleepDIY) {
        if (indexPath.section == 0) {
            height = 60;
        } else {
            if (indexPath.row == 0) {
                height = 74;
            } else {
                height = 330;
            }
        }
    } else {
        if (indexPath.row == 0) {
            height = 74;
        } else {
            height = 330;
        }
    }
    return height;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc]init];
    headerView.backgroundColor = [UIColor clearColor];
    
    return headerView;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    
    if (!self.addSleepDIY && section == 0) {
        return nil;
    }
    
    AUXPeakVallyFooterView *footerView = [[[NSBundle mainBundle] loadNibNamed:@"AUXPeakVallyFooterView" owner:nil options:nil] firstObject];
    footerView.contentLabel.text = @"按住圆点并上下拖动，即可调节温度";
    return footerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    
    if (!self.addSleepDIY) {
        if (indexPath.section == 0) {
            cell = [self tableView:tableView timeCellForRowAtIndexPath:indexPath];
        } else {
            switch (indexPath.row) {
                case 0:
                    cell = [self tableView:tableView deviceSetCellForRowAtIndexPath:indexPath];
                    break;
                case 1:
                    cell = [self tableView:tableView curveCellForRowAtIndexPath:indexPath];
                    break;
                default:
                    break;
            }
        }
    } else {
        switch (indexPath.row) {
            case 0:
                cell = [self tableView:tableView deviceSetCellForRowAtIndexPath:indexPath];
                break;
            case 1:
                cell = [self tableView:tableView curveCellForRowAtIndexPath:indexPath];
                break;
                
            default:
                break;
        }
    }
    
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView timeCellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AUXSubtitleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AUXSubtitleTableViewCell" forIndexPath:indexPath];
    
    cell.titleLabel.text = @"睡眠时间";
    cell.indicatorImageView.hidden = NO;
    
    cell.subtitleLabel.text = [self performPeroidTime];
    
    if (self.oldDevice) {
        cell.subtitleLabel.text = [NSString stringWithFormat:@"睡眠DIY开启后的%ld个小时" , (long)self.sleepDIYModel.definiteTime];
    }
    
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView deviceSetCellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    AUXDeviceSetTableViewCell *setCell = [tableView dequeueReusableCellWithIdentifier:@"AUXDeviceSetTableViewCell" forIndexPath:indexPath];
    
    setCell.windLabel.text = [AUXConfiguration getServerWindSpeedName:self.sleepDIYModel.windSpeed];
    self.windSpeedLabel = setCell.windLabel;
    setCell.smartBtn.selected = self.sleepDIYModel.smart;
    
    @weakify(setCell , self);
    setCell.windBlock = ^{
        
        for (AUXDeviceFunctionItem *item in self.windSpeedArray) {
            if ((NSInteger)item.type == self.sleepDIYModel.windSpeed) {
                item.selected = YES;
            } else {
                item.selected = NO;
            }
        }
        
        [AUXModeAndSpeedView alertViewWithNameData:self.windSpeedArray confirm:^(NSInteger index) {
            @strongify(setCell , self);
            for (AUXDeviceFunctionItem *obj in self.windSpeedArray) {
                obj.selected = NO;
            }
            
            AUXDeviceFunctionItem *functionItem = self.windSpeedArray[index];
            functionItem.selected = YES;
            self.sleepDIYModel.windSpeed = (NSInteger)functionItem.type;
            setCell.windLabel.text = [AUXConfiguration getWindSpeedName:(NSInteger)functionItem.type];
            
            if (![setCell.windLabel.text isEqualToString:@"自定义"]) {
                for (AUXACSleepDIYPoint *pointmodel in self.sleepDIYModel.pointModelList) {
                    pointmodel.windSpeed = (NSInteger)functionItem.type;
                }
            }
            
            [self editStatus];
            [self reloadData];
        } close:^{
            
        }];
    };
    setCell.smartBlock = ^(BOOL on) {
        self.sleepDIYModel.smart = on;
        [self actionTapTableView];
        
        [self editStatus];
        [self reloadData];
    };
    
    setCell.helpBlock = ^{
        @strongify(setCell , self);
        
        if (self.alertView) {
            return ;
        }
        
        AUXSleepDIYAlertView *alertView = [[[NSBundle mainBundle] loadNibNamed:@"AUXCustomAlertView" owner:nil options:nil] objectAtIndex:7];
        
        self.alertView = alertView;
        if (self.pointAdjustView.superview) {
            [self.tableView insertSubview:alertView belowSubview:self.pointAdjustView];
        } else {
            [self.tableView addSubview:alertView];
        }
    
        CGRect rect = [setCell convertRect:setCell.smartTitleLabel.frame toView:tableView];
        CGFloat contentLabelHeight = [alertView.alertContentLabel.text getStringHeightWithText:alertView.alertContentLabel.text font:[UIFont systemFontOfSize:12] viewWidth:alertView.backImageView.frame.size.width - 34];
        
        CGFloat width = alertView.backImageView.frame.size.width + 8;
        CGFloat height = alertView.backImageView.frame.size.height;
        if (contentLabelHeight + 20 > height) {
            height = contentLabelHeight + 20;
        }
        alertView.frame = CGRectMake(kAUXScreenWidth - width, rect.origin.y + setCell.smartTitleLabel.frame.size.height, width, height);
        
        UIImage *backImage = [alertView.backImageView.image resizableImageWithCapInsets:UIEdgeInsetsMake(20, 20, alertView.backImageView.frame.size.height - 10, alertView.backImageView.frame.size.width - 20) resizingMode:UIImageResizingModeStretch];
        alertView.backImageView.image = backImage;
        
        @weakify(self);
        alertView.closeBlock = ^{
            @strongify(self);
            self.alertView = nil;
        };
    };
    
    [setCell.sleepDiyHelpBtn sendActionsForControlEvents:UIControlEventTouchUpInside];
    
    setCell.bottomView.hidden = YES;
    
    return setCell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView curveCellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"adjustCell"];
    
    AUXSleepDIYCurveView *curveView;
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"adjustCell"];
        cell.contentView.backgroundColor = [UIColor whiteColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        CGFloat width = CGRectGetWidth(self.view.frame);
        CGFloat height = 330;
        
        curveView = [[AUXSleepDIYCurveView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
        curveView.delegate = self;
        curveView.tag = 100;
        [cell.contentView addSubview:curveView];
        
        self.curveView = curveView;
        self.tableView.curveViewCell = cell;
    } else {
        curveView = (AUXSleepDIYCurveView *)[cell.contentView viewWithTag:100];
    }
    
    curveView.pointArray = self.sleepDIYModel.pointModelList;
    curveView.smart = self.sleepDIYModel.smart;
    [curveView updateCurve];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    
    if (self.deviceInfo.virtualDevice) {
        return ;
    }
    
    if (!self.addSleepDIY && indexPath.section == 0 && indexPath.row == 0) {
        
        [self actionTapTableView];
        
        AUXSleepDIYTimeViewController *sleepDIYTimeViewController = [AUXSleepDIYTimeViewController instantiateFromStoryboard:kAUXStoryboardNameDeviceControl];
        sleepDIYTimeViewController.mode = self.mode;
        sleepDIYTimeViewController.addSleepDIY = self.addSleepDIY;
        sleepDIYTimeViewController.deviceInfo = self.deviceInfo;
        sleepDIYTimeViewController.sleepDIYModel = self.sleepDIYModel;
        sleepDIYTimeViewController.existedModelList = self.existedModelList;
        sleepDIYTimeViewController.controlType = self.controlType;
        
        sleepDIYTimeViewController.editSuccessBlock = ^(AUXSleepDIYModel * _Nonnull sleepDIYModel) {
            
            self.sleepDIYModel = sleepDIYModel;
            [self editStatus];
            [self updateSleepDIYPoints];
            
            [self reloadData];
        };
        
        [self.navigationController pushViewController:sleepDIYTimeViewController animated:YES];
    }
    
}

#pragma mark - AUXSleepDIYCurveViewDelegate

- (void)sleepDIYCurveView:(AUXSleepDIYCurveView *)curveView willBeginDragging:(CGPoint)point pointModel:(AUXSleepDIYPointModel *)pointModel {
    self.tableView.scrollEnabled = NO;
}

- (void)sleepDIYCurveView:(AUXSleepDIYCurveView *)curveView dragging:(CGPoint)point yOffset:(CGFloat)yOffset pointModel:(AUXSleepDIYPointModel *)pointModel {
    self.tableView.scrollEnabled = NO;
    
    if (self.pointAdjustView.superview) {
        self.pointAdjustView.frame = CGRectOffset(self.pointAdjustView.frame, 0, yOffset);
        
        if (self.pointAdjustView.temperature != pointModel.temperature) {
            self.pointAdjustView.temperature = pointModel.temperature;
        }
        
        if (self.pointAdjustView.windSpeed != pointModel.windSpeed) {
            self.pointAdjustView.windSpeed = pointModel.windSpeed;
        }
    }
}

- (void)sleepDIYCurveView:(AUXSleepDIYCurveView *)curveView didEndDragging:(CGPoint)point pointModel:(AUXSleepDIYPointModel *)pointModel {
    self.tableView.scrollEnabled = YES;
    
    [self editStatus];
}

- (void)sleepDIYCurveView:(AUXSleepDIYCurveView *)curveView didTap:(CGPoint)point pointModel:(AUXSleepDIYPointModel *)pointModel {
    // 点击在有效范围内，显示当前选中节点的温度、风速调节界面
    if (pointModel) {
        CGFloat width = CGRectGetWidth(self.pointAdjustView.frame);
        CGFloat height = CGRectGetHeight(self.pointAdjustView.frame);
        
        CGPoint origin = CGPointMake(point.x - width / 2.0 , point.y - 27 - height + self.curveCellOriginY);
        // 如果 pointAdjustView 将要超出屏幕范围，则调整其位置以在屏幕之内
        // 相对应的，也要调整下三角指示器的位置 (下三角指示器默认显示在 pointAdjustView 底部中间)
        if (origin.x < 5) {
            origin.x = 5;
            
        } else if (origin.x + width + 5 > CGRectGetWidth(self.view.frame)) {
            CGFloat xOffset = origin.x + width + 5 - CGRectGetWidth(self.view.frame);
            origin.x -= xOffset;

        }
        
        CGRect frame = CGRectMake(origin.x, origin.y, width, height);
        
        // 显示并移动 pointAdjustView
        if (!self.pointAdjustView.superview) {
            
            if (self.alertView) {
                [self.tableView insertSubview:self.pointAdjustView aboveSubview:self.alertView];
            } else {
                [self.tableView addSubview:self.pointAdjustView];
            }
            
            self.pointAdjustView.frame = frame;
            
            self.pointAdjustView.alpha = 0;
            [UIView animateWithDuration:0.25 animations:^{
                self.pointAdjustView.alpha = 1;
            }];
        } else {
            [UIView animateWithDuration:0.25 animations:^{
                self.pointAdjustView.frame = frame;
            }];
        }
        
        if (self.pointAdjustView.temperature != pointModel.temperature) {
            self.pointAdjustView.temperature = pointModel.temperature;
        }
        
        if (self.pointAdjustView.windSpeed != pointModel.windSpeed) {
            self.pointAdjustView.windSpeed = pointModel.windSpeed;
        }
        
        @weakify(self);
        // 在 pointAdjustView 上调节了温度
        self.pointAdjustView.temperatureChangedBlock = ^(CGFloat temperature) {
            @strongify(self);
            pointModel.temperature = temperature;
            [curveView updateCurveAtPointModel:pointModel];
            
            self.navigationItem.rightBarButtonItem = self.sureBarButtonItem;
        };
        
        // 在 pointAdjustView 上调节了风速
        self.pointAdjustView.windSpeedChangedBlock = ^(AUXServerWindSpeed windSpeed) {
            @strongify(self);
            pointModel.windSpeed = windSpeed;
            [self didChangeWindSpeedOfPoint:pointModel windSpeed:windSpeed];
            self.navigationItem.rightBarButtonItem = self.sureBarButtonItem;
        };
    } else {
        // 隐藏 pointAdjustView
        [self hidePointAdjustView];
        
        self.tableView.scrollEnabled = YES;
    }
}

@end
