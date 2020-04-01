//
//  AUXDeviceControlFunctionListTableViewCell.m
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2019/3/30.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXDeviceControlFunctionListTableViewCell.h"
#import "AUXFunctoinListCell.h"
#import "AUXConstant.h"

@interface AUXDeviceControlFunctionListTableViewCell ()<UICollectionViewDelegate , UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet UIView *backView;
@property (nonatomic,strong) NSNumber *windSpeed;
@property (nonatomic,strong) NSNumber *mode;
@property (nonatomic, strong) NSLayoutConstraint *onCollectionViewLeading;

@end

@implementation AUXDeviceControlFunctionListTableViewCell

+ (CGFloat)heightForFunctionItem {
    return 50.0;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windSpeedSelectedNotification:) name:AUXDeviceSlectedWindSpeedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(modeSelectedNotification:) name:AUXDeviceSlectedAirConModeNotification object:nil];
    
    [self createOnCollectionView];
    [self createOffCollectionView];
    
}

- (void)createOnCollectionView {
    self.onCollectionView = [self createCollectionViewWithLastCollectionView:self.onCollectionView];
    
    [self addOnCollectionViewConstraints];
    
    if (self.offCollectionView) {
        // 重新创建了 onCollectionView 之后，为 offCollectionView 重新添加约束
        // 因为 offCollectionView 的所有约束都是相对于 onCollectionView 添加的
        [self addOffCollectionViewConstraints];
    }
}

- (void)createOffCollectionView {
    self.offCollectionView = [self createCollectionViewWithLastCollectionView:self.offCollectionView];
    
    [self addOffCollectionViewConstraints];
}

/// 创建 collectionView
- (UICollectionView *)createCollectionViewWithLastCollectionView:(UICollectionView *)lastCollectionView {
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:self.backView.frame collectionViewLayout:flowLayout];
    [self configureCollectionView:collectionView];
    [self.backView addSubview:collectionView];
    [collectionView reloadData];
    
    if (lastCollectionView) {
        [lastCollectionView removeFromSuperview];
    }
    
    return collectionView;
}

/// 配置 collectionView
- (void)configureCollectionView:(UICollectionView *)collectionView {
    collectionView.backgroundColor = [UIColor clearColor];
    collectionView.scrollEnabled = NO;
    collectionView.bounces = NO;
    collectionView.showsVerticalScrollIndicator = NO;
    collectionView.delegate = self;
    collectionView.dataSource = self;
    collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    [collectionView registerNib:[UINib nibWithNibName:@"AUXFunctoinListCell" bundle:nil] forCellWithReuseIdentifier:@"AUXFunctoinListCell"];
    
    CGFloat padding = 10;
    CGFloat marign = 28;
    CGFloat itemWidth = (kAUXScreenWidth - 2 * marign - 3 * padding) / 4;
    
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)collectionView.collectionViewLayout;
    flowLayout.sectionInset = UIEdgeInsetsMake(0, marign, 0, marign);
    flowLayout.itemSize = CGSizeMake(itemWidth, 50);
    flowLayout.minimumLineSpacing = 42;
    flowLayout.minimumInteritemSpacing = padding;
}

