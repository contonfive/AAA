//
//  AUXDeviceControlChildTableViewCell.m
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2019/3/29.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXDeviceControlChildTableViewCell.h"
#import "AUXFaultInfo.h"
#import "AUXConfiguration.h"
#import "UIColor+AUXCustom.h"

@interface AUXDeviceControlChildTableViewCell ()<CAAnimationDelegate>

@property (weak, nonatomic) IBOutlet UIView *temperatureContentView;

@property (weak, nonatomic) IBOutlet UIImageView *backImageView;
@property (weak, nonatomic) IBOutlet UIView *powerOnView;
@property (weak, nonatomic) IBOutlet UIView *powerOffView;
@property (weak, nonatomic) IBOutlet UIView *offlineView;
@property (weak, nonatomic) IBOutlet UIButton *faultBtn;
@property (weak, nonatomic) IBOutlet UIImageView *faultImageView;

@property (weak, nonatomic) IBOutlet UILabel *ventilateLabel;


@property (weak, nonatomic) IBOutlet UIView *tempratureView;
@property (weak, nonatomic) IBOutlet UILabel *temperatureLabel;
@property (weak, nonatomic) IBOutlet UILabel *decimalTemperatureLabel;
@property (weak, nonatomic) IBOutlet UILabel *temperatureUnitLabel;
@property (weak, nonatomic) IBOutlet UIButton *coolBtn;
@property (weak, nonatomic) IBOutlet UIButton *heatUpBtn;

@property (weak, nonatomic) IBOutlet UIButton *powerOnBtn;


@property (weak, nonatomic) IBOutlet UIView *powerOnIndoorView;
@property (weak, nonatomic) IBOutlet UIView *powerOffIndoorView;

@property (weak, nonatomic) IBOutlet UILabel *powerOnInDoorTempratureLabel;
@property (weak, nonatomic) IBOutlet UILabel *powerOffInDoorTempratureLabel;

@property (weak, nonatomic) IBOutlet UIImageView *indicatorImageView;

@property (nonatomic, assign, readonly) CGFloat dragRadius;     // 拖拽半径

/// 标识当前是否正在拖拽调节温度
@property (nonatomic, assign) BOOL draggingIndicator;

@property (nonatomic, assign) BOOL movingIndicator;             // 指示器是否移动中(动画)

/// 指示器轨迹动画时间
@property (nonatomic, assign, readonly) NSTimeInterval indicatorAnimationDuration;

/// 当前温度指示器所在的角度
@property (nonatomic, assign) CGFloat angle;

@property (nonatomic, strong) NSTimer *changingTimer;
@property (nonatomic, assign) CGFloat targetTemperature;

@property (nonatomic, assign) CGFloat temperature;      // 设置温度
@property (nonatomic, assign) CGFloat roomTemperature;  // 室内温度
@property (nonatomic, assign) AirConFunction mode;      // 模式
@property (nonatomic, assign) BOOL powerOn;             // 开关机状态
@property (nonatomic, assign) BOOL hasRoomTemperature;  // 是否显示室内温度。默认为YES。
@property (nonatomic, assign) BOOL halfTemperature;     // 温度调节步进，YES=0.5摄氏度，NO=1摄氏度。默认为YES。

@end

@implementation AUXDeviceControlChildTableViewCell

+ (CGFloat)properHeight {
    return 350;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    _temperature = kAUXTemperatureMin;
    _powerOn = YES;
    _hasRoomTemperature = YES;
    _halfTemperature = YES;
    self.faultBtn.hidden = YES;
    self.faultImageView.hidden = YES;
    [self addGesture];
    
    [self updateUIAnimated:NO];
    
    [self moveIndicatorToTemperature:self.temperature];
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

- (void)addGesture {
    
    // 拖拽指示器调节温度
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(actionDragIndicatorImageView:)];
    [self.indicatorImageView addGestureRecognizer:panGesture];
    self.indicatorImageView.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionTapTemperatureView:)];
    [self.temperatureContentView addGestureRecognizer:tapGestureRecognizer];
    self.temperatureContentView.userInteractionEnabled = YES;
    
}

#pragma mark - Getters & Setters
/// 指示器拖拽半径
- (CGFloat)dragRadius {
    CGFloat circleWidth = CGRectGetWidth(self.backImageView.frame);
    CGFloat indicatorWidth = CGRectGetWidth(self.indicatorImageView.frame);
    
    CGFloat radius = (circleWidth - indicatorWidth) / 2.0 + 12.0;
    
    return radius;
}

