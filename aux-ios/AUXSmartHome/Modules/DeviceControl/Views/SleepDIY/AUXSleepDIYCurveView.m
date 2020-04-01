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

#import "AUXSleepDIYCurveView.h"

#import "UIColor+AUXCustom.h"

#import "AUXDefinitions.h"
#import "AUXConfiguration.h"

/// 四舍五入
NSInteger floatToInteger(CGFloat aFloat) {
    NSInteger anInteger = (NSInteger)aFloat;
    CGFloat decimals = aFloat - (CGFloat)anInteger;
    anInteger += (decimals >= 0.5 ? 1 : 0);
    
    return anInteger;
}

@interface AUXSleepDIYCurveView () {
    CGFloat _lineWidth, _lineHeight;    // 背景网格线的长度
    CGFloat _topMargin;                 // Y轴与顶部的间距
    CGFloat _leftMargin;                // Y轴与左边的间距
    CGFloat _bottomMargin;              // X轴与底部的间距
    CGFloat _rightMargin;               // X轴与右边的间距
    CGFloat _xAxisLeftMargin;           // X轴最小刻度(绘制点)与左边的间距
    CGFloat _xAxisRightMargin;          // X轴最大刻度(绘制点)与右边的间距
    
    CGFloat _temperatureStep;       // Y轴温度刻度间隔步进
    CGFloat _temperatureInterval;   // Y轴每摄氏度间隔距离 (1°C所占的高度)
    CGFloat _xAxisInterval;         // X轴每个刻度间隔距离
    
    CGRect _validRect;       // 有效的点击范围
    BOOL _shouldRespond;     // 是否响应拖动
    CGPoint _lastSavePoint;  // 上次拖动的位置
    NSInteger _responsingXIndex;    // 本次拖动或点击对应的X轴下标
    
    BOOL _isDragging;               // 是否在拖动
    BOOL _shouldHighlightPoint;     // 是否应该高亮选中的节点
}

@property (nonatomic, strong) UILabel *temperatureLabel;    // 温度单位

@property (nonatomic, strong) UIImage *pointImage;
@property (nonatomic, strong) UIImage *highlightedPointImage;  // 拖动睡眠曲线的节点时，高亮的图片

@property (nonatomic, strong) NSArray<NSString *> *xAxisValues;             // X轴刻度
@property (nonatomic, strong) NSArray<NSString *> *yAxisValues;             // Y轴刻度

@property (nonatomic, strong) NSMutableArray<NSValue *> *pointsAtXAxis;     // X轴刻度绘制的位置
@property (nonatomic, strong) NSMutableArray<NSValue *> *pointsAtYAxis;     // Y轴刻度绘制的位置
@property (nonatomic, strong) NSMutableArray<NSValue *> *sleepCurvePoints;  // 睡眠曲线每个值所在的节点

@property (nonatomic, strong) NSString *temperatureUnit;
@property (nonatomic, strong) NSString *timeUnit;

@end

@implementation AUXSleepDIYCurveView

+ (CGFloat)properHeight {
    return 330;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.pointImage = [UIImage imageNamed:@"device_icon_slide_updown_blue"];
        self.highlightedPointImage = [UIImage imageNamed:@"device_btn_slide_updown"];
        [self initData];
        [self createCoordinateSystem];
        [self createSleepCurvePoints];
    }
    return self;
}

