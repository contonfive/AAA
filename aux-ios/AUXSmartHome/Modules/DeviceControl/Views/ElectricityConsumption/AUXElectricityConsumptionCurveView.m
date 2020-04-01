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

#import "AUXElectricityConsumptionCurveView.h"

#import "RACEXTScope.h"
#import "AUXConfiguration.h"
#import "AUXDefinitions.h"
#import "NSDate+AUXCustom.h"
#import "UIColor+AUXCustom.h"
#import "UIView+MIExtensions.h"


CGSize AUXECGetStringSize(NSString *string, UIFont *font) {
    CGSize size = [string boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin  attributes:@{NSFontAttributeName: font} context:nil].size;
    return size;
}


#pragma mark - X轴或Y轴刻度所在的点模型 (私有)

/// X轴或Y轴刻度所在的点
@interface AUXCurveAxisPoint : NSObject

@property (nonatomic, assign) CGPoint point;
@property (nonatomic, strong) NSString *scaleString;
@property (nonatomic, assign) CGSize scaleSize;

@end

@implementation AUXCurveAxisPoint

@end


#pragma mark - 曲线图Y轴 (私有)

/// 曲线图Y轴及平行于X轴的刻度线
@interface AUXElectricityConsumptionCurveYAxisView : UIView

/// Y轴每个刻度的坐标
@property (nonatomic, strong) NSArray<AUXCurveAxisPoint *> *axisPoints;

@property (nonatomic, strong) NSString *unitString; // 单位 (度)
@property (nonatomic, assign) CGSize unitSize;

@property (nonatomic, strong) NSString *xUnitString; // 单位 (时)
@property (nonatomic, assign) CGSize xUnitSize;

@property (nonatomic, strong) UIColor *scaleColor;  // 刻度颜色
@property (nonatomic, strong) UIFont *scaleFont;    // 刻度字体
@property (nonatomic, strong) UIColor *lineColor;   // 线条颜色
@property (nonatomic, assign) CGFloat lineWidth;

@end

@implementation AUXElectricityConsumptionCurveYAxisView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self initSubviews];
    }
    
    return self;
}

- (instancetype)init {
    self = [super init];
    
    if (self) {
        [self initSubviews];
    }
    
    return self;
}

- (void)initSubviews {
    self.backgroundColor = [UIColor clearColor];
    
    self.scaleFont = [UIFont systemFontOfSize:12];
    self.scaleColor = [UIColor colorWithHexString:@"8E959D"];
    self.lineColor = [UIColor colorWithHexString:@"F6F6F6"];
    self.unitString = @"(度)";
    self.xUnitString = @"(时)";
}

- (void)setUnitString:(NSString *)unitString {
    _unitString = unitString;
    
    if (unitString && unitString.length > 0) {
        CGSize unitSize = AUXECGetStringSize(unitString, self.scaleFont);
        self.unitSize = unitSize;
    } else {
        self.unitSize = CGSizeZero;
    }
}

- (void)setXUnitString:(NSString *)xUnitString {
    _xUnitString = xUnitString;
    
    if (_xUnitString && _xUnitString.length > 0) {
        CGSize unitSize = AUXECGetStringSize(_xUnitString, self.scaleFont);
        self.xUnitSize = unitSize;
    } else {
        self.xUnitSize = CGSizeZero;
    }
    
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    
    if (!self.axisPoints || self.axisPoints.count == 0) {
        [super drawRect:rect];
        return;
    }
    
    UIColor *lineColor = self.lineColor;
    UIColor *textColor = self.scaleColor;
    
    UIFont *font = self.scaleFont;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 1.0);
    
    NSDictionary *fontAttri = @{NSFontAttributeName: font, NSForegroundColorAttributeName: textColor};
    
    // 画刻度值（Y轴）(线条平行于X轴)
    for (AUXCurveAxisPoint *axisPoint in self.axisPoints) {
        NSString *scaleString = axisPoint.scaleString;
        CGSize scaleSize = axisPoint.scaleSize;
        CGPoint lineYPoint = axisPoint.point;
        
        // 刻度
        CGPoint scalePoint = CGPointMake(lineYPoint.x - scaleSize.width - 5, lineYPoint.y - scaleSize.height / 2.0);
        [scaleString drawAtPoint:scalePoint withAttributes:fontAttri];
        
        // 线条
        CGPoint startPoint = lineYPoint;
        CGPoint endPoint = CGPointMake(startPoint.x + self.lineWidth, startPoint.y);
        
        CGContextMoveToPoint(context, startPoint.x, startPoint.y);
        CGContextAddLineToPoint(context, endPoint.x, endPoint.y);
    }
    
    CGContextSetStrokeColorWithColor(context, lineColor.CGColor);
    CGContextStrokePath(context);
    
    // 单位
    if ([self.unitString length] > 0) {
        CGSize unitSize = self.unitSize;
        
        CGPoint unitPoint = self.axisPoints.lastObject.point;
        unitPoint = CGPointMake(unitPoint.x - unitSize.width, unitPoint.y - 10 - unitSize.height);
        [self.unitString drawAtPoint:unitPoint withAttributes:fontAttri];
    }
    
    
    // 单位
    if ([self.xUnitString length] > 0) {
        CGSize unitSize = self.xUnitSize;
        
        CGPoint unitPoint = self.axisPoints.firstObject.point;
        unitPoint = CGPointMake(unitPoint.x - unitSize.width, unitPoint.y + 10 );
        [self.xUnitString drawAtPoint:unitPoint withAttributes:fontAttri];
    }
    
    [super drawRect:rect];
}

