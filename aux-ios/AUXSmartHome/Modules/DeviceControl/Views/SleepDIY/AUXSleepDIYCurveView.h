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

#import "AUXBaseView.h"

#import "AUXSleepDIYModel.h"

@class AUXSleepDIYCurveView;

@protocol AUXSleepDIYCurveViewDelegate <NSObject>

@optional

/**
 将要开始拖动节点

 @param curveView 曲线视图
 @param point 当前节点的center point
 @param pointModel 节点
 */
- (void)sleepDIYCurveView:(AUXSleepDIYCurveView *)curveView willBeginDragging:(CGPoint)point pointModel:(AUXSleepDIYPointModel *)pointModel;

/**
 正在拖动节点

 @param curveView 曲线视图
 @param point 当前节点的center point
 @param yOffset 拖动y轴偏移量
 @param pointModel 节点
 */
- (void)sleepDIYCurveView:(AUXSleepDIYCurveView *)curveView dragging:(CGPoint)point yOffset:(CGFloat)yOffset pointModel:(AUXSleepDIYPointModel *)pointModel;

/**
 拖动结束

 @param curveView 曲线视图
 @param point 当前节点的center point
 @param pointModel 节点
 */
- (void)sleepDIYCurveView:(AUXSleepDIYCurveView *)curveView didEndDragging:(CGPoint)point pointModel:(AUXSleepDIYPointModel *)pointModel;

/**
 点击了节点 (如果点击的位置不在有效范围，point为CGPointZero，pointModel为nil。)

 @param curveView 曲线视图
 @param point 当前节点的center point
 @param pointModel 节点
 */
- (void)sleepDIYCurveView:(AUXSleepDIYCurveView *)curveView didTap:(CGPoint)point pointModel:(AUXSleepDIYPointModel *)pointModel;

@end

/**
 睡眠DIY温度调节界面
 */
@interface AUXSleepDIYCurveView : UIControl 

@property (class, nonatomic, assign, readonly) CGFloat properHeight;

@property (nonatomic, assign) BOOL halfTemperature;     // 是否支持 0.5 摄氏度，默认为NO

/// 智能健康调节。相邻两点之间温度差不能超过2摄氏度。
/// 开启之后，拖动节点调节温度时，需要自动更改其他节点的温度。
@property (nonatomic, assign) BOOL smart;

@property (nonatomic, strong) NSArray<AUXSleepDIYPointModel *> *pointArray;

@property (nonatomic, weak) id<AUXSleepDIYCurveViewDelegate> delegate;

- (void)updateCurve;
- (void)updateCurveAtPointModel:(AUXSleepDIYPointModel *)pointModel;

/**
 取消所有节点的高亮状态
 */
- (void)cancelHighlightedState;

@end