- (void)initData {
    
    self.halfTemperature = NO;
    self.temperatureUnit = @"(℃)";
    self.timeUnit = @"(时)";
    
    // 创建默认的Y轴刻度
    _temperatureStep = 2;
    NSMutableArray<NSString *> *yAxisValues = [[NSMutableArray alloc] init];
    for (NSInteger temperature = kAUXTemperatureMin; temperature <= kAUXTemperatureMax; temperature += _temperatureStep) {
        [yAxisValues addObject:[NSString stringWithFormat:@"%@", @(temperature)]];
    }
    self.yAxisValues = yAxisValues;
    
    // 创建默认的X轴刻度
    NSMutableArray<AUXSleepDIYPointModel *> *pointArray = [[NSMutableArray alloc] init];
    self.pointArray = pointArray;
    NSMutableArray<NSString *> *xAxisValues = [[NSMutableArray alloc] init];
    self.xAxisValues = xAxisValues;
    
    NSArray<NSDictionary *> *sleepCurveTestDataArray = [self sleepCurveTestDataArray];
    for (int i = 0; i < sleepCurveTestDataArray.count; i++) {
        NSDictionary *dict = sleepCurveTestDataArray[i];
        
        AUXSleepDIYPointModel *pointModel = [AUXSleepDIYPointModel yy_modelWithDictionary:dict];
        pointModel.hour = [dict[@"hour"] integerValue];
        [pointArray addObject:pointModel];
        
        [xAxisValues addObject:[NSString stringWithFormat:@"%@", @(pointModel.hour)]];
    }
}

- (NSArray<NSDictionary *> *)sleepCurveTestDataArray {
    return @[@{@"temperature": @27, @"windSpeed": @(AUXServerWindSpeedAuto), @"hour": @23},
             @{@"temperature": @25, @"windSpeed": @(AUXServerWindSpeedAuto), @"hour": @0},
             @{@"temperature": @29, @"windSpeed": @(AUXServerWindSpeedAuto), @"hour": @1},
             @{@"temperature": @19, @"windSpeed": @(AUXServerWindSpeedAuto), @"hour": @2},
             @{@"temperature": @23, @"windSpeed": @(AUXServerWindSpeedAuto), @"hour": @3},
             @{@"temperature": @30, @"windSpeed": @(AUXServerWindSpeedAuto), @"hour": @4},
             @{@"temperature": @25, @"windSpeed": @(AUXServerWindSpeedAuto), @"hour": @5}];
}

/// 创建坐标系统
- (void)createCoordinateSystem {
    
    CGFloat width = CGRectGetWidth(self.frame);
    CGFloat height = CGRectGetHeight(self.frame);
    
    self.pointsAtXAxis = [NSMutableArray new];
    self.pointsAtYAxis = [NSMutableArray new];
    
    _topMargin = 28;     // Y轴最大值与顶部的间距
    _leftMargin = 30;    // Y轴与左边的间距
    _bottomMargin = 70;  // X轴与底部的间距
    _rightMargin = 20;   // X轴最大值与右边的间距
    
    _lineWidth = width - _leftMargin - _rightMargin;
    
    _xAxisLeftMargin = _leftMargin + 17.0;     // X轴最小刻度(绘制点)与左边的间距
    _xAxisRightMargin = _rightMargin + 17.0;   // X轴最大刻度(绘制点)与右边的间距
    
    // 温度值坐标（Y轴）
    {
        CGFloat temperatureStep = self.halfTemperature ? 0.5 : 1.0;
        // 计算网格线垂直间隔
        CGFloat distance = height - _topMargin - _bottomMargin;
        _temperatureInterval = distance / (kAUXTemperatureMax - kAUXTemperatureMin) * temperatureStep;
        
        // 计算每个温度值所在的点
        // 计算每个温度值的触发范围
        
        // 原点位置
        CGPoint lineYPoint = CGPointMake(_leftMargin, height - _bottomMargin);
        
        for (CGFloat temperature = kAUXTemperatureMin; temperature <= kAUXTemperatureMax; temperature += temperatureStep) {
            NSValue *value = [NSValue valueWithCGPoint:lineYPoint];
            [self.pointsAtYAxis addObject:value];
            
            lineYPoint.y -= _temperatureInterval;
        }
    }
    
    // 时间坐标（X轴）
    {
        // 计算网格线水平间隔
        CGFloat distance = width - _xAxisLeftMargin - _xAxisRightMargin;
        CGFloat cellWidth;
        
        if (self.xAxisValues.count == 1) {
            cellWidth = distance / 2.0;
        } else {
            cellWidth = distance / (self.xAxisValues.count - 1);
        }
        
        _xAxisInterval = cellWidth;
        
        // 计算要显示的时间值（刻度值）所在的点
        CGPoint lineXPoint = CGPointMake(_xAxisLeftMargin, height-_bottomMargin);
        
        if (self.xAxisValues.count == 1) {
            lineXPoint.x += cellWidth;
            NSValue *value = [NSValue valueWithCGPoint:lineXPoint];
            [self.pointsAtXAxis addObject:value];
        } else {
            for (int i = 0; i < self.xAxisValues.count; i++) {
                NSValue *value = [NSValue valueWithCGPoint:lineXPoint];
                [self.pointsAtXAxis addObject:value];
                
                lineXPoint.x += cellWidth;
            }
        }
    }
    
    CGPoint minY = self.pointsAtYAxis.firstObject.CGPointValue;
    CGPoint maxY = self.pointsAtYAxis.lastObject.CGPointValue;
    CGPoint minX = self.pointsAtXAxis.firstObject.CGPointValue;
    CGPoint maxX = self.pointsAtXAxis.lastObject.CGPointValue;
    
    _validRect = CGRectMake(minX.x, maxY.y, maxX.x - minX.x, minY.y - maxY.y);
}