@end


#pragma mark - 曲线图X轴 (私有)

/// 曲线图X轴
@interface AUXElectricityConsumptionCurveXAxisView : UIView

/// X轴每个刻度的坐标
@property (nonatomic, strong) NSArray<AUXCurveAxisPoint *> *axisPoints;

@property (nonatomic, strong) UIColor *scaleColor;  // 刻度颜色
@property (nonatomic, strong) UIFont *scaleFont;    // 刻度字体
@property (nonatomic, strong) UIColor *lineColor;   // 线条颜色
@property (nonatomic, assign) CGFloat lineWidth;

@property (nonatomic, assign) CGSize unitSize;

@property (nonatomic, assign) NSInteger selectedIndex;
@property (nonatomic, assign) CGPoint selectedValuePoint;

@end

@implementation AUXElectricityConsumptionCurveXAxisView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self initSubviews];
    }
    
    return self;
}

- (instancetype)init {
    self = [super init];
    
    if (self) {
        [self initSubviews];
    }
    
    return self;
}

- (void)initSubviews {
    self.backgroundColor = [UIColor clearColor];
    
    self.scaleFont = [UIFont systemFontOfSize:12];
    self.scaleColor = [UIColor colorWithHexString:@"8E959D"];
    self.lineColor = [AUXConfiguration sharedInstance].curveCommonColor;
    
    self.selectedIndex = -1;
}
//
//- (void)setUnitString:(NSString *)unitString {
//    _unitString = unitString;
//
//    if (unitString && unitString.length > 0) {
//        CGSize unitSize = AUXECGetStringSize(unitString, self.scaleFont);
//        self.unitSize = unitSize;
//    } else {
//        self.unitSize = CGSizeZero;
//    }
//
//}


- (void)drawRect:(CGRect)rect {
    
    if (!self.axisPoints || self.axisPoints.count == 0) {
        [super drawRect:rect];
        return;
    }
    
    UIColor *lineColor = self.lineColor;
    UIColor *textColor = self.scaleColor;
    
    UIFont *font = self.scaleFont;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 1.0);
    
    NSDictionary *fontAttri = @{NSFontAttributeName: font, NSForegroundColorAttributeName: textColor};
    NSDictionary *selectedFontAttri = @{NSFontAttributeName: font, NSForegroundColorAttributeName: [UIColor whiteColor]};
    
    NSInteger selectedIndex = self.selectedIndex;
    CGPoint selectedPoint = self.selectedValuePoint;
    
    // 画刻度值（X轴）
    [self.axisPoints enumerateObjectsUsingBlock:^(AUXCurveAxisPoint * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *scaleString = obj.scaleString;
        CGSize scaleSize = obj.scaleSize;
        CGPoint lineXPoint = obj.point;
        
        CGFloat scaleWidth = MAX(scaleSize.width + 5, 18);
        
        // 刻度
        CGPoint scalePoint = CGPointMake(lineXPoint.x - scaleSize.width / 2.0, lineXPoint.y + 10);
        CGPoint scaleCenter = CGPointMake(lineXPoint.x, scalePoint.y + scaleSize.height / 2.0);
        
        // 当前节点被选中
        if (idx == selectedIndex) {
            
            // X轴刻度边框
            UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(scaleCenter.x - scaleWidth / 2.0, scaleCenter.y - 8, scaleWidth, 16) cornerRadius:8];
            CGContextAddPath(context, bezierPath.CGPath);
            
            CGContextSetFillColorWithColor(context, lineColor.CGColor);//填充颜色
            CGContextFillPath(context);
            
            // 指示虚线
            CGFloat pattern[] = {3, 2};
            CGContextMoveToPoint(context, selectedPoint.x, selectedPoint.y);
            CGContextAddLineToPoint(context, lineXPoint.x, lineXPoint.y);
            CGContextSetLineDash(context, 0, pattern, 2);
            CGContextStrokePath(context);
            
            [scaleString drawAtPoint:scalePoint withAttributes:selectedFontAttri];
        } else {
            [scaleString drawAtPoint:scalePoint withAttributes:fontAttri];
        }
    }];
    
    
    [super drawRect:rect];
}

@end

#pragma mark - 曲线图 (私有)

/// 真正画曲线的视图
@interface AUXElectricityConsumptionInternalCurveView : UIView