/// 指示器移动动画时间
- (NSTimeInterval)indicatorAnimationDuration {
    return 0.618;
}

- (void)setControlType:(AUXDeviceControlType)controlType {
    _controlType = controlType;
}

- (void)setDeviceFeature:(AUXDeviceFeature *)deviceFeature {
    _deviceFeature = deviceFeature;
    
    if (_deviceFeature) {
        self.hasRoomTemperature = _deviceFeature.hasRoomTemperature;
        self.halfTemperature = _deviceFeature.halfTemperature;
        [self showIndoorTemperature:!_deviceFeature.hasRoomTemperature];
    }
}

- (void)setDeviceStatus:(AUXDeviceStatus *)deviceStatus {
    _deviceStatus = deviceStatus;
    
    if (_deviceStatus) {
        self.temperature = _deviceStatus.temperature;
        self.roomTemperature = _deviceStatus.roomTemperature;
        self.mode = _deviceStatus.mode;
        self.powerOn = _deviceStatus.powerOn;
        
        // 开关机动画过程中、拖拽调节温度中、指示器移动中，忽略温度状态上报
        if (self.draggingIndicator || self.movingIndicator) {
            return;
        }
        
        [self updateUIAnimated:NO];
        [self updateTemperature:_deviceStatus.temperature roomTemperature:_deviceStatus.roomTemperature];
        [self moveIndicatorToTemperature:_deviceStatus.temperature];
        
        if (_deviceStatus.fault) {
            [self updateUIWithFaultCode:_deviceStatus.fault.code faultMessage:nil faultId:nil];
        } else if (_deviceStatus.filterInfo) {
            [self updateUIWithFaultCode:0 faultMessage:nil faultId:_deviceStatus.filterInfo.faultId];
        } else {
            [self hideFaultInfo];
        }
    }
}

- (void)setOffline:(BOOL)offline {
    _offline = offline;
}

#pragma mark - Actions

/// 拖拽圆点调节温度
- (void)actionDragIndicatorImageView:(UIGestureRecognizer *)sender {
    BOOL result = YES;
    switch (sender.state) {
        case UIGestureRecognizerStateBegan:
            self.draggingIndicator = YES;
            break;
            
        case UIGestureRecognizerStateChanged: {
            CGPoint point = [sender locationInView:self];
            result = [self dragDidChange:point];
        }
            break;
            
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded: {
            self.draggingIndicator = NO;
            if (result) {
                if (self.didAdjustTemperatureBlock) {
                    self.didAdjustTemperatureBlock(self.temperature);
                }
            }
        }
            
        default:
            self.draggingIndicator = NO;
            break;
    }
}

/// 点击圆环调节温度
- (void)actionTapTemperatureView:(UITapGestureRecognizer *)sender {
    
    if (!self.powerOn) {
        return ;
    }
    
    // 自动、送风模式不能调节温度
    if (self.mode == AirConFunctionAuto || self.mode == AirConFunctionVentilate) {
        return;
    }
    
    CGPoint point = [sender locationInView:self.temperatureContentView];
    
    if (CGRectContainsPoint(self.indicatorImageView.frame, point)) {
        return;
    }
    
    // 圆方程 (x - a)^2 + (y - b)^2 = r^2  点(a, b)为圆心  r为半径
    // 点P1(x1, y1)与圆的关系：
    // (x1 - a)^2 + (y1 - b)^2 > r^2    点P1在圆外
    // (x1 - a)^2 + (y1 - b)^2 = r^2    点P1在圆上
    // (x1 - a)^2 + (y1 - b)^2 < r^2    点P1在圆内
    
    // 圆心
    CGPoint circleCenter = self.backImageView.center;
    
    CGFloat x = point.x - circleCenter.x;
    CGFloat y = point.y - circleCenter.y;
    
    CGFloat radius = [self dragRadius];
    // 外圆半径
    CGFloat radiusOuter = radius + 25.0;
    // 内圆半径
    CGFloat radiusInner = radius - 25.0;
    
    CGFloat value = x * x + y * y;
    CGFloat value1 = radiusOuter * radiusOuter;
    CGFloat value2 = radiusInner * radiusInner;
    
    // 点不在圆环内
    if (value > value1 || value < value2) {
        return;
    }
    
    BOOL result = [self dragDidChange:point];
    
    if (result) {
        if (self.didAdjustTemperatureBlock) {
            self.didAdjustTemperatureBlock(self.temperature);
        }
    }
    
}