// 创建睡眠曲线的每个点
- (void)createSleepCurvePoints {
    self.sleepCurvePoints = [NSMutableArray new];
    
    for (int i = 0; i < self.pointArray.count; i++) {
        CGFloat temperature = self.pointArray[i].temperature;
        
        CGPoint hourPoint = self.pointsAtXAxis[i].CGPointValue;
        CGPoint temperaturePoint = [self temperatureToYAxisPoint:temperature];
        
        CGPoint curvePoint = CGPointMake(hourPoint.x, temperaturePoint.y);
        [self.sleepCurvePoints addObject:[NSValue valueWithCGPoint:curvePoint]];
    }
}

- (void)drawRect:(CGRect)rect {
    
    UIColor *lineColor = [UIColor colorWithHex:0xf4f4f4];
    UIColor *textColor = [UIColor darkGrayColor];
    
    UIFont *font = [UIFont systemFontOfSize:12];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 1.0);
    
    NSDictionary *fontAttri = @{NSFontAttributeName: font, NSForegroundColorAttributeName: textColor};
    
    CGFloat temperatureStep = self.halfTemperature ? 0.5 : 1.0;
    
    // 画刻度值（Y轴）(线条平行于X轴)
    NSUInteger count = [self.yAxisValues count];
    for (int i = 0; i < count; i++) {
        NSString *scaleValue = self.yAxisValues[i];
        NSInteger index = (scaleValue.integerValue - kAUXTemperatureMin) / temperatureStep;
        
        CGPoint lineYPoint = self.pointsAtYAxis[index].CGPointValue;
        
        // 刻度
        CGPoint scalePoint = CGPointMake(lineYPoint.x - 20, lineYPoint.y - 7);
        [scaleValue drawAtPoint:scalePoint withAttributes:fontAttri];
        
        CGPoint startPoint = lineYPoint;
        CGPoint endPoint = CGPointMake(startPoint.x + _lineWidth, startPoint.y);
        
        CGContextMoveToPoint(context, startPoint.x, startPoint.y);
        CGContextAddLineToPoint(context, endPoint.x, endPoint.y);
    }
    
    CGContextSetStrokeColorWithColor(context, lineColor.CGColor);
    CGContextStrokePath(context);
    
    CGPoint maxYPoint = [((NSValue *)self.pointsAtYAxis.lastObject) CGPointValue];
    
    // 画刻度值（X轴）(线条平行于Y轴)
    for (int i = 0; i < self.xAxisValues.count; i++) {
        NSString *hourStr = self.xAxisValues[i];
        
        CGPoint point = self.pointsAtXAxis[i].CGPointValue;
        CGPoint endPoint = CGPointMake(point.x, maxYPoint.y);
        CGContextMoveToPoint(context, point.x, point.y);
        CGContextAddLineToPoint(context, endPoint.x, endPoint.y);
        
        CGSize strSize = [hourStr boundingRectWithSize:CGSizeMake(MAXFLOAT, 20) options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin  attributes:fontAttri context:nil].size;
        
        point.x -= strSize.width/2.0;
        point.y += 5;
        
        [hourStr drawAtPoint:point withAttributes:fontAttri];
    }
    
    CGContextSetStrokeColorWithColor(context, lineColor.CGColor);
    CGContextStrokePath(context);
    
    if (self.smart) {
        lineColor = [AUXConfiguration sharedInstance].blueColor;
    } else {
        lineColor = [UIColor colorWithHexString:@"DEE3EA"];
    }
    
    // 温度单位
    fontAttri = @{NSFontAttributeName: font, NSForegroundColorAttributeName: [UIColor colorWithHexString:@"666666"]};
    CGPoint unitPoint = self.pointsAtYAxis.lastObject.CGPointValue;
    unitPoint = CGPointMake(unitPoint.x - 20, unitPoint.y - 30);
    [self.temperatureUnit drawAtPoint:unitPoint withAttributes:fontAttri];
    
    //时间单位
    NSString *hourStr = self.xAxisValues.lastObject;
    CGSize hourSize = [hourStr boundingRectWithSize:CGSizeMake(MAXFLOAT, 20) options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin  attributes:fontAttri context:nil].size;
    CGSize strSize = [self.timeUnit boundingRectWithSize:CGSizeMake(MAXFLOAT, 20) options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin  attributes:fontAttri context:nil].size;
    CGPoint timePoint = self.pointsAtXAxis.lastObject.CGPointValue;
    timePoint = CGPointMake(timePoint.x + hourSize.width - strSize.width, timePoint.y + hourSize.height + strSize.height);
    [self.timeUnit drawAtPoint:timePoint withAttributes:fontAttri];
    
    // 画睡眠曲线
    if ([self.pointArray count] > 0) {
        CGContextSetStrokeColorWithColor(context, lineColor.CGColor);
        CGContextSetLineWidth(context, 1);
        
        size_t count = (size_t)self.sleepCurvePoints.count;
        
        CGPoint points[count];
        
        // 先画线，再画点
        for (int i = 0; i < self.sleepCurvePoints.count; i++) {
            NSValue *value = self.sleepCurvePoints[i];
            CGPoint curvePoint = value.CGPointValue;
            points[i] = curvePoint;
        }
        
        CGContextAddLines(context, points, count);
        CGContextStrokePath(context);
        
        NSInteger lastIndex = 0;
        NSInteger nextIndex = 0;
        CGPoint lastPoint;
        CGPoint helightedPoint;
        CGPoint nextPoint;
        if (count >= 3 && !self.smart && _shouldHighlightPoint) {
            CGContextSetStrokeColorWithColor(context, [AUXConfiguration sharedInstance].blueColor.CGColor);
            CGContextSetLineWidth(context, 1);
            
            helightedPoint = self.sleepCurvePoints[_responsingXIndex].CGPointValue;
            if (_responsingXIndex == 0) {
                nextPoint = self.sleepCurvePoints[_responsingXIndex + 1].CGPointValue;
                CGContextMoveToPoint(context, helightedPoint.x, helightedPoint.y);
                CGContextAddLineToPoint(context, nextPoint.x, nextPoint.y);
                CGContextStrokePath(context);
            } else if (_responsingXIndex == count - 1) {
                lastPoint = self.sleepCurvePoints[_responsingXIndex - 1].CGPointValue;
                CGContextMoveToPoint(context, lastPoint.x, lastPoint.y);
                CGContextAddLineToPoint(context, helightedPoint.x, helightedPoint.y);
                CGContextStrokePath(context);
            } else {
                lastIndex = _responsingXIndex - 1;
                nextIndex = _responsingXIndex + 1;
                lastPoint = self.sleepCurvePoints[_responsingXIndex - 1].CGPointValue;
                nextPoint = self.sleepCurvePoints[_responsingXIndex + 1].CGPointValue;
                CGContextMoveToPoint(context, helightedPoint.x, helightedPoint.y);
                CGContextAddLineToPoint(context, nextPoint.x, nextPoint.y);
                CGContextStrokePath(context);
                
                CGContextMoveToPoint(context, lastPoint.x, lastPoint.y);
                CGContextAddLineToPoint(context, helightedPoint.x, helightedPoint.y);
                CGContextStrokePath(context);
            }
            
        }
        
        if (_shouldHighlightPoint) {
            self.pointImage = [UIImage imageNamed:@"device_icon_slide_updown_gray"];
        } else {
            self.pointImage = [UIImage imageNamed:@"device_icon_slide_updown_blue"];
        }
        if (self.smart) {
            self.pointImage = [UIImage imageNamed:@"device_icon_slide_updown_blue"];
        }
        
        CGSize imageSize = self.pointImage.size;
        CGFloat halfWidth = imageSize.width / 2.0;
        CGFloat halfHeight = imageSize.height / 2.0;
        
        for (int i = 0; i < count; i++) {
            
            // 当前选中的点，跳过，另外绘制
            if (_shouldHighlightPoint && i == _responsingXIndex) {
                continue;
            }
            
            CGPoint curvePoint = points[i];
            CGRect imageRect = CGRectMake(curvePoint.x - halfWidth, curvePoint.y - halfHeight, imageSize.width, imageSize.height);
            CGContextDrawImage(context, imageRect, self.pointImage.CGImage);
        }
    }
    
    // 当前选中的点
    if (_shouldHighlightPoint) {
        CGSize imageSize = self.highlightedPointImage.size;
        CGFloat halfWidth = imageSize.width / 2.0;
        CGFloat halfHeight = imageSize.height / 2.0;
        
        CGPoint curvePoint = self.sleepCurvePoints[_responsingXIndex].CGPointValue;
        CGRect imageRect = CGRectMake(curvePoint.x - halfWidth, curvePoint.y - halfHeight, imageSize.width, imageSize.height);
        CGContextDrawImage(context, imageRect, self.highlightedPointImage.CGImage);
    }
    
    [super drawRect:rect];
}