@property (nonatomic, strong) NSArray<AUXElectricityConsumptionCurvePointModel *> *pointModelArray; // 节点列表

@end

@implementation AUXElectricityConsumptionInternalCurveView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self initSubviews];
    }
    
    return self;
}

- (instancetype)init {
    self = [super init];
    
    if (self) {
        [self initSubviews];
    }
    
    return self;
}

- (void)initSubviews {
    self.backgroundColor = [UIColor clearColor];
}

- (NSArray<AUXElectricityConsumptionCurvePointModel *> *)pointModelArray {
    if (!_pointModelArray) {
        _pointModelArray = @[];
    }
    
    return _pointModelArray;
}

/// 修改了节点列表之后，调用该方法更新曲线
- (void)updateCurve {
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    
    if (self.pointModelArray.count == 0) {
        [super drawRect:rect];
        return;
    }
    
    // 画节点
    void (^drawDotAtPoint)(CGContextRef, CGColorRef, CGPoint) = ^(CGContextRef context, CGColorRef color, CGPoint point) {
        CGFloat pointRadius = 3.0;
        
        CGRect rect = CGRectMake(point.x - pointRadius, point.y - pointRadius, pointRadius * 2, pointRadius * 2);
        
        CGContextAddEllipseInRect(context, rect);
        CGContextSetFillColorWithColor(context, color);
        CGContextFillPath(context);
    };
    
    // 曲线颜色
    AUXConfiguration *configuration = [AUXConfiguration sharedInstance];
    CGColorRef curveNormalColor = configuration.curveNormalColor.CGColor;
    CGColorRef curvePeakColor = configuration.curvePeakColor.CGColor;
    CGColorRef curveValleyColor = configuration.curveValleyColor.CGColor;
    CGColorRef curveCommonColor = configuration.curveCommonColor.CGColor;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 2.0);
    
    // 从第2点开始画
    for (int i = 1; i < self.pointModelArray.count; i++) {
        AUXElectricityConsumptionCurvePointModel *pointModel = self.pointModelArray[i];
        AUXElectricityConsumptionCurvePointModel *lastPointModel = self.pointModelArray[i - 1];
        
        CGContextMoveToPoint(context, lastPointModel.point.x, lastPointModel.point.y);
        CGContextAddLineToPoint(context, pointModel.point.x, pointModel.point.y);
        
        CGColorRef lineColor;
        
        switch (lastPointModel.waveType) {
            case AUXElectricityCurveWaveTypeNone:
                lineColor = curveCommonColor;
                break;
                
            case AUXElectricityCurveWaveTypeNormal:
                lineColor = curveNormalColor;
                break;
                
            case AUXElectricityCurveWaveTypePeak:
                lineColor = curvePeakColor;
                break;
                
            default:
                lineColor = curveValleyColor;
                break;
        }
        
        // 先画线条
        CGContextSetStrokeColorWithColor(context, lineColor);
        CGContextStrokePath(context);
        
        // 画节点
        drawDotAtPoint(context, lineColor, lastPointModel.point);
        
        // 画最后一个节点
        if (i == self.pointModelArray.count - 1) {

            switch (pointModel.waveType) {
                case AUXElectricityCurveWaveTypeNone:
                    lineColor = curveCommonColor;
                    break;

                case AUXElectricityCurveWaveTypeNormal:
                    lineColor = curveNormalColor;
                    break;

                case AUXElectricityCurveWaveTypePeak:
                    lineColor = curvePeakColor;
                    break;

                default:
                    lineColor = curveValleyColor;
                    break;
            }

            drawDotAtPoint(context, lineColor, pointModel.point);
        }
    }
    
    [super drawRect:rect];
}

@end


#pragma mark - 曲线上选中的点 (私有)

@interface AUXElectricityConsumptionSelectedView : UIView

@property (nonatomic, assign) BOOL oldDevice;   // 新设备、旧设备。默认为NO，即新设备。

// 日用电曲线选中的视图
@property (nonatomic, strong) UIView *dayContentView;
@property (nonatomic, strong) UILabel *dayValueLabel; // 电量
// 月、年用电曲线选中的视图
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UILabel *normalLabel; // 波平电量
@property (nonatomic, strong) UILabel *peakLabel;   // 波峰电量
@property (nonatomic, strong) UILabel *valleyLabel; // 波谷电量
@property (nonatomic, strong) UILabel *totalLabel;  // 总电量

@property (nonatomic, assign) CGFloat normalElectricity;
@property (nonatomic, assign) CGFloat peakElectricity;
@property (nonatomic, assign) CGFloat valleyElectricity;
@property (nonatomic, assign) CGFloat totalElectricity;

// 选中的节点
@property (nonatomic, strong) CALayer *pointLayer;

@property (nonatomic, assign) AUXElectricityCurveDateType dateType;

@end

@implementation AUXElectricityConsumptionSelectedView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self initSubviews];
    }
    
    return self;
}