/// 添加 onCollectionView 的约束
- (void)addOnCollectionViewConstraints {
    NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:self.onCollectionView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.backView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
    NSLayoutConstraint *leading = [NSLayoutConstraint constraintWithItem:self.onCollectionView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.backView attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0];
    NSLayoutConstraint *width = [NSLayoutConstraint constraintWithItem:self.onCollectionView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.backView attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0];
    NSLayoutConstraint *bottom = [NSLayoutConstraint constraintWithItem:self.onCollectionView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.backView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
    [self.backView addConstraints:@[top, leading, width, bottom]];
    
    self.onCollectionViewLeading = leading;
}

/// 添加 offCollectionView 的约束
- (void)addOffCollectionViewConstraints {
    NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:self.offCollectionView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.backView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
    NSLayoutConstraint *trailing = [NSLayoutConstraint constraintWithItem:self.offCollectionView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.onCollectionView attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0];
    NSLayoutConstraint *width = [NSLayoutConstraint constraintWithItem:self.offCollectionView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.onCollectionView attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0];
    NSLayoutConstraint *bottom = [NSLayoutConstraint constraintWithItem:self.offCollectionView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.onCollectionView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
    [self.backView addConstraints:@[top, trailing, width, bottom]];
}

- (NSString *)getCurrentWindImage:(WindSpeed)wind {
    
    NSString *imageString;
    switch (wind) {
        case WindSpeedSilence:
            imageString = @"device_btn_fan1";
            break;
        case WindSpeedMin:
            imageString = @"device_btn_fan2";
            break;
        case WindSpeedMidMin:
            imageString = @"device_btn_fan3";
            break;
        case WindSpeedMid:
            imageString = @"device_btn_fan4";
            break;
        case WindSpeedMidMax:
            imageString = @"device_btn_fan5";
            break;
        case WindSpeedMax:
            imageString = @"device_btn_fan6";
            break;
        case WindSpeedTurbo:
            imageString = @"device_btn_fan7";
            break;
        case WindSpeedAuto:
            imageString = @"device_btn_fan8";
            break;
            
        default:
            break;
    }
    
    return imageString;
}

- (NSString *)getCurrentModeImage:(AirConFunction)mode {
    
    NSString *imageString;
    switch (mode) {
        case AirConFunctionCool:
            imageString = @"device_btn_cold";
            break;
        case AirConFunctionHeat:
            imageString = @"device_btn_hot";
            break;
        case AirConFunctionDehumidify:
            imageString = @"device_btn_dry";
            break;
        case AirConFunctionVentilate:
            imageString = @"device_btn_wind";
            break;
        case AirConFunctionAuto:
            imageString = @"device_btn_auto";
            break;
            
        default:
            break;
    }
    return imageString;
}

#pragma mark 通知监听方法
- (void)windSpeedSelectedNotification:(NSNotification *)notication {
    NSNumber *windSpeed = notication.userInfo[AUXDeviceSlectedWindSpeedNotification];
    self.windSpeed = windSpeed;
    self.deviceStatus.mode = self.mode.integerValue;
    self.deviceStatus.convenientWindSpeed = self.windSpeed.integerValue;
    
    [self reloadData];
}

- (void)modeSelectedNotification:(NSNotification *)notication {
    
    NSNumber *mode = notication.userInfo[AUXDeviceSlectedAirConModeNotification];
    self.mode = mode;
    self.deviceStatus.mode = self.mode.integerValue;
    self.deviceStatus.convenientWindSpeed = self.windSpeed.integerValue;
    
    [self reloadData];
}

#pragma mark - Setters
- (void)setOnFunctionList:(NSArray<AUXDeviceFunctionItem *> *)onFunctionList {
    _onFunctionList = onFunctionList;
    [self.onCollectionView reloadData];
}

- (void)setOffFunctionList:(NSArray<AUXDeviceFunctionItem *> *)offFunctionList {
    _offFunctionList = offFunctionList;
    [self.offCollectionView reloadData];
}

- (void)setDeviceStatus:(AUXDeviceStatus *)deviceStatus {
    _deviceStatus = deviceStatus;
    if (_deviceStatus) {
        if (_deviceStatus.powerOn) {
            [self showOnFunctionListAnimated:NO];
        } else {
            [self showOffFunctionListAnimated:NO];
        }
        self.mode = @(_deviceStatus.mode);
        self.windSpeed = @(_deviceStatus.convenientWindSpeed);
        
        [self reloadData];
    }
}

#pragma mark - 设备开机/关机列表切换

- (void)showOnFunctionListAnimated:(BOOL)animated {
    
    if (self.onCollectionViewLeading.constant == 0) {
        return;
    }
    
    [self.contentView layoutIfNeeded];
    self.onCollectionViewLeading.constant = 0;
    
    NSTimeInterval duration = animated ? 0.5 : 0;
    
    [UIView animateWithDuration:duration animations:^{
        [self.contentView layoutIfNeeded];
    }];
}

- (void)showOffFunctionListAnimated:(BOOL)animated {
    
    if (self.onCollectionViewLeading.constant != 0) {
        return;
    }
    
    CGFloat width = CGRectGetWidth(self.contentView.frame);
    
    NSTimeInterval duration = animated ? 0.5 : 0;
    
    [self.contentView layoutIfNeeded];
    self.onCollectionViewLeading.constant = width;
    [UIView animateWithDuration:duration animations:^{
        [self.contentView layoutIfNeeded];
    }];
}

#pragma mark - 界面更新方法

- (void)reloadData {
    [self.onCollectionView reloadData];
    [self.offCollectionView reloadData];
}

#pragma mark - UICollectionViewDelegate, UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    if ([collectionView isEqual:self.onCollectionView]) {
        return [self.onFunctionList count];
    }
    
    return [self.offFunctionList count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    AUXFunctoinListCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AUXFunctoinListCell" forIndexPath:indexPath];
    
    AUXDeviceFunctionItem *item;
    
    if ([collectionView isEqual:self.onCollectionView]) {
        item = self.onFunctionList[indexPath.row];
    } else {
        item = self.offFunctionList[indexPath.row];
    }
    
    if ([item.title isEqualToString:@"模式"] || [item.title isEqualToString:@"风速"]) {
        cell.deviceIconListImageView.hidden = NO;
    } else {
        cell.deviceIconListImageView.hidden = YES;
    }
    
    if (item.type == AUXDeviceFunctionTypeWindSpeed) {
        item.imageNor = [self getCurrentWindImage:self.deviceStatus.convenientWindSpeed];
    }
    
    if (item.type == AUXDeviceFunctionTypeMode) {
        item.imageNor = [self getCurrentModeImage:self.deviceStatus.mode];
    }
    
    if (item.type == AUXDeviceFunctionTypeDisplay) {
        item.title = self.deviceStatus.screenOnOff ? @"屏显" : @"屏显";
        
        if (self.deviceStatus.autoScreen) {
            item.title = @"屏显";
            item.imageSel = @"device_btn_display_auto";
        } else {
            item.imageSel = @"device_btn_display_selected";
        }
    }
    
    [cell updateCellWithItem:item];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    AUXDeviceFunctionItem *item;
    if ([collectionView isEqual:self.onCollectionView]) {
        item = self.onFunctionList[indexPath.row];
    } else {
        item = self.offFunctionList[indexPath.row];
    }
    
//    if (item.disabled) {
//        return ;
//    }
    
    if ([collectionView isEqual:self.onCollectionView]) {
        
        item = self.onFunctionList[indexPath.row];
        
        if (self.didSelectOnItemBlock) {
            self.didSelectOnItemBlock(indexPath.item);
        }
    } else {
        if (self.didSelectOffItemBlock) {
            self.didSelectOffItemBlock(indexPath.item);
        }
    }
}

@end