- (void)updateCurve {
    
    NSMutableArray<NSString *> *xAxisValues = [[NSMutableArray alloc] init];
    self.xAxisValues = xAxisValues;
    
    for (AUXSleepDIYPointModel *pointModel in self.pointArray) {
        [xAxisValues addObject:[NSString stringWithFormat:@"%@", @(pointModel.hour)]];
    }
    
    [self createCoordinateSystem];
    [self createSleepCurvePoints];
    
    [self setNeedsDisplay];
}

- (void)updateCurveAtPointModel:(AUXSleepDIYPointModel *)pointModel {
    
    if (![self.pointArray containsObject:pointModel]) {
        return ;
    }
    
    NSInteger pointIndex = [self.pointArray indexOfObject:pointModel];
    CGPoint saveCurvePoint = self.sleepCurvePoints[pointIndex].CGPointValue;
    
    // 智能健康调节
    if (self.smart) {
        [self intelligentlyAdjustTemperatureWithPoint:pointModel];
    }
    
    [self updateCurve];
    
    CGPoint curvePoint = self.sleepCurvePoints[pointIndex].CGPointValue;
    CGFloat yOffset = curvePoint.y - saveCurvePoint.y;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(sleepDIYCurveView:dragging:yOffset:pointModel:)]) {
        [self.delegate sleepDIYCurveView:self dragging:curvePoint yOffset:yOffset pointModel:pointModel];
    }
}