/// 温度减0.5度
- (IBAction)actionDecreaseTemperature:(id)sender {
    CGFloat temperatureStep = self.halfTemperature ? 0.5 : 1.0;
    
    if (self.temperature > kAUXTemperatureMin) {
        self.temperature -= temperatureStep;
        
        if (self.didAdjustTemperatureBlock) {
            self.didAdjustTemperatureBlock(self.temperature);
        }
    } else {
        if (self.showErrorMessageBlock) {
            self.showErrorMessageBlock(kAUXLocalizedString(@"DeviceControlMinTem"));
        }
    }
}

/// 温度增加0.5度
- (IBAction)actionIncreaseTemperature:(id)sender {
    CGFloat temperatureStep = self.halfTemperature ? 0.5 : 1.0;
    
    if (self.temperature < kAUXTemperatureMax) {
        self.temperature += temperatureStep;
        
        if (self.didAdjustTemperatureBlock) {
            self.didAdjustTemperatureBlock(self.temperature);
        }
    } else {
        if (self.showErrorMessageBlock) {
            self.showErrorMessageBlock(kAUXLocalizedString(@"DeviceControlMaxTem"));
        }
    }
}

- (IBAction)powerOnAtcion:(id)sender {
    if (self.powerOnBlock) {
        self.powerOnBlock();
    }
}


/// 跳转到故障列表
- (IBAction)actionGotoFaultList:(id)sender {
    if (self.pushToFaultVCBlock) {
        self.pushToFaultVCBlock();
    }
}

#pragma mark 显示或隐藏室内温度
- (void)showIndoorTemperature:(BOOL)hidden {
    if (self.controlType == AUXDeviceControlTypeSceneMultiDevice || self.controlType == AUXDeviceControlTypeGatewayMultiDevice) {
        self.powerOnIndoorView.hidden = YES;
        self.powerOffIndoorView.hidden = YES;
        return ;
    }
    if (!self.powerOn && self.mode == AirConFunctionVentilate) {
        self.powerOnIndoorView.hidden = NO;
        self.powerOffIndoorView.hidden = NO;
        return ;
    }
    
    self.powerOnIndoorView.hidden = hidden;
    self.powerOffIndoorView.hidden = hidden;
}

- (void)setIndoorTempratureAlpha:(CGFloat)alpha {
    self.powerOffIndoorView.alpha = alpha;
    self.powerOffView.alpha = alpha;
}

#pragma mark - 温度与角度 互转

/// 将温度转换为角度
- (CGFloat)getAngleWithTemperature:(CGFloat)temperature {
    return (temperature - kAUXTemperatureMin) / (kAUXTemperatureMax - kAUXTemperatureMin) * 270.0 + 135.0;
}

/// 将角度转换为温度
- (CGFloat)getTemperatureWithAngle:(CGFloat)angle {
    
    if (angle < 135.0) {
        angle += 360.0;
    }
    
    CGFloat value = (angle - 135.0) / 270.0 * (kAUXTemperatureMax - kAUXTemperatureMin) + kAUXTemperatureMin;
    
    CGFloat temperatureStep = self.halfTemperature ? 0.5 : 1.0;
    
    return AUXAdjustFloatValue(value, temperatureStep);
}

#pragma mark - 界面更新方法

- (void)updateUIWithFaultCode:(NSInteger)code faultMessage:(NSString *)faultMessage faultId:(NSString *)faultId {
    
    // 滤网故障
    if (faultId && [faultId isEqualToString:kAUXFilterFaultId]) {
        self.faultBtn.hidden = NO;
        self.faultImageView.hidden = NO;
        self.faultImageView.image = [UIImage imageNamed:@"device_icon_needclean"];
        [self.faultBtn setTitle:@"滤网需清洗" forState:UIControlStateNormal];
        return;
    }
    
    // 故障代码为 0x0100 的时候，是正常状态，即没有故障
    if (code == 0x0100) {
        [self hideFaultInfo];
        return;
    }
    
    NSString *title;
    
    if (code > 0) {
        title = @"发生故障";
    } else {
        title = faultMessage;
    }
    
    self.faultBtn.hidden = NO;
    self.faultImageView.hidden = NO;
    self.faultImageView.image = [UIImage imageNamed:@"common_icon_warn"];
    [self.faultBtn setTitle:title forState:UIControlStateNormal];
}

