//
//  AUXLaunchAdModel.h
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2019/1/14.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <YYModel.h>

NS_ASSUME_NONNULL_BEGIN

@interface AUXLaunchAdModel : NSObject<NSCoding>

/**
 唯一标识
 */
@property (nonatomic,copy) NSString *advertisementId;
/**
 停留时间(default 3000 ,单位:毫秒)
 */
@property (nonatomic,assign) NSInteger duration;
/**
 显示完成动画时间(default 2000 , 单位:毫秒)
 */
@property (nonatomic,assign) NSInteger showFinishAnimateTime;
/**
 image本地图片名(jpg/gif图片请带上扩展名)或网络图片URL string
 */
@property (nonatomic,copy) NSString *imageBannerURLString;;
/**
 设置GIF动图是否只循环播放一次(YES:只播放一次,NO:循环播放,default NO,仅对动图设置有效)
 */
@property (nonatomic,assign) BOOL GIFImageCycleOnce;
/**
 video本地名或网络链接URL string
 */
@property (nonatomic,copy) NSString *videoURLString;
/**
 设置视频是否只循环播放一次(YES:只播放一次,NO循环播放,default NO)
 */
@property (nonatomic,assign) BOOL videoCycleOnce;
/**
 开始时间
 */
@property (nonatomic,assign) NSTimeInterval startTime;
/**
 结束时间
 */
@property (nonatomic,assign) NSTimeInterval endTime;
/**
 广告页能否点击，默认可点击 NO
 */
@property (nonatomic,assign) BOOL isCanClick;
/**
 广告页可点击的开始时间
 */
@property (nonatomic,assign) NSTimeInterval clickStartTime;
/**
 广告页可点击的结束时间
 */
@property (nonatomic,assign) NSTimeInterval clickEndTime;

/**
 点击跳转URL(可三方APP、可跳往APPweb页面、可跳往APP本地原生页面)
 */
@property (nonatomic,copy) NSString *sourceValue;
/**
 降级url，对local|schema降级处理
 */
@property (nonatomic,copy) NSString *linkedUrl;
/**
 跳转类型
 schema ：以schema方式打开链接，常用于打开外部链接
 local：打开本地页面
 */
@property (nonatomic,copy) NSString *sourceType;

@end

NS_ASSUME_NONNULL_END
