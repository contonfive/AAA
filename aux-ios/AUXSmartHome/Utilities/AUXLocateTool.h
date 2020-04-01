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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@protocol AUXLocateToolDeletate;

/**
 定位工具
 */
@interface AUXLocateTool : NSObject

@property (nonatomic, weak) id<AUXLocateToolDeletate> delegate;

@property (nonatomic, strong) NSString *province;       // 定位 - 省份
@property (nonatomic, strong) NSString *city;           // 定位 - 城市

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;    // 坐标

+ (instancetype)defaultTool;

+ (CLAuthorizationStatus)status;

- (BOOL)requestLocation;

/**
 判断是否打开定位权限

 @return YES 打开  NO 未打开
 */
+ (BOOL)whtherOpenLocalionPermissions;

- (void)geoCodeAddress:(NSString *)address completion:(void (^)(CLPlacemark *pl , NSError *error))completion;

@end


@protocol AUXLocateToolDeletate <NSObject>

@optional

- (void)locateTool:(AUXLocateTool *)locateTool didUpdateCoordinate:(CLLocationCoordinate2D)coordinate;
- (void)locateToolDidUpdateLocation:(AUXLocateTool *)locateTool;

@end