- (instancetype)init {
    self = [super init];
    
    if (self) {
        [self initSubviews];
    }
    
    return self;
}

- (void)initSubviews {
    self.backgroundColor = [UIColor clearColor];
    self.dateType = AUXElectricityCurveDateTypeDay;
    
    self.pointLayer = [self createPointLayer];
    
    self.dayContentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 90, 30)];
    
    self.dayContentView.layer.backgroundColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0].CGColor;
    self.dayContentView.layer.cornerRadius = 2;
    self.dayContentView.layer.shadowColor = [UIColor colorWithRed:78/255.0 green:120/255.0 blue:169/255.0 alpha:0.13].CGColor;
    self.dayContentView.layer.shadowOffset = CGSizeMake(0,1);
    self.dayContentView.layer.shadowOpacity = 1;
    self.dayContentView.layer.shadowRadius = 4;
    self.dayContentView.backgroundColor = [UIColor whiteColor];
    self.dayContentView.hidden = YES;
    [self addSubview:self.dayContentView];
    
    self.dayValueLabel = [self createPointLabel];
    [self.dayContentView addSubview:self.dayValueLabel];
    
    self.contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 108, 95)];
    self.contentView.backgroundColor = [UIColor whiteColor];
    self.contentView.layer.backgroundColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0].CGColor;
    self.contentView.layer.cornerRadius = 2;
    self.contentView.layer.shadowColor = [UIColor colorWithRed:78/255.0 green:120/255.0 blue:169/255.0 alpha:0.13].CGColor;
    self.contentView.layer.shadowOffset = CGSizeMake(0,1);
    self.contentView.layer.shadowOpacity = 1;
    self.contentView.layer.shadowRadius = 4;
    self.contentView.hidden = YES;
    [self addSubview:self.contentView];
    
    self.normalLabel = [self createPointLabel];
    [self.contentView addSubview:self.normalLabel];
    
    self.peakLabel = [self createPointLabel];
    [self.contentView addSubview:self.peakLabel];
    
    self.valleyLabel = [self createPointLabel];
    [self.contentView addSubview:self.valleyLabel];
    
    self.totalLabel = [self createPointLabel];
    self.totalLabel.textColor = [UIColor colorWithHexString:@"10BFCA"];
    [self.contentView addSubview:self.totalLabel];
}

- (UILabel *)createPointLabel {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 90, 25)];
    label.textColor = [AUXConfiguration sharedInstance].curveCommonColor;
    label.font = [UIFont systemFontOfSize:12];
    
    return label;
}

- (CALayer *)createPointLayer {
    CGFloat radius = 5.0;
    
    CALayer *layer = [CALayer layer];
    layer.frame = CGRectMake(0, 0, radius * 2, radius * 2);
    layer.cornerRadius = radius;
    layer.borderWidth = 2.0;
    layer.borderColor = [AUXConfiguration sharedInstance].curveCommonColor.CGColor;
    layer.backgroundColor = [UIColor whiteColor].CGColor;
    layer.hidden = YES;
    [self.layer addSublayer:layer];
    
    return layer;
}

- (void)setDateType:(AUXElectricityCurveDateType)dateType {
    _dateType = dateType;
}

- (void)updateDayContentViewWithPointModel:(AUXElectricityConsumptionCurvePointModel *)pointModel {
    
    CGFloat value = 0;
    NSString *typeString;
    UIFont *valueFont = [UIFont systemFontOfSize:16];
    
    switch (pointModel.waveType) {
        case AUXElectricityCurveWaveTypeNormal:
            value = pointModel.waveFlatElectricity;
            self.normalElectricity = value;
            typeString = @"波平: ";
            break;
            
        case AUXElectricityCurveWaveTypePeak:
            value = pointModel.peakElectricity;
            self.peakElectricity = value;
            typeString = @"波峰: ";
            break;
            
        case AUXElectricityCurveWaveTypeValley:
            value = pointModel.valleyElectricity;
            self.valleyElectricity = value;
            typeString = @"波谷: ";
            break;
            
        default:
            value = pointModel.waveFlatElectricity;
            self.normalElectricity = value;
            typeString = @"总共: ";
            break;
    }
    
    [self updateLabel:self.dayValueLabel value:value valueFont:valueFont typeString:typeString];
    
    CGFloat padding = 20;
    CGFloat width = CGRectGetWidth(self.dayValueLabel.frame) + padding * 2;
    
    self.dayContentView.width = width;
    
    self.dayValueLabel.left = padding;
    self.dayValueLabel.centerY = self.dayContentView.height / 2.0;
    
    self.dayContentView.bottom = pointModel.point.y - 10;
    self.dayContentView.centerX = pointModel.point.x;
    
    [self adjustContentViewPosition:self.dayContentView withPointModel:pointModel];
}

