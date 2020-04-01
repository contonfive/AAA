//
//  AUXDeviceControlStatusTableViewCell.m
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2019/3/29.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXDeviceControlStatusTableViewCell.h"
#import "AUXDeviceControlStatusIconCell.h"
#import "AUXConfiguration.h"

@interface AUXDeviceControlStatusTableViewCell ()<UICollectionViewDelegate , UICollectionViewDataSource>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *collectionViewWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *collectionViewHeight;

/// 设备正在开启的功能列表
@property (nonatomic, strong) NSMutableArray<AUXDeviceFunctionItem *> *functionList;
@property (nonatomic,strong) NSMutableArray<NSNumber *> *enableFuncList;
@end

@implementation AUXDeviceControlStatusTableViewCell

+ (CGFloat)properHeight {
    return 115;
}

+ (NSDictionary *)statusInfoDictionary {

    return @{@(AUXDeviceFunctionTypeECO): @{@"title": @"ECO", @"imageNor": @"device_icon_eco"},
             @(AUXDeviceFunctionTypeSleep): @{@"title": @"睡眠", @"imageNor": @"device_icon_sleep"},
             @(AUXDeviceFunctionTypeSwingUpDown): @{@"title": @"上下", @"imageNor": @"device_icon_updown"},
             @(AUXDeviceFunctionTypeSwingLeftRight): @{@"title": @"左右", @"imageNor": @"device_icon_leftright"},
             @(AUXDeviceFunctionTypeElectricalHeating): @{@"title": @"电加热", @"imageNor": @"device_icon_heat"},
             @(AUXDeviceFunctionTypeHealth): @{@"title": @"健康", @"imageNor": @"device_icon_health"},
             @(AUXDeviceFunctionTypeComfortWind): @{@"title": @"舒风", @"imageNor": @"device_icon_comfortable"},
             @(AUXDeviceFunctionTypeMouldProof): @{@"title": @"防霉", @"imageNor": @"device_icon_fangmei"},
             @(AUXDeviceFunctionTypeClean): @{@"title": @"清洁", @"imageNor": @"device_icon_clean"}
             };
}

+ (AUXDeviceFunctionItem *)createItemWithType:(AUXDeviceFunctionType)type {
    
    NSDictionary *dict = [self statusInfoDictionary][@(type)];
    
    AUXDeviceFunctionItem *item = [AUXDeviceFunctionItem yy_modelWithDictionary:dict];
    
    return item;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"AUXDeviceControlStatusIconCell" bundle:nil] forCellWithReuseIdentifier:@"AUXDeviceControlStatusIconCell"];
    
    self.functionList = [NSMutableArray array];
    
}

- (void)setControlType:(AUXDeviceControlType)controlType {
    _controlType = controlType;
}

- (void)setDeviceFeature:(AUXDeviceFeature *)deviceFeature {
    _deviceFeature = deviceFeature;
    
    if (_deviceFeature) {
        NSMutableArray<NSNumber *> *enableFuncList = [NSMutableArray arrayWithArray:[self.deviceFeature convertToOnFunctionList]];
        [enableFuncList addObjectsFromArray:[self.deviceFeature convertToOffFunctionList]];
        self.enableFuncList = enableFuncList;
    }
}

- (void)setDeviceStatus:(AUXDeviceStatus *)deviceStatus {
    _deviceStatus = deviceStatus;
    
    if (_deviceStatus) {
        [self.functionList removeAllObjects];
        [self updateCollectionView];
    }
}