- (void)hideFaultInfo {
    self.faultBtn.hidden = YES;
    self.faultImageView.hidden = YES;
}

/// 更新UI
- (void)updateUIAnimated:(BOOL)animated {
    
    self.ventilateLabel.hidden = YES;
    if (self.offline) {
        self.offlineView.hidden = NO;
        self.powerOnView.hidden = YES;
        self.powerOffView.hidden = YES;
        self.backImageView.image = [UIImage imageNamed:@"device_bg_circle_black"];
    }
    
    if (self.powerOn) { // 设备处于开机状态
        self.powerOnView.hidden = NO;
        self.powerOffView.hidden = YES;
        self.offlineView.hidden = YES;
        
        NSString *imageString;
        NSString *indocatorImageString;
        UIColor *color;
        switch (self.mode) {
            case AirConFunctionCool:
            case AirConFunctionDehumidify:
                imageString = @"device_bg_circle_blue";
                indocatorImageString = @"device_bg_slide_blue";
                self.indicatorImageView.hidden = NO;
                self.powerOnInDoorTempratureLabel.hidden = NO;
                self.coolBtn.hidden = NO;
                self.heatUpBtn.hidden = NO;
                color = [UIColor colorWithHexString:@"4E78A9"];
                break;
            case AirConFunctionHeat:
                imageString = @"device_bg_circle_yellow";
                indocatorImageString = @"device_bg_slide_yellow";
                self.indicatorImageView.hidden = NO;
                self.powerOnInDoorTempratureLabel.hidden = NO;
                self.coolBtn.hidden = NO;
                self.heatUpBtn.hidden = NO;
                color = [UIColor colorWithHexString:@"F8981D"];
                break;
            case AirConFunctionAuto:
            case AirConFunctionVentilate:
                imageString = @"device_bg_circle_green";
                indocatorImageString = @"device_bg_slide_green";
                self.indicatorImageView.hidden = YES;
                self.powerOnInDoorTempratureLabel.hidden = NO;
                self.coolBtn.hidden = YES;
                self.heatUpBtn.hidden = YES;
                color = [UIColor colorWithHexString:@"4EA4A9"];
                break;
            default:
                imageString = @"device_bg_circle_blue";
                indocatorImageString = @"device_bg_slide_blue";
                self.indicatorImageView.hidden = NO;
                self.powerOnInDoorTempratureLabel.hidden = NO;
                self.coolBtn.hidden = NO;
                self.heatUpBtn.hidden = NO;
                color = [AUXConfiguration sharedInstance].blueColor;
                break;
        }
        
        if ((self.controlType == AUXDeviceControlTypeSceneMultiDevice || self.controlType == AUXDeviceControlTypeGatewayMultiDevice) && self.mode == AirConFunctionVentilate) {
            self.powerOnView.hidden = YES;
            self.ventilateLabel.hidden = NO;
        }
        
        self.backImageView.image = [UIImage imageNamed:imageString];
        self.indicatorImageView.image = [UIImage imageNamed:indocatorImageString];
        
        self.temperatureLabel.textColor = color;
        self.decimalTemperatureLabel.textColor = color;
        self.temperatureUnitLabel.textColor = color;
        
    } else {
        self.powerOnView.hidden = YES;
        self.powerOffView.hidden = NO;
        self.offlineView.hidden = YES;
        self.indicatorImageView.hidden = YES;
        
        self.backImageView.image = [UIImage imageNamed:@"device_bg_circle_black"];
        
    }
}