- (void)updateContentViewWithPointModel:(AUXElectricityConsumptionCurvePointModel *)pointModel {
    
    UIFont *totalValueFont = [UIFont systemFontOfSize:16];
    UIFont *valueFont = [UIFont systemFontOfSize:14];
    
    self.normalElectricity = pointModel.waveFlatElectricity;
    self.peakElectricity = pointModel.peakElectricity;
    self.valleyElectricity = pointModel.valleyElectricity;
    self.totalElectricity = pointModel.totalElectricity;
    
    [self updateLabel:self.totalLabel value:self.totalElectricity valueFont:totalValueFont typeString:@"总共: "];
    [self updateLabel:self.peakLabel value:self.peakElectricity valueFont:valueFont typeString:@"波峰: "];
    [self updateLabel:self.valleyLabel value:self.valleyElectricity valueFont:valueFont typeString:@"波谷: "];
    [self updateLabel:self.normalLabel value:self.normalElectricity valueFont:valueFont typeString:@"波平: "];
    
    CGFloat leftPadding = 20;
    CGFloat topPadding = 10;
    CGFloat verticalSpacing = 5;
    CGFloat width = CGRectGetWidth(self.totalLabel.frame) + leftPadding * 2;
    
    self.contentView.width = width;
    
    self.totalLabel.left = leftPadding;
    self.totalLabel.top = topPadding;
    
    self.peakLabel.left = leftPadding;
    self.peakLabel.top = self.totalLabel.bottom + verticalSpacing;
    
    self.valleyLabel.left = leftPadding;
    self.valleyLabel.top = self.peakLabel.bottom + verticalSpacing;
    
    self.normalLabel.left = leftPadding;
    self.normalLabel.top = self.valleyLabel.bottom + verticalSpacing;
    
    self.contentView.height = self.normalLabel.bottom + topPadding;
    
    self.contentView.bottom = pointModel.point.y - topPadding;
    self.contentView.centerX = pointModel.point.x;
    
    [self adjustContentViewPosition:self.contentView withPointModel:pointModel];
}

- (void)adjustContentViewPosition:(UIView *)contentView withPointModel:(AUXElectricityConsumptionCurvePointModel *)pointModel {
    CGFloat padding = 10;
    CGFloat maxX = CGRectGetWidth(self.frame);
    
    if (contentView.top < 0) {
        contentView.top = padding;
        contentView.left = pointModel.point.x + padding;
        
        if (contentView.right > maxX) {
            contentView.right = pointModel.point.x - padding;
        }
    } else if (contentView.left < 0) {
        contentView.left = 5;
    } else if (contentView.right > maxX) {
        contentView.right = maxX - 5;
    }
}

- (void)updateLabel:(UILabel *)label value:(CGFloat)value valueFont:(UIFont *)valueFont typeString:(NSString *)typeString {
    NSString *valueString = [NSString stringWithFormat:@"%.2f", (float)value];
    NSString *text = [NSString stringWithFormat:@"%@%@ 度", typeString, valueString];
    NSRange range = [text rangeOfString:valueString];
    
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:text];
    [attributedText addAttribute:NSFontAttributeName value:valueFont range:range];
    
    label.attributedText = attributedText;
    [label sizeToFit];
}

- (void)selectPointModel:(AUXElectricityConsumptionCurvePointModel *)pointModel {
    
    if (!pointModel) {
        self.pointLayer.hidden = YES;
        self.dayContentView.hidden = YES;
        self.contentView.hidden = YES;
        return;
    }
    
    CALayer *layer = self.pointLayer;
    
    // 选中的节点
    CGRect layerFrame = layer.frame;
    layerFrame.origin.x = pointModel.point.x - CGRectGetWidth(layerFrame) / 2.0;
    layerFrame.origin.y = pointModel.point.y - CGRectGetHeight(layerFrame) / 2.0;
    
    layer.hidden = NO;
    layer.frame = layerFrame;
    
    if (self.dateType == AUXElectricityCurveDateTypeDay || self.oldDevice) {
        self.dayContentView.hidden = NO;
        self.contentView.hidden = YES;
        [self updateDayContentViewWithPointModel:pointModel];
    } else {
        self.dayContentView.hidden = YES;
        self.contentView.hidden = NO;
        [self updateContentViewWithPointModel:pointModel];
    }
}

@end


#pragma mark - 装载曲线图、Y轴、X轴的视图 (公开)

@interface AUXElectricityConsumptionCurveView () {
    CGFloat _lineWidth, _lineHeight;    // 背景网格线的长度
    CGFloat _topMargin;                 // Y轴与顶部的间距
    CGFloat _leftMargin;                // Y轴与左边的间距
    CGFloat _bottomMargin;              // X轴与底部的间距
    CGFloat _rightMargin;               // X轴与右边的间距
    CGFloat _xAxisLeftMargin;           // X轴最小刻度(绘制点)与左边的间距
    CGFloat _xAxisRightMargin;          // X轴最大刻度(绘制点)与右边的间距
    CGFloat _xScaleInterval;            // X轴每个刻度的间距
    CGFloat _yScaleInterval;            // Y轴每个刻度的间距
    NSInteger _yScaleStep;                // Y轴每个刻度的步进
}