- (void)cancelHighlightedState {
    _shouldHighlightPoint = NO;
    [self setNeedsDisplay];
}

#pragma mark - Touch event

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    
    // 将位置转换为 X轴 下标
    NSInteger xIndex = [self pointToXIndex:point];
    
    // 离手指位置最近的节点
    CGPoint curvePoint = [self.sleepCurvePoints objectAtIndex:xIndex].CGPointValue;
    CGFloat radius = MIN(_xAxisInterval / 2.0 - 1.0, 30);
    
    CGRect respondingRect = CGRectMake(curvePoint.x-radius, curvePoint.y-radius, radius*2, radius*2);
    
    // 手指位置不在有效识别范围内
    if (!CGRectContainsPoint(respondingRect, point)) {
        _shouldHighlightPoint = NO;
        [self setNeedsDisplay];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(sleepDIYCurveView:willBeginDragging:pointModel:)]) {
            [self.delegate sleepDIYCurveView:self willBeginDragging:CGPointZero pointModel:nil];
        }
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(sleepDIYCurveView:didTap:pointModel:)]) {
            [self.delegate sleepDIYCurveView:self didTap:CGPointZero pointModel:nil];
        }
        return;
    }
    
    _shouldRespond = YES;
    _shouldHighlightPoint = YES;
    _lastSavePoint = point;
    _responsingXIndex = xIndex;
    
    [self setNeedsDisplay];
    
    AUXSleepDIYPointModel *pointModel = self.pointArray[_responsingXIndex];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(sleepDIYCurveView:willBeginDragging:pointModel:)]) {
        [self.delegate sleepDIYCurveView:self willBeginDragging:curvePoint pointModel:pointModel];
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(sleepDIYCurveView:didTap:pointModel:)]) {
        [self.delegate sleepDIYCurveView:self didTap:curvePoint pointModel:pointModel];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if (!_shouldRespond) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(sleepDIYCurveView:dragging:yOffset:pointModel:)]) {
            [self.delegate sleepDIYCurveView:self dragging:CGPointZero yOffset:0 pointModel:nil];
        }
        return;
    }
    
    _isDragging = YES;
    
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    
    CGPoint curvePoint = self.sleepCurvePoints[_responsingXIndex].CGPointValue;
    CGPoint saveCurvePoint = curvePoint;
    CGFloat yOffset = (point.y - _lastSavePoint.y);
    
    // 当前曲线点到达了最小（最大）值之后，还继续往上（往下）拖拽，则直接抛弃掉，不作处理
    if (curvePoint.y == CGRectGetMinY(_validRect) && yOffset < 0) {
        return;
    }
    
    if (curvePoint.y == CGRectGetMaxY(_validRect) && yOffset > 0) {
        return;
    }
    
    curvePoint.y += yOffset;
    
    // 限制拖拽的范围
    if (curvePoint.y < CGRectGetMinY(_validRect)) {
        curvePoint.y = CGRectGetMinY(_validRect);
        yOffset = curvePoint.y - saveCurvePoint.y;
    }
    
    if (curvePoint.y > CGRectGetMaxY(_validRect)) {
        curvePoint.y = CGRectGetMaxY(_validRect);
        yOffset = curvePoint.y - saveCurvePoint.y;
    }
    
    // 将点的位置转换为温度
    CGFloat temperature = [self pointToTemperature:curvePoint];
    
    // 重新计算出点的位置和对应的温度值后，替换掉原来的值
    [self.sleepCurvePoints replaceObjectAtIndex:_responsingXIndex withObject:[NSValue valueWithCGPoint:curvePoint]];
    AUXSleepDIYPointModel *pointModel = self.pointArray[_responsingXIndex];
    pointModel.temperature = temperature;
    
    // 智能健康调节
    if (self.smart) {
        [self intelligentlyAdjustTemperatureWithPoint:pointModel];
    }
    
    [self setNeedsDisplay];
    
    _lastSavePoint = point;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(sleepDIYCurveView:dragging:yOffset:pointModel:)]) {
        [self.delegate sleepDIYCurveView:self dragging:curvePoint yOffset:yOffset pointModel:pointModel];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    CGPoint curvePoint = CGPointZero;
    AUXSleepDIYPointModel *pointModel = nil;
    
    if (_shouldRespond) {
        _shouldRespond = NO;
        
        // 拖动过节点
        if (_isDragging) {
            _isDragging = NO;
            
            [self setNeedsDisplay];
            
            curvePoint = self.sleepCurvePoints[_responsingXIndex].CGPointValue;
            pointModel = self.pointArray[_responsingXIndex];
        }
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(sleepDIYCurveView:didEndDragging:pointModel:)]) {
        [self.delegate sleepDIYCurveView:self didEndDragging:curvePoint pointModel:pointModel];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [self touchesEnded:touches withEvent:event];
}

