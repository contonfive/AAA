/*
 * =============================================================================
 *
 * AUX Group Confidential
 *
 * OCO Source Materials
 *
 * (C) Copyright AUX Group Co., Ltd. 2017 All Rights Reserved.
 *
 * The source code for this program is not published or otherwise divested
 * of its trade secrets, unauthorized application or modification of this
 * source code will incur legal liability.
 * =============================================================================
 */

#import "AUXLocateTool.h"

@interface AUXLocateTool () <CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLGeocoder *geoC;

@end

@implementation AUXLocateTool

+ (instancetype)defaultTool {
    static AUXLocateTool *_tool = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        _tool = [[AUXLocateTool alloc] init];
    });
    
    return _tool;
}

- (instancetype)init {
    self = [super init];
    
    if (self) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
        self.geoC = [[CLGeocoder alloc]init];
    }
    
    return self;
}

+ (CLAuthorizationStatus)status {
    return [CLLocationManager authorizationStatus];
}

// 判断是否打开定位
+ (BOOL)whtherOpenLocalionPermissions {
    
    if ([CLLocationManager locationServicesEnabled] && ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways)) {
        
        return YES;
        
    } else if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
        
        return NO;
        
    } else{
        
        return NO;
        
    }
    
}

- (BOOL)requestLocation {
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    
    if (status == kCLAuthorizationStatusDenied) {
        return NO;
    }
    
    if ([CLLocationManager locationServicesEnabled]) {
        [self.locationManager requestWhenInUseAuthorization];
        self.locationManager.distanceFilter = kCLDistanceFilterNone;
        [self.locationManager startUpdatingLocation];
        return YES;
    }
    
    return NO;
}

- (void)handleAddressDictionary:(NSDictionary *)addressDictionary {
    /**
     {
     FormattedAddressLines = [
     中国广东省广州市天河区沙东街道沙太路陶庄5号
     ],
     Street = 沙太路陶庄5号,
     Thoroughfare = 沙太路陶庄5号,
     Name = 沙东轻工业大厦,
     City = 广州市,
     Country = 中国,
     State = 广东省,
     SubLocality = 天河区,
     CountryCode = CN
     }
     */
    self.city = addressDictionary[@"SubLocality"];
    self.province = addressDictionary[@"State"];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(locateToolDidUpdateLocation:)]) {
        [self.delegate locateToolDidUpdateLocation:self];
    }
}

- (void)geoCodeAddress:(NSString *)address completion:(void (^)(CLPlacemark *pl , NSError *error))completion {
    if (address.length == 0) {
        return ;
    }
    [self.geoC geocodeAddressString:address completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        /**
         *  CLPlacemark : 地标对象
         *  location : 对应的位置对象
         *  name : 地址全称
         *  locality : 城市
         *  按相关性进行排序
         */
        CLPlacemark *pl = [placemarks firstObject];
        
        if (completion) {
            completion(pl , error);
        }
    }];
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    [self requestLocation];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    [manager stopUpdatingLocation];
    
    CLLocation *location = [locations lastObject];
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    
    self.coordinate = location.coordinate;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(locateTool:didUpdateCoordinate:)]) {
        [self.delegate locateTool:self didUpdateCoordinate:location.coordinate];
    }
    
    @weakify(self);
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        @strongify(self);
        if (!error) {
            CLPlacemark *placemark = [placemarks firstObject];
            
            NSDictionary *addressDict = [placemark addressDictionary];
            //NSLog(@"定位信息 %@", addressDict);
            [self handleAddressDictionary:addressDict];
        } else {
            NSLog(@"解析定位信息失败 [%@] %@", @(error.code), [error localizedDescription]);
            [self handleAddressDictionary:nil];
        }
    }];
}

@end