@property (nonatomic, assign) CGFloat lineWidth;

@property (nonatomic, strong) AUXElectricityConsumptionCurveXAxisView *xAxisView;    // X轴刻度
@property (nonatomic, strong) AUXElectricityConsumptionCurveYAxisView *yAxisView;    // Y轴刻度

@property (nonatomic, strong) UIScrollView *scrollView; // 装载曲线图的scrollView
@property (nonatomic, strong) UITapGestureRecognizer *scrollViewTapGesture;

@property (nonatomic, strong) AUXElectricityConsumptionInternalCurveView *curveView;

@property (nonatomic, strong) AUXElectricityConsumptionSelectedView *selectedView;  // 显示选中的节点及度数的视图

@property (nonatomic, strong) NSMutableArray<AUXCurveAxisPoint *> *pointsAtYAxis;     // Y轴刻度绘制的位置
@property (nonatomic, strong) NSMutableArray<AUXCurveAxisPoint *> *pointsAtXAxis;     // X轴刻度绘制的位置

@end

@implementation AUXElectricityConsumptionCurveView

+ (CGFloat)properHeightForCell {
    return 218;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self initSubviews];
    }
    
    return self;
}

- (instancetype)init {
    self = [super init];
    
    if (self) {
        [self initSubviews];
    }
    
    return self;
}

- (void)initSubviews {
    _topMargin = 22;     // Y轴最大值与顶部的间距
    _leftMargin = 40;    // Y轴与左边的间距
    _bottomMargin = 53;  // X轴与底部的间距
    _rightMargin = 20;   // X轴最大值与右边的间距
    _xAxisLeftMargin = 4.0;     // X轴最小刻度(绘制点)与左边的间距
    
    self.yAxisMinValue = 0;
    self.yAxisMaxValue = 30;
    self.yAxisScaleCount = 7;
    
    // Y轴刻度
    self.yAxisView = [[AUXElectricityConsumptionCurveYAxisView alloc] initWithFrame:self.bounds];
    [self addSubview:self.yAxisView];
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(_leftMargin, 0, CGRectGetWidth(self.frame) - _leftMargin - _rightMargin, CGRectGetHeight(self.frame) - 20)];
    self.scrollView.showsHorizontalScrollIndicator = NO;
    [self addSubview:self.scrollView];
    
    self.scrollViewTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionTapScrollView:)];
    [self.scrollView addGestureRecognizer:self.scrollViewTapGesture];
    
    // X轴刻度
    self.xAxisView = [[AUXElectricityConsumptionCurveXAxisView alloc] initWithFrame:self.scrollView.bounds];
    [self.scrollView addSubview:self.xAxisView];
    
    // 选中的节点
    self.selectedView = [[AUXElectricityConsumptionSelectedView alloc] initWithFrame:self.scrollView.bounds];
    [self.scrollView addSubview:self.selectedView];
    
    self.scaleFont = [UIFont systemFontOfSize:12];
    self.scaleColor = [UIColor lightGrayColor];
    self.lineColor = [UIColor colorWithHexString:@"F6F6F6"];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.yAxisView.frame = self.bounds;
    [self updateCurveView];
}

- (void)updateCurveView {
    // 计算Y轴刻度的最大值和最小值 (度数)
    CGFloat minValue = MAXFLOAT;
    CGFloat maxValue = 0;
    
    // 获取曲线的最大值和最小值 (度数)
    [self getMaxAndMinValueForPointArray:self.pointModelList minValue:&minValue maxValue:&maxValue];
    
    // 最小值向下取整
    minValue = floor(minValue);
    // 最大值向上取整
    maxValue = ceil(maxValue);
    
    // 刻度间隔值
    NSInteger intervalValue = [self calculateIntervalValue:maxValue count:self.yAxisScaleCount - 1];
    
    if (intervalValue > 0) {
        self.yAxisMinValue = 0;
        self.yAxisMaxValue = intervalValue * (self.yAxisScaleCount - 1);
    }
    
    // 更新坐标系统
    [self createCoordinateSystem];
    // 更新Y轴
    self.yAxisView.axisPoints = self.pointsAtYAxis;
    self.yAxisView.lineWidth = _lineWidth;
    [self.yAxisView setNeedsDisplay];
    
    self.scrollView.frame = CGRectMake(_leftMargin, 0, CGRectGetWidth(self.frame) - _leftMargin - _rightMargin, CGRectGetHeight(self.frame));
    
    // 更新X轴
    AUXCurveAxisPoint *lastXPoint = self.pointsAtXAxis.lastObject;
    CGFloat width = lastXPoint.point.x + _xScaleInterval / 2.0;
    CGRect frame = CGRectMake(0, 0, width, CGRectGetHeight(self.scrollView.frame));
    
    self.xAxisView.frame = frame;
    self.xAxisView.axisPoints = self.pointsAtXAxis;
    self.xAxisView.selectedIndex = -1;
    [self.xAxisView setNeedsDisplay];
    
    self.scrollView.contentSize = self.xAxisView.frame.size;
    
    // 更新各个节点的X轴坐标
    [self updatePointModelPointX];
    
    // 创建或更新曲线图
    if (!self.curveView) {
        self.curveView = [[AUXElectricityConsumptionInternalCurveView alloc] init];
        [self.scrollView addSubview:self.curveView];
    }
    
    self.curveView.frame = frame;
    self.curveView.pointModelArray = self.pointModelList;
    [self.curveView updateCurve];
    
    self.selectedView.frame = frame;
    [self.selectedView selectPointModel:nil];
    [self.scrollView bringSubviewToFront:self.selectedView];
}