- (void)updateCollectionView {
    
    if (self.deviceStatus.powerOn) {
        
        AUXDeviceFunctionItem *modeItem = [[AUXDeviceFunctionItem alloc] init];
        modeItem.title = [AUXConfiguration getModeName:self.deviceStatus.mode];
        modeItem.imageNor = [AUXConfiguration getDeviceControlStatusModeIcon:self.deviceStatus.mode];
        [self.functionList addObject:modeItem];
        
        AUXDeviceFunctionItem *windSpeedItem = [[AUXDeviceFunctionItem alloc] init];
        if (self.deviceStatus.comfortWind) {
            windSpeedItem.title = [AUXConfiguration getWindSpeedName:WindSpeedAuto];
            windSpeedItem.imageNor = [AUXConfiguration getDeviceControlStatusWindSpeedIcon:WindSpeedAuto];
        } else {
            windSpeedItem.title = [AUXConfiguration getWindSpeedName:self.deviceStatus.convenientWindSpeed];
            windSpeedItem.imageNor = [AUXConfiguration getDeviceControlStatusWindSpeedIcon:self.deviceStatus.convenientWindSpeed];
        }
        [self.functionList addObject:windSpeedItem];
        
        if (self.deviceStatus.swingUpDown && !self.deviceStatus.comfortWind) {
            [self functionListAddDeviceFunctionType:AUXDeviceFunctionTypeSwingUpDown];
        }
        
        if (self.deviceStatus.swingLeftRight && !self.deviceStatus.comfortWind) {
            [self functionListAddDeviceFunctionType:AUXDeviceFunctionTypeSwingLeftRight];
        }
        
        if (self.deviceStatus.comfortWind) {
            [self functionListAddDeviceFunctionType:AUXDeviceFunctionTypeComfortWind];
        }
        
        if (self.deviceStatus.eco) {
            [self functionListAddDeviceFunctionType:AUXDeviceFunctionTypeECO];
        }
        
        if (self.deviceStatus.electricHeating) {
            [self functionListAddDeviceFunctionType:AUXDeviceFunctionTypeElectricalHeating];
        }
        
        if (self.deviceStatus.sleepMode) {
            [self functionListAddDeviceFunctionType:AUXDeviceFunctionTypeSleep];
        }
        
        if (self.deviceStatus.healthy) {
            [self functionListAddDeviceFunctionType:AUXDeviceFunctionTypeHealth];
        }
    } else {
        
        if (self.deviceStatus.antiFungus) {
            [self functionListAddDeviceFunctionType:AUXDeviceFunctionTypeMouldProof];
        }
        
        if (self.deviceStatus.clean) {
            [self functionListAddDeviceFunctionType:AUXDeviceFunctionTypeClean];
        }
    }
    
    if (self.controlType == AUXDeviceControlTypeSubdevice || self.controlType == AUXDeviceControlTypeGatewayMultiDevice) {
        [self.functionList removeObject:[[self class] createItemWithType:AUXDeviceFunctionTypeSwingLeftRight]];
        [self.functionList removeObject:[[self class] createItemWithType:AUXDeviceFunctionTypeSwingUpDown]];
    }
    
    NSInteger count = [self.functionList count];
    
    if (count > 0) {
        
        UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
        flowLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
        
        flowLayout.itemSize = CGSizeMake(63, 20);
        
        flowLayout.minimumInteritemSpacing = 10;
        flowLayout.minimumLineSpacing = 0;
        if (count > 4) {
            flowLayout.minimumLineSpacing = 8;
        }
        
        CGFloat width = (count - 1) * flowLayout.minimumInteritemSpacing + count * flowLayout.itemSize.width;
        self.collectionViewWidth.constant = width > kAUXScreenWidth - 80 ? kAUXScreenWidth - 80 : width;
        self.collectionViewHeight.constant = flowLayout.itemSize.height;
        
        if (count > 4) {
            self.collectionViewHeight.constant = flowLayout.itemSize.height * 2 + flowLayout.minimumLineSpacing;
        }
        
        [self layoutIfNeeded];
    }
    
    [self.collectionView reloadData];
}

- (void)functionListAddDeviceFunctionType:(AUXDeviceFunctionType)functionType {
    if ([self.enableFuncList containsObject:@(functionType)]) {
        [self.functionList addObject:[[self class] createItemWithType:functionType]];
    }
}

#pragma mark - UICollectionViewDelegate & UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.functionList count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    AUXDeviceControlStatusIconCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AUXDeviceControlStatusIconCell" forIndexPath:indexPath];
    
    AUXDeviceFunctionItem *item = self.functionList[indexPath.item];
    
    cell.imageView.image = [UIImage imageNamed:item.imageNor];
    cell.titleLabel.text = item.title;
    
    return cell;
}


@end