/// 显示温度设置界面以及室内温度
- (void)showTemperatureCircleViewAnimated:(BOOL)animated completion:(void (^)(void))completion {
    if (animated) {
        
        // 送风模式下，不显示设置温度，室内温度显示在中间
        if (self.hasRoomTemperature && self.mode != AirConFunctionVentilate) {
            [self showIndoorTemperature:NO];
            [self setIndoorTempratureAlpha:0];
        }
        
        // 自动、送风模式下，不能调节温度
        BOOL shouldMoveIndicator = (self.mode != AirConFunctionAuto && self.mode != AirConFunctionVentilate);
        
        if (shouldMoveIndicator) {
            self.indicatorImageView.hidden = YES;
            [self moveIndicatorToTemperature:kAUXTemperatureMin];
        } else {
            [self moveIndicatorToTemperature:self.temperature];
        }
        
        [self setIndoorTempratureAlpha:1];
        
        if (shouldMoveIndicator) {
            @weakify(self);
            [self showIndicatorImageViewAnimated:animated completion:^{
                @strongify(self);
                [self moveIndicatorToTemperature:self.temperature animated:YES];
                [self changeTemperatureFromMinTo:self.temperature animated:YES];
            }];
        } else {
            self.movingIndicator = NO;
        }
        
        if (completion) {
            completion();
        }
    } else {
        
        if (self.hasRoomTemperature) {
            [self showIndoorTemperature:(self.mode == AirConFunctionVentilate)];
        }
        
        [self moveIndicatorToTemperature:self.temperature];
        [self updateTemperature:self.temperature roomTemperature:self.roomTemperature];

        if (completion) {
            completion();
        }
    }
}

/// 使用 timer 来动态化更改温度值
- (void)changeTemperatureFromMinTo:(CGFloat)temperature animated:(BOOL)animated {
    
    CGFloat difference = temperature - kAUXTemperatureMin;
    CGFloat count = difference / 0.5;
    NSTimeInterval duration = self.indicatorAnimationDuration / count;
    
    _targetTemperature = temperature;
    
    _temperature = kAUXTemperatureMin;
    [self updateTemperature:_temperature roomTemperature:_roomTemperature];
    
    self.changingTimer = [NSTimer scheduledTimerWithTimeInterval:duration target:self selector:@selector(changeTemperatureByTimer) userInfo:nil repeats:YES];
}

- (void)changeTemperatureByTimer {
    
    if (_temperature < _targetTemperature) {
        _temperature += 0.5;
        [self updateTemperature:_temperature roomTemperature:_roomTemperature];
    } else {
        [self.changingTimer invalidate];
        self.changingTimer = nil;
    }
}

/// 隐藏温度设置界面以及室内温度
- (void)hideTemperatureCircleViewAnimated:(BOOL)animated completion:(void (^)(void))completion {
    [self showIndoorTemperature:NO];
    [self setIndoorTempratureAlpha:1];
    
    if (completion) {
        completion();
    }
}

/// 显示温度调节圆点出现动画
- (void)showIndicatorImageViewAnimated:(BOOL)animated completion:(void (^)(void))completion {
    if (animated) {
        self.indicatorImageView.hidden = NO;
        self.indicatorImageView.transform = CGAffineTransformMakeScale(0.1, 0.1);
        
        [UIView animateWithDuration:0.35 animations:^{
            self.indicatorImageView.transform = CGAffineTransformMakeScale(1.2, 1.2);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.2 animations:^{
                self.indicatorImageView.transform = CGAffineTransformMakeScale(1.0, 1.0);
            } completion:^(BOOL finished) {
                if (completion) {
                    completion();
                }
            }];
        }];
    } else {
        self.indicatorImageView.hidden = NO;
        if (completion) {
            completion();
        }
    }
}

/// 更新设置温度、室内温度值
- (void)updateTemperature:(CGFloat)temperature roomTemperature:(CGFloat)roomTemperature {
    // 送风模式下，无设置温度，圆圈中间显示室内温度
    temperature = (self.mode == AirConFunctionVentilate) ? roomTemperature : temperature;
    
    NSString *temperatureString = [NSString stringWithFormat:@"%f" , temperature];
    NSArray *temperatureArray = [NSMutableArray array];
    if ([temperatureString containsString:@"."]) {
        NSInteger index = [temperatureString rangeOfString:@"."].location;
        
        if (temperatureString.length >= index + 2) {
            temperatureString = [temperatureString substringToIndex:index + 2];
        }
        temperatureArray = [[temperatureString componentsSeparatedByString:@"."] mutableCopy];
    }
    
    NSInteger nTemperature = (NSInteger)temperature;
    
    self.decimalTemperatureLabel.text = (temperature - nTemperature == 0.5) ? @".5" : @".0";
    self.temperatureLabel.text = temperatureArray.firstObject ? temperatureArray.firstObject : temperatureString;
    
    self.powerOnInDoorTempratureLabel.text = [NSString stringWithFormat:@"当前%.1f°C" , self.roomTemperature];
    self.powerOffInDoorTempratureLabel.text = [NSString stringWithFormat:@"当前%.1f°C" , self.roomTemperature];
    
    if (self.deviceStatus.mode == AirConFunctionVentilate) {
        self.powerOnInDoorTempratureLabel.text = @"当前温度";
        
        NSString *lastObject = (NSString *)temperatureArray.lastObject;
        NSString *decimalTemperature = !AUXWhtherNullString(lastObject) ? [NSString stringWithFormat:@".%ld" , [lastObject integerValue]] : @".0";
        self.decimalTemperatureLabel.text = decimalTemperature;
    }
}