/// 创建坐标系统
- (void)createCoordinateSystem {
    CGFloat width = CGRectGetWidth(self.frame);
    CGFloat height = CGRectGetHeight(self.frame);
    
    _xScaleInterval = 30.0;
    
    // Y轴
    {
        NSInteger valueStep = (self.yAxisMaxValue - self.yAxisMinValue) / (self.yAxisScaleCount - 1);   // Y轴刻度值步进
        _yScaleStep = valueStep;
        
        CGFloat maxScaleWidth = _leftMargin;
        
        // 先创建Y轴刻度值，得出刻度最大宽度
        self.pointsAtYAxis = [NSMutableArray new];
        for (NSInteger value = self.yAxisMinValue; value <= self.yAxisMaxValue; value += valueStep) {
            NSString *scaleString = [NSString stringWithFormat:@"%d", (int)value];
            CGSize scaleSize = AUXECGetStringSize(scaleString, self.scaleFont);
            
            if (scaleSize.width > maxScaleWidth) {
                maxScaleWidth = scaleSize.width + 10;
            }
            
            AUXCurveAxisPoint *axisPoint = [[AUXCurveAxisPoint alloc] init];
            axisPoint.scaleString = scaleString;
            axisPoint.scaleSize = scaleSize;
            [self.pointsAtYAxis addObject:axisPoint];
        }
        
        _leftMargin = maxScaleWidth;
        _lineWidth = width - _leftMargin - _rightMargin;
        
        // 刻度间隔距离
        CGFloat distance = (height - _topMargin - _bottomMargin) / (CGFloat)(self.yAxisScaleCount - 1);
        _yScaleInterval = distance;
        
        // 原点位置
        CGPoint origin = CGPointMake(_leftMargin, height - _bottomMargin);
        
        // 计算Y轴刻度坐标
        [self.pointsAtYAxis enumerateObjectsUsingBlock:^(AUXCurveAxisPoint * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            CGPoint point = CGPointMake(origin.x, origin.y - idx * distance);
            obj.point = point;
        }];
    }
    
    // X轴
    [self createXAxisCoordinate];
}

/// 创建X轴 (注意：要先创建了Y轴之后，再创建X轴)
- (void)createXAxisCoordinate {
    
    self.pointsAtXAxis = [[NSMutableArray alloc] init];
    
    NSInteger minValue = 0;
    NSInteger maxValue = -1;
    
    switch (self.dateType) {
        case AUXElectricityCurveDateTypeDay:
            minValue = 0;
            maxValue = 23;
            break;
            
        case AUXElectricityCurveDateTypeMonth:
            minValue = 1;
            maxValue = self.numberOfDaysForMonth;
            break;
            
        case AUXElectricityCurveDateTypeYear:
            minValue = 1;
            maxValue = 12;
            break;
            
        default:
            break;
    }
    
    CGPoint origin = self.pointsAtYAxis.firstObject.point;
    origin.x = _xScaleInterval / 2.0;
    
    for (NSInteger value = minValue; value <= maxValue; value++, origin.x += _xScaleInterval) {
        
        NSString *scaleString = [NSString stringWithFormat:@"%d", (int)value];
        CGSize scaleSize = AUXECGetStringSize(scaleString, self.scaleFont);
        
        AUXCurveAxisPoint *axisPoint = [[AUXCurveAxisPoint alloc] init];
        axisPoint.scaleString = scaleString;
        axisPoint.scaleSize = scaleSize;
        axisPoint.point = origin;
        [self.pointsAtXAxis addObject:axisPoint];
    }
    
    origin = self.pointsAtXAxis.firstObject.point;
}

- (void)updatePointModelPointX {
    // 根据节点的度数，计算节点的位置
    for (AUXElectricityConsumptionCurvePointModel *pointModel in self.pointModelList) {
        pointModel.point = [self convertValueToPoint:CGPointMake(pointModel.xValue, pointModel.totalElectricity) dateType:self.dateType];
    }
}

#pragma mark Getters & Setters

- (NSInteger)numberOfDaysForMonth {
    return [NSDate numberOfDaysInMonth:self.month forYear:self.year];
}