/**
 将坐标转换为温度
 */
- (CGFloat)pointToTemperature:(CGPoint)point {
    CGPoint minTemperaturePoint = self.pointsAtYAxis.firstObject.CGPointValue;
    
    CGFloat temperature = 0;
    
    CGFloat temperatureStep = self.halfTemperature ? 0.5 : 1.0;
    
    CGFloat distance = minTemperaturePoint.y - point.y;
    CGFloat scale = distance / _temperatureInterval * temperatureStep;
    
    temperature = kAUXTemperatureMin + scale;
    temperature = AUXAdjustFloatValue(temperature, temperatureStep);
    
    return temperature;
}

/**
 获取温度对应的Y轴坐标

 @param temperature 温度
 @return 坐标
 */
- (CGPoint)temperatureToYAxisPoint:(CGFloat)temperature {
    CGFloat temperatureStep = self.halfTemperature ? 0.5 : 1.0;
    
    NSInteger index = (temperature - kAUXTemperatureMin) / temperatureStep;
    
    return self.pointsAtYAxis[index].CGPointValue;
}

/**
 将坐标转换为X轴的下标

 @param point 坐标
 @return 时间的下标
 */
- (NSInteger)pointToXIndex:(CGPoint)point {
    CGPoint xOrigin = self.pointsAtXAxis.firstObject.CGPointValue;
    
    CGFloat floatIndex = (point.x - xOrigin.x) / _xAxisInterval;
    
    if (floatIndex < 0) {
        return 0;
    }
    
    NSInteger xIndex = floatToInteger(floatIndex);
    
    if (xIndex >= self.pointsAtXAxis.count) {
        xIndex = self.pointsAtXAxis.count - 1;
    }
    
    return xIndex;
}