/// 拖拽温度指示器
- (BOOL)dragDidChange:(CGPoint)point {
    
    CGPoint circleCenter = self.backImageView.center;
    
    CGFloat x = point.x - circleCenter.x;
    CGFloat y = point.y - circleCenter.y;
    
    CGFloat theta = 0;  // 弧度
    CGFloat angle = 0;  // 角度
    
    if (x != 0) {
        theta = atan(y / x);
        
        if (x < 0) {    // 第二、三象限
            theta += M_PI;
        }
        
        if (x > 0 && y < 0) {   // 第四象限
            theta += M_PI * 2;
        }
    } else {
        if (y > 0) {
            theta = M_PI_2;     // 90°
        } else {
            theta = M_PI_2 * 3; // 270°
        }
    }
    
    // 将弧度转换为角度
    angle = theta / M_PI * 180.0;
    
    // 45° ~ 135° 不响应拖动
    if (angle > 45.0 && angle < 135.0) {
        if (self.angle <= 45.0) {
            angle = 45.0;
        } else {
            angle = 135.0;
        }
        
        theta = angle / 180.0 * M_PI;
        return NO;
    }
    
    self.angle = angle;
    
    [self moveIndicatorToRadian:theta];
    
    _temperature = [self getTemperatureWithAngle:angle];
    [self updateTemperature:_temperature roomTemperature:_roomTemperature];
    
    if (_temperature == kAUXTemperatureMin) {
        
        if (self.showErrorMessageBlock) {
            self.showErrorMessageBlock(kAUXLocalizedString(@"DeviceControlMinTem"));
        }
    } else if (_temperature == kAUXTemperatureMax) {
        if (self.showErrorMessageBlock) {
            self.showErrorMessageBlock(kAUXLocalizedString(@"DeviceControlMaxTem"));
        }
    }
    return YES;
}

/// 将温度调节圆点移动到对应的弧度
- (void)moveIndicatorToRadian:(CGFloat)radian {
    
    CGFloat radius = [self dragRadius];
    CGPoint circleCenter = self.backImageView.center;
    
    CGFloat x1 = radius * cos(radian);
    CGFloat y1 = radius * sin(radian);
    
    CGPoint offsetPoint = CGPointMake(circleCenter.x + x1, circleCenter.y + y1);
    
    self.indicatorImageView.center = offsetPoint;
}

/// 将温度调节圆点移动到对应的温度
- (void)moveIndicatorToTemperature:(CGFloat)temperature {
    [self moveIndicatorToTemperature:temperature animated:NO];
}
/// 将温度调节圆点移动到对应的温度
- (void)moveIndicatorToTemperature:(CGFloat)temperature animated:(BOOL)animated {
    
    self.angle = [self getAngleWithTemperature:temperature];
    
    CGFloat radian = self.angle / 180.0 * M_PI;
    
    [self moveIndicatorToRadian:radian];
    
    if (animated) {
        CGFloat angle = [self getAngleWithTemperature:temperature];
        CGFloat radian = angle / 180.0 * M_PI;
        
        UIBezierPath *path = [UIBezierPath bezierPath];
        [path addArcWithCenter:self.backImageView.center radius:[self dragRadius] startAngle:135.0/180.0*M_PI endAngle:radian clockwise:YES];
        
        CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
        animation.path = path.CGPath;
        animation.duration = self.indicatorAnimationDuration;
        animation.repeatCount = 1.0;
        animation.removedOnCompletion = YES;
        animation.fillMode = kCAFillModeForwards;
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
        animation.delegate = self;
        
        self.movingIndicator = YES;
        [self.indicatorImageView.layer addAnimation:animation forKey:@"position"];
    }
}

/// 移动动画结束
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    self.movingIndicator = NO;
}

@end