- (void)setUnitString:(NSString *)unitString {
    _unitString = unitString;
    self.yAxisView.unitString = unitString;
}

- (void)setLineColor:(UIColor *)lineColor {
    _lineColor = lineColor;
    self.yAxisView.lineColor = lineColor;
}

- (void)setScaleColor:(UIColor *)scaleColor {
    _scaleColor = scaleColor;
    self.yAxisView.scaleColor = scaleColor;
}

- (void)setScaleFont:(UIFont *)scaleFont {
    _scaleFont = scaleFont;
    self.yAxisView.scaleFont = scaleFont;
}

- (void)setDateType:(AUXElectricityCurveDateType)dateType {
    _dateType = dateType;
    self.selectedView.dateType = dateType;
    
    if (_dateType == AUXElectricityCurveDateTypeDay) {
        self.yAxisView.xUnitString = @"(时)";
    } else if (_dateType == AUXElectricityCurveDateTypeMonth) {
        self.yAxisView.xUnitString = @"(日)";
    } else if (_dateType == AUXElectricityCurveDateTypeYear) {
        self.yAxisView.xUnitString = @"(月)";
    }
    
    
}

- (void)setOldDevice:(BOOL)oldDevice {
    _oldDevice = oldDevice;
    self.selectedView.oldDevice = oldDevice;
}

#pragma mark Actions

- (void)actionTapScrollView:(UITapGestureRecognizer *)tapGesture {
    
    CGPoint location = [tapGesture locationInView:self.xAxisView];
    
    // 计算当前点击位置对应哪个X轴刻度
    CGFloat multiplier = fabs(location.x - _xScaleInterval / 2.0) / _xScaleInterval;
    NSInteger index = AUXAdjustFloatValue(multiplier, 1.0);
    
    NSInteger count = self.pointModelList.count;
    
    if (index < 0 || index >= count) {
        return;
    }
    
    AUXElectricityConsumptionCurvePointModel *selectedPointModel = self.pointModelList[index];
    
    // 选中X轴刻度
    self.xAxisView.selectedIndex = index;
    self.xAxisView.selectedValuePoint = selectedPointModel.point;
    [self.xAxisView setNeedsDisplay];
    
    // 选中曲线的节点
    
    [self.selectedView selectPointModel:selectedPointModel];
}

#pragma mark 坐标转换

/**
 将用电度数转换为坐标

 @param value value.x为时间，value.y为用电度数
 @return 坐标
 @warning 要先创建了Y轴之后再调用该方法。
 */
- (CGPoint)convertValueToPoint:(CGPoint)value dateType:(AUXElectricityCurveDateType)dateType {
    CGPoint point = CGPointZero;
    
    if (!self.pointsAtYAxis || self.pointsAtYAxis.count == 0) {
        return point;
    }
    
    CGPoint minYPoint = self.pointsAtYAxis.firstObject.point;
    
    // 计算 point.y 的值
    CGFloat yValue = value.y - self.yAxisMinValue;
    CGFloat multiplier = yValue / (CGFloat)_yScaleStep;
    
    point.y = minYPoint.y - (multiplier * _yScaleInterval);
    
    // 计算 point.x 的值
    CGFloat xValue;
    
    switch (dateType) {
        case AUXElectricityCurveDateTypeDay:    // 日用电曲线，X轴单位为小时，从0开始
            xValue = value.x - 0;
            break;
            
        case AUXElectricityCurveDateTypeMonth:  // 月用电曲线，X轴单位为日，从1开始
            xValue = value.x - 1;
            break;
            
        case AUXElectricityCurveDateTypeYear:   // 年用电曲线，X轴单位为月份，从1开始
            xValue = value.x - 1;
            break;
            
        default:
            break;
    }
    
    point.x = (0.5 + xValue) * _xScaleInterval;
    
    return point;
}

/// 获取节点列表中的最大值和最小值。
- (void)getMaxAndMinValueForPointArray:(NSArray<AUXElectricityConsumptionCurvePointModel *> *)pointModelArray minValue:(out CGFloat *)minValue maxValue:(out CGFloat *)maxValue {
    
    for (AUXElectricityConsumptionCurvePointModel *pointModel in pointModelArray) {
        if (pointModel.totalElectricity > *maxValue) {
            *maxValue = pointModel.totalElectricity;
        } else if (pointModel.totalElectricity < *minValue) {
            *minValue = pointModel.totalElectricity;
        }
    }
}

/**
 计算Y轴刻度间隔值 (Y轴最小刻度默认为0)

 @param maxValue 当前曲线数据的最大值
 @param count Y轴刻度区间数
 @return 刻度间隔值
 */
- (NSInteger)calculateIntervalValue:(NSInteger)maxValue count:(NSInteger)count {
    
    if (count == 0) {
        return 0;
    }
    
    // 商，向上取整
    CGFloat quotient = ceil(maxValue / (CGFloat)count);
    
    return quotient;
}

@end