/**
 智能健康调节。相邻两点之间温度差不能超过2摄氏度。
 
 @param pointModel 当前正在修改的节点
 */
- (void)intelligentlyAdjustTemperatureWithPoint:(AUXSleepDIYPointModel *)pointModel {
    
    [self adjustTemperatureWithPointArray:self.pointArray referencePoint:pointModel forward:NO];
    [self adjustTemperatureWithPointArray:self.pointArray referencePoint:pointModel forward:YES];
}

- (void)adjustTemperatureWithPointArray:(NSArray<AUXSleepDIYPointModel *> *)pointArray referencePoint:(AUXSleepDIYPointModel *)pointModel forward:(BOOL)forward {
    
    if (!pointArray) {
        return;
    }
    
    NSInteger index = [pointArray indexOfObject:pointModel];
    
    if (index == NSNotFound) {
        return;
    }
    
    if (forward && index < pointArray.count - 1) {
        index += 1;
    } else if (!forward && index > 0) {
        index -= 1;
    } else {
        index = NSNotFound;
    }
    
    if (index != NSNotFound) {
        AUXSleepDIYPointModel *anotherPointModel = pointArray[index];
        CGFloat difference = anotherPointModel.temperature - pointModel.temperature;
        if (difference > 2) {
            anotherPointModel.temperature = pointModel.temperature + 2;
        } else if (difference < -2) {
            anotherPointModel.temperature = pointModel.temperature - 2;
        }
        
        CGPoint temperaturePoint = [self temperatureToYAxisPoint:anotherPointModel.temperature];
        CGPoint hourPoint = self.pointsAtXAxis[index].CGPointValue;
        CGPoint curvePoint = CGPointMake(hourPoint.x, temperaturePoint.y);
        
        [self.sleepCurvePoints replaceObjectAtIndex:index withObject:[NSValue valueWithCGPoint:curvePoint]];
        
        [self adjustTemperatureWithPointArray:pointArray referencePoint:anotherPointModel forward:forward];
    }
}

@end
