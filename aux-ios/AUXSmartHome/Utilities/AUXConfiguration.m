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

#import "AUXConfiguration.h"
#import "AUXDefinitions.h"
#import "UIColor+AUXCustom.h"

@implementation AUXConfiguration

+ (instancetype)sharedInstance {
    static AUXConfiguration *configuration = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        configuration = [[AUXConfiguration alloc] init];
    });
    
    return configuration;
}

- (instancetype)init {
    self = [super init];
    
    if (self) {
        [self initDefaultConfiguration];
    }
    
    return self;
}

- (void)initDefaultConfiguration {
    
    self.blueColor = [UIColor colorWithHex:0x256BBD];
    self.greenColor = [UIColor colorWithHex:0x14C1BB];
    self.orangeColor = [UIColor colorWithHex:0xF6AC2E];
    
    self.curveNormalColor = [UIColor colorWithHex:0x5835b1];
    self.curvePeakColor = [UIColor colorWithHex:0x03d6e3];
    self.curveValleyColor = [UIColor colorWithHex:0x2977e2];
    self.curveCommonColor = [UIColor colorWithHex:0x256BBD];
}

#pragma mark - Getters

/// 设备型号字典
- (NSMutableDictionary<NSString *,AUXDeviceModel *> *)deviceModelDictionary {
    if (!_deviceModelDictionary) {
        _deviceModelDictionary = [[NSMutableDictionary alloc] init];
    }
    
    return _deviceModelDictionary;
}

#pragma mark 场景模式
+ (AUXSceneModelType)getSceneMode:(NSString *)modeName {
    
    if ([modeName isEqualToString:@"制冷"]) {
        return AUXSceneModelTypeOfCool;
    } else if ([modeName isEqualToString:@"制热"]) {
        return AUXSceneModelTypeOfHeat;
    } else if ([modeName isEqualToString:@"送风"]) {
        return AUXSceneModelTypeOfVentilate;
    } else if ([modeName isEqualToString:@"除湿"]) {
        return AUXSceneModelTypeOfDehumidify;
    } else {
        return AUXSceneModelTypeOfAuto;
    }
}

+ (NSString *)getSceneModeName:(AUXSceneModelType)mode {
    NSString *name;
    
    switch (mode) {
        case AUXSceneModelTypeOfCool:
            name = @"制冷";
            break;
            
        case AUXSceneModelTypeOfHeat:
            name = @"制热";
            break;
            
        case AUXSceneModelTypeOfVentilate:
            name = @"送风";
            break;
            
        case AUXSceneModelTypeOfDehumidify:
            name = @"除湿";
            break;
            
        case AUXSceneModelTypeOfAuto:
            name = @"自动";
            break;
            
        default:
            name = @"";
            break;
    }
    
    return name;
}

#pragma mark - SDK 模式、风速
+ (NSString *)getModeName:(AirConFunction)mode {
    NSString *name;
    
    switch (mode) {
        case AirConFunctionCool:
            name = @"制冷";
            break;
            
        case AirConFunctionHeat:
            name = @"制热";
            break;
            
        case AirConFunctionVentilate:
            name = @"送风";
            break;
            
        case AirConFunctionDehumidify:
            name = @"除湿";
            break;
            
        case AirConFunctionAuto:
            name = @"自动";
            break;
            
        default:
            name = @"";
            break;
    }
    
    return name;
}

+ (NSString *)getWindSpeedName:(WindSpeed)windSpeed {
    NSString *name;
    
    switch (windSpeed) {
        case WindSpeedSilence:
            name = @"静音";
            break;
            
        case WindSpeedMin:
            name = @"低档";
            break;
            
        case WindSpeedMidMin:
            name = @"中低";
            break;
            
        case WindSpeedMid:
            name = @"中档";
            break;
            
        case WindSpeedMidMax:
            name = @"中高";
            break;
            
        case WindSpeedMax:
            name = @"高档";
            break;
        
        case WindSpeedTurbo:
            name = @"强力";
            break;
            
        case WindSpeedAuto:
        default:
            name = @"自动";
            break;
    }
    
    return name;
}

#pragma mark - 服务器 模式、风速

+ (WindGearType)getSDKWindGearTypeWithMachineType:(AUXDeviceMachineType)machineType {
    WindGearType gearType;
    
    switch (machineType) {
        case AUXDeviceMachineTypeHang:  // 挂机
            gearType = WindGearType1;
            break;
            
        default:    // 柜机
            gearType = WindGearType2;
            break;
    }
    
    return gearType;
}


+ (AirConFunction)getServerDeviceMode:(NSString *)modeName {
    
    if ([modeName isEqualToString:@"制冷"]) {
        return AirConFunctionCool;
    } else if ([modeName isEqualToString:@"制热"]) {
        return AirConFunctionHeat;
    } else if ([modeName isEqualToString:@"送风"]) {
        return AirConFunctionVentilate;
    } else if ([modeName isEqualToString:@"除湿"]) {
        return AirConFunctionDehumidify;
    } else {
        return AirConFunctionAuto;
    }
}

+ (NSString *)getServerModeName:(AUXServerDeviceMode)mode {
    NSString *name;
    
    switch (mode) {
        case AUXServerDeviceModeCool:
            name = @"制冷";
            break;
            
        case AUXServerDeviceModeHeat:
            name = @"制热";
            break;
            
        case AUXServerDeviceModeWind:
            name = @"送风";
            break;
            
        case AUXServerDeviceModeDry:
            name = @"除湿";
            break;
            
        case AUXServerDeviceModeAuto:
            name = @"自动";
            break;
            
        default:
            name = @"";
            break;
    }
    
    return name;
}

+ (NSString *)getServerWindSpeedName:(AUXServerWindSpeed)windSpeed {
    NSString *name;
    
    switch (windSpeed) {
        case AUXServerWindSpeedLow:
            name = @"低风";
            break;
            
        case AUXServerWindSpeedMid:
            name = @"中风";
            break;
            
        case AUXServerWindSpeedHigh:
            name = @"高风";
            break;
            
        case AUXServerWindSpeedMute:
            name = @"静音";
            break;
            
        case AUXServerWindSpeedAuto:
            name = @"自动";
            break;
            
        case AUXServerWindSpeedTurbo:
            name = @"强力";
            break;
            
        case AUXServerWindSpeedCustom:
        default:
            name = @"自定义";
            break;
    }
    
    return name;
}

+ (WindSpeed)getSDKWindSpeedWithServerWindSpeed:(AUXServerWindSpeed)serverWindSpeed {
    WindSpeed windSpeed;
    
    switch (serverWindSpeed) {
        case AUXServerWindSpeedMute:
            windSpeed = WindSpeedSilence;
            break;
            
        case AUXServerWindSpeedLow:
            windSpeed = WindSpeedMin;
            break;
            
        case AUXServerWindSpeedMid:
            windSpeed = WindSpeedMid;
            break;
            
        case AUXServerWindSpeedHigh:
            windSpeed = WindSpeedMax;
            break;
            
        case AUXServerWindSpeedAuto:
            windSpeed = WindSpeedAuto;
            break;
            
        case AUXServerWindSpeedTurbo:
            windSpeed = WindSpeedTurbo;
            break;
            
        case AUXServerWindSpeedCustom:
        default:
            windSpeed = WindSpeedMin;
            break;
    }
    
    return windSpeed;
}

+ (AUXServerWindSpeed)getServerWindSpeedWithSDKWindSpeed:(WindSpeed)windSpeed {
    AUXServerWindSpeed serverWindSpeed;
    
    switch (windSpeed) {
        case WindSpeedMin:
        case WindSpeedMidMin:
            serverWindSpeed = AUXServerWindSpeedLow;
            break;
            
        case WindSpeedMid:
            serverWindSpeed = AUXServerWindSpeedMid;
            break;
            
        case WindSpeedMidMax:
        case WindSpeedMax:
            serverWindSpeed = AUXServerWindSpeedHigh;
            break;
            
        case WindSpeedSilence:
            serverWindSpeed = AUXServerWindSpeedMute;
            break;
            
        case WindSpeedTurbo:
            serverWindSpeed = AUXServerWindSpeedTurbo;
            break;
            
        default:
            serverWindSpeed = AUXServerWindSpeedAuto;
            break;
    }
    
    return serverWindSpeed;
}

+ (AirConFunction)getSDKModeWithServerMode:(AUXServerDeviceMode)serverMode {
    AirConFunction mode;
    
    switch (serverMode) {
        case AUXServerDeviceModeCool:
            mode = AirConFunctionCool;
            break;
            
        case AUXServerDeviceModeHeat:
            mode = AirConFunctionHeat;
            break;
            
        case AUXServerDeviceModeWind:
            mode = AirConFunctionVentilate;
            break;
            
        case AUXServerDeviceModeDry:
            mode = AirConFunctionDehumidify;
            break;
            
        default:
            mode = AirConFunctionAuto;
            break;
    }
    
    return mode;
}

+ (AUXServerDeviceMode)getServerModeWithSDKMode:(AirConFunction)mode {
    AUXServerDeviceMode serverMode;
    
    switch (mode) {
        case AirConFunctionCool:
            serverMode = AUXServerDeviceModeCool;
            break;
            
        case AirConFunctionHeat:
            serverMode = AUXServerDeviceModeHeat;
            break;
            
        case AirConFunctionVentilate:
            serverMode = AUXServerDeviceModeWind;
            break;
            
        case AirConFunctionDehumidify:
            serverMode = AUXServerDeviceModeDry;
            break;
            
        default:
            serverMode = AUXServerDeviceModeAuto;
            break;
    }
    
    return serverMode;
}

+ (NSString *)getSmartPowerModeNameWithMode:(AUXSmartPowerMode)mode {
    NSString *name = nil;
    
    switch (mode) {
        case AUXSmartPowerModeFast:
            name = @"极速模式";
            break;
            
        case AUXSmartPowerModeBalance:
            name = @"均衡模式";
            break;
            
        default:
            name = @"标准模式";
            break;
    }
    
    return name;
}

#pragma mark - 界面构造

+ (NSDictionary<NSNumber *,NSDictionary *> *)getDeviceModesDictionary {
    
    return @{
             @(AirConFunctionCool): @{@"title": @"制冷",  @"imageNor": @"device_icon_cold", @"type": @(AirConFunctionCool)},
             
             @(AirConFunctionHeat): @{@"title": @"制热",  @"imageNor": @"device_icon_hot", @"type": @(AirConFunctionHeat)},
             
             @(AirConFunctionDehumidify): @{@"title": @"除湿",  @"imageNor": @"device_icon_dry", @"type": @(AirConFunctionDehumidify)},
             
             @(AirConFunctionVentilate): @{@"title": @"送风",  @"imageNor": @"device_icon_wind", @"type": @(AirConFunctionVentilate)},
             
             @(AirConFunctionAuto): @{@"title": @"自动",  @"imageNor": @"device_icon_auto", @"type": @(AirConFunctionAuto)}
             };
}

+ (NSDictionary<NSNumber *,NSDictionary *> *)getDeviceWindsDictionary {
    
    return @{
             @(WindSpeedSilence): @{@"title": @"静音",  @"imageNor": @"device_icon_fan1", @"type": @(WindSpeedSilence)},
             
             @(WindSpeedMin): @{@"title": @"低档",  @"imageNor": @"device_icon_fan2", @"type": @(WindSpeedMin)},
             
             @(WindSpeedMidMin): @{@"title": @"中低",  @"imageNor": @"device_icon_fan3", @"type": @(WindSpeedMidMin)},
             
             @(WindSpeedMid): @{@"title": @"中档",  @"imageNor": @"device_icon_fan4", @"type": @(WindSpeedMid)},
             
             @(WindSpeedMidMax): @{@"title": @"中高",  @"imageNor": @"device_icon_fan5", @"type": @(WindSpeedMidMax)},
             
             @(WindSpeedMax): @{@"title": @"高档",  @"imageNor": @"device_icon_fan6", @"type": @(WindSpeedMax)},
             
             @(WindSpeedTurbo): @{@"title": @"强力",  @"imageNor": @"device_icon_fan7", @"type": @(WindSpeedTurbo)},
             
             @(WindSpeedAuto): @{@"title": @"自动",  @"imageNor": @"device_icon_fan8", @"type": @(WindSpeedAuto)}
             };
}


+ (NSDictionary<NSNumber *,NSDictionary *> *)getServerWindsDictionary {
    
    return @{
             @(AUXServerWindSpeedMute): @{@"title": @"静音",  @"imageNor": @"device_icon_fan1", @"type": @(AUXServerWindSpeedMute)},
             
             @(AUXServerWindSpeedLow): @{@"title": @"低档",  @"imageNor": @"device_icon_fan2", @"type": @(AUXServerWindSpeedLow)},
             
             @(AUXServerWindSpeedMid): @{@"title": @"中档",  @"imageNor": @"device_icon_fan4", @"type": @(AUXServerWindSpeedMid)},
             
             @(AUXServerWindSpeedHigh): @{@"title": @"高档",  @"imageNor": @"device_icon_fan6", @"type": @(AUXServerWindSpeedHigh)},
             
             @(AUXServerWindSpeedTurbo): @{@"title": @"强力",  @"imageNor": @"device_icon_fan7", @"type": @(AUXServerWindSpeedTurbo)}
             };
}

+ (NSDictionary<NSNumber *,NSDictionary *> *)getDeviceFunctionsDictionary {
    
    return @{
             @(AUXDeviceFunctionTypeWindSpeed): @{@"title": @"风速",  @"imageNor": @"device_btn_fan6", @"type": @(AUXDeviceFunctionTypeWindSpeed)},
             
             @(AUXDeviceFunctionTypeMode): @{@"title": @"模式",  @"imageNor": @"device_btn_auto", @"type": @(AUXDeviceFunctionTypeMode)},
             @(AUXDeviceFunctionTypePower): @{@"title": @"开关",  @"imageNor": @"device_btn_off", @"imageSel": @"device_btn_on", @"type": @(AUXDeviceFunctionTypePower)},
             @(AUXDeviceFunctionTypeCold): @{@"title": @"制冷",  @"imageNor": @"device_btn_cold", @"imageSel": @"device_btn_cold_selected", @"type": @(AUXDeviceFunctionTypeCold)},
             @(AUXDeviceFunctionTypeHot): @{@"title": @"制热",  @"imageNor": @"device_btn_hot", @"imageSel": @"device_btn_hot_selected", @"type": @(AUXDeviceFunctionTypeHot)},
             @(AUXDeviceFunctionTypeSwingUpDown): @{@"title": @"上下摆风", @"imageNor": @"device_btn_updown", @"imageSel": @"device_btn_updown_selected", @"type": @(AUXDeviceFunctionTypeSwingUpDown)},
             @(AUXDeviceFunctionTypeSwingLeftRight): @{@"title": @"左右摆风", @"imageNor": @"device_btn_leftright", @"imageSel": @"device_btn_leftright_selected", @"type": @(AUXDeviceFunctionTypeSwingLeftRight)},
             @(AUXDeviceFunctionTypeDisplay): @{@"title": @"屏显",  @"imageNor": @"device_btn_display", @"imageSel": @"device_btn_display_selected", @"type": @(AUXDeviceFunctionTypeDisplay)},
             @(AUXDeviceFunctionTypeECO): @{@"title": @"ECO", @"imageNor": @"device_btn_eco", @"imageSel": @"device_btn_eco_selected", @"type": @(AUXDeviceFunctionTypeECO)},
             @(AUXDeviceFunctionTypeElectricalHeating): @{@"title": @"电加热", @"imageNor": @"device_btn_heat", @"imageSel": @"device_btn_heat_selected", @"type": @(AUXDeviceFunctionTypeElectricalHeating)},
             @(AUXDeviceFunctionTypeSleep): @{@"title": @"睡眠", @"imageNor": @"device_btn_sleep", @"imageSel": @"device_btn_sleep_selected", @"type": @(AUXDeviceFunctionTypeSleep)},
             @(AUXDeviceFunctionTypeHealth): @{@"title": @"健康", @"imageNor": @"device_btn_health", @"imageSel": @"device_btn_health_selected", @"type": @(AUXDeviceFunctionTypeHealth)},
             @(AUXDeviceFunctionTypeClean): @{@"title": @"清洁", @"imageNor": @"device_btn_clean", @"imageSel": @"device_btn_clean_selected", @"type": @(AUXDeviceFunctionTypeClean)},
             @(AUXDeviceFunctionTypeMouldProof): @{@"title": @"防霉", @"imageNor": @"device_btn_mildew", @"imageSel": @"device_btn_mildew_selected", @"type": @(AUXDeviceFunctionTypeMouldProof)},
             @(AUXDeviceFunctionTypeChildLock): @{@"title": @"童锁", @"imageNor": @"device_btn_lock", @"imageSel": @"device_btn_lock_selected", @"type": @(AUXDeviceFunctionTypeChildLock)},
            @(AUXDeviceFunctionTypeComfortWind): @{@"title": @"舒风", @"imageNor": @"device_btn_comfortable", @"imageSel": @"device_btn_comfortable_selected" , @"type": @(AUXDeviceFunctionTypeComfortWind)}};
}

+ (NSDictionary<NSNumber *,NSDictionary *> *)getDeviceControlTableViewSectionInfosDictionary {
    return @{
             @(AUXDeviceFunctionTypeScheduler):
                 @{@"title": @"定时",
                   @"imageStr": @"device_icon_time",
                   @"type": @(AUXDeviceFunctionTypeScheduler),
                   @"rowCount": @(0),
                   @"canClicked": @(YES)},
             @(AUXDeviceFunctionTypeElectricityConsumptionCurve):
                 @{@"title": @"日用电曲线",
                   @"imageStr": @"device_icon_curve",
                   @"type": @(AUXDeviceFunctionTypeElectricityConsumptionCurve),
                   @"rowCount": @(1),
                   @"canClicked": @(YES)},
             @(AUXDeviceFunctionTypeLimitElectricity):
                 @{@"title": @"用电限制",@"imageStr": @"device_icon_limit",
                   @"type": @(AUXDeviceFunctionTypeLimitElectricity),
                   @"rowCount": @(0),
                   @"canClicked": @(YES)},
             @(AUXDeviceFunctionTypePeakValley):
                 @{@"title": @"峰谷节电",
                   @"imageStr" : @"device_icon_peak",
                   @"type": @(AUXDeviceFunctionTypePeakValley),
                   @"rowCount": @(0),
                   @"canClicked": @(YES)},
             @(AUXDeviceFunctionTypeSleepDIY):
                 @{@"title": @"睡眠DIY",
                   @"imageStr" : @"device_icon_sleepdiy",
                   @"type": @(AUXDeviceFunctionTypeSleepDIY),
                   @"rowCount": @(0),
                   @"canClicked": @(YES)},
             @(AUXDeviceFunctionTypeSmartPower):
                 @{@"title": @"智能用电",
                   @"imageStr" : @"device_icon_Intelligence",
                   @"type": @(AUXDeviceFunctionTypeSmartPower),
                   @"rowCount": @(0),
                   @"canClicked": @(YES)}
             };
}

#pragma mark - 获取图标

+ (NSString *)getDeviceListACModeIcon:(AirConFunction)mode {
    NSString *name;
    
    switch (mode) {
        case AirConFunctionCool:
            name = @"index_card_icon_mode_cool";
            break;
            
        case AirConFunctionHeat:
            name = @"index_card_icon_mode_heat";
            break;
            
        case AirConFunctionVentilate:
            name = @"index_card_icon_mode_wind";
            break;
            
        case AirConFunctionDehumidify:
            name = @"index_card_icon_mode_dry";
            break;
            
        case AirConFunctionAuto:
            name = @"index_card_icon_mode_auto";
            break;
            
        default:
            name = @"";
            break;
    }
    
    return name;
}

+ (NSString *)getDeviceListACWindSpeedIcon:(WindSpeed)windSpeed {
    NSString *name;
    
    switch (windSpeed) {
        case WindSpeedSilence:
            name = @"index_icon_wind1";
            break;
            
        case WindSpeedMin:
            name = @"index_icon_wind2";
            break;
            
        case WindSpeedMidMin:
            name = @"index_icon_wind3";
            break;
            
        case WindSpeedMid:
            name = @"index_icon_wind4";
            break;
            
        case WindSpeedMidMax:
            name = @"index_icon_wind5";
            break;
            
        case WindSpeedMax:
            name = @"index_icon_wind6";
            break;
            
        case WindSpeedAuto:
            name = @"index_icon_fan8";
            break;
            
        case WindSpeedTurbo:
        default:
            name = @"index_icon_wind7";
            break;
    }
    
    return name;
}

+ (NSString *)getDeviceCardPowernBgIcon:(AirConFunction)mode {
    NSString *name;
    
    switch (mode) {
        case AirConFunctionCool:
        case AirConFunctionVentilate:
        case AirConFunctionDehumidify:
        case AirConFunctionAuto:
            name = @"index_onedevice_circle_blue";
            break;
            
        case AirConFunctionHeat:
            name = @"index_onedevice_circle_yellow";
            break;
        default:
            name = @"";
            break;
    }
    
    return name;
}

+ (NSString *)getDeviceCardModeIcon:(AirConFunction)mode {
    NSString *name;
    
    switch (mode) {
        case AirConFunctionCool:
            name = @"index_icon_mode_cool";
            break;
            
        case AirConFunctionHeat:
            name = @"index_icon_mode_heat";
            break;
            
        case AirConFunctionVentilate:
            name = @"index_icon_mode_wind";
            break;
            
        case AirConFunctionDehumidify:
            name = @"index_icon_mode_dry";
            break;
            
        case AirConFunctionAuto:
            name = @"index_icon_mode_auto";
            break;
            
        default:
            name = @"";
            break;
    }
    
    return name;
}

+ (NSString *)getDeviceListGatewayModeIcon:(AirConFunction)mode {
    NSString *name;
    
    switch (mode) {
        case AirConFunctionCool:
            name = @"device_list_gateway_mode_cool";
            break;
            
        case AirConFunctionHeat:
            name = @"device_list_gateway_mode_heat";
            break;
            
        case AirConFunctionVentilate:
            name = @"device_list_gateway_mode_wind";
            break;
            
        case AirConFunctionDehumidify:
            name = @"device_list_gateway_mode_dry";
            break;
            
        case AirConFunctionAuto:
            name = @"device_list_gateway_mode_auto";
            break;
            
        default:
            name = @"";
            break;
    }
    
    return name;
}

+ (NSString *)getDeviceControlStatusModeIcon:(AirConFunction)mode {
    NSString *name;
    
    switch (mode) {
        case AirConFunctionCool:
            name = @"device_icon_cold";
            break;
            
        case AirConFunctionHeat:
            name = @"device_icon_hot";
            break;
            
        case AirConFunctionVentilate:
            name = @"device_icon_wind";
            break;
            
        case AirConFunctionDehumidify:
            name = @"device_icon_dry";
            break;
            
        case AirConFunctionAuto:
            name = @"device_icon_auto";
            break;
            
        default:
            name = @"";
            break;
    }
    
    return name;
}

+ (NSString *)getDeviceControlStatusWindSpeedIcon:(WindSpeed)windSpeed {
    NSString *name;
    
    switch (windSpeed) {
        case WindSpeedSilence:
            name = @"device_icon_fan1";
            break;
            
        case WindSpeedMin:
            name = @"device_icon_fan2";
            break;
            
        case WindSpeedMidMin:
            name = @"device_icon_fan3";
            break;
            
        case WindSpeedMid:
            name = @"device_icon_fan4";
            break;
            
        case WindSpeedMidMax:
            name = @"device_icon_fan5";
            break;
            
        case WindSpeedMax:
            name = @"device_icon_fan6";
            break;
            
        case WindSpeedTurbo:
            name = @"device_icon_fan7";
            break;
            
        case WindSpeedAuto:
        default:
            name = @"device_icon_fan8";
            break;
    }
    
    return name;
}

+ (NSDictionary<NSString *,NSString *> *)getDeviceFunctionWindSpeedIcon:(WindSpeed)windSpeed {
    NSDictionary<NSString *,NSString *> *iconsDict;
    
    switch (windSpeed) {
        case WindSpeedSilence: {
            iconsDict = @{@"imageNorBlue": @"function_list_wind_speed_mute_nor_blue",
                          @"imageSelBlue": @"function_list_wind_speed_mute_sel_blue",
                          @"imageNorGreen": @"function_list_wind_speed_mute_nor_green",
                          @"imageSelGreen": @"function_list_wind_speed_mute_sel_green",
                          @"imageNorOrange": @"function_list_wind_speed_mute_nor_orange",
                          @"imageSelOrange": @"function_list_wind_speed_mute_sel_orange"};
        }
            break;
            
        case WindSpeedMin: {
            iconsDict = @{@"imageNorBlue": @"function_list_wind_speed_min_nor_blue",
                          @"imageSelBlue": @"function_list_wind_speed_min_sel_blue",
                          @"imageNorGreen": @"function_list_wind_speed_min_nor_green",
                          @"imageSelGreen": @"function_list_wind_speed_min_sel_green",
                          @"imageNorOrange": @"function_list_wind_speed_min_nor_orange",
                          @"imageSelOrange": @"function_list_wind_speed_min_sel_orange"};
        }
            break;
            
        case WindSpeedMidMin: {
            iconsDict = @{@"imageNorBlue": @"function_list_wind_speed_mid_min_nor_blue",
                          @"imageSelBlue": @"function_list_wind_speed_mid_min_sel_blue",
                          @"imageNorGreen": @"function_list_wind_speed_mid_min_nor_green",
                          @"imageSelGreen": @"function_list_wind_speed_mid_min_sel_green",
                          @"imageNorOrange": @"function_list_wind_speed_mid_min_nor_orange",
                          @"imageSelOrange": @"function_list_wind_speed_mid_min_sel_orange"};
        }
            break;
            
        case WindSpeedMid: {
            iconsDict = @{@"imageNorBlue": @"function_list_wind_speed_mid_nor_blue",
                          @"imageSelBlue": @"function_list_wind_speed_mid_sel_blue",
                          @"imageNorGreen": @"function_list_wind_speed_mid_nor_green",
                          @"imageSelGreen": @"function_list_wind_speed_mid_sel_green",
                          @"imageNorOrange": @"function_list_wind_speed_mid_nor_orange",
                          @"imageSelOrange": @"function_list_wind_speed_mid_sel_orange"};
        }
            break;
            
        case WindSpeedMidMax: {
            iconsDict = @{@"imageNorBlue": @"function_list_wind_speed_mid_max_nor_blue",
                          @"imageSelBlue": @"function_list_wind_speed_mid_max_sel_blue",
                          @"imageNorGreen": @"function_list_wind_speed_mid_max_nor_green",
                          @"imageSelGreen": @"function_list_wind_speed_mid_max_sel_green",
                          @"imageNorOrange": @"function_list_wind_speed_mid_max_nor_orange",
                          @"imageSelOrange": @"function_list_wind_speed_mid_max_sel_orange"};
        }
            break;
            
        case WindSpeedMax: {
            iconsDict = @{@"imageNorBlue": @"function_list_wind_speed_max_nor_blue",
                          @"imageSelBlue": @"function_list_wind_speed_max_sel_blue",
                          @"imageNorGreen": @"function_list_wind_speed_max_nor_green",
                          @"imageSelGreen": @"function_list_wind_speed_max_sel_green",
                          @"imageNorOrange": @"function_list_wind_speed_max_nor_orange",
                          @"imageSelOrange": @"function_list_wind_speed_max_sel_orange"};
        }
            break;
            
        case WindSpeedAuto: {
            iconsDict = @{@"imageNorBlue": @"function_list_wind_speed_auto_nor_blue",
                          @"imageSelBlue": @"function_list_wind_speed_auto_sel_blue",
                          @"imageNorGreen": @"function_list_wind_speed_auto_nor_green",
                          @"imageSelGreen": @"function_list_wind_speed_auto_sel_green",
                          @"imageNorOrange": @"function_list_wind_speed_auto_nor_orange",
                          @"imageSelOrange": @"function_list_wind_speed_auto_sel_orange"};
        }
            break;
            
        case WindSpeedTurbo:
        default: {
            iconsDict = @{@"imageNorBlue": @"function_list_wind_speed_turbo_nor_blue",
                          @"imageSelBlue": @"function_list_wind_speed_turbo_sel_blue",
                          @"imageNorGreen": @"function_list_wind_speed_turbo_nor_green",
                          @"imageSelGreen": @"function_list_wind_speed_turbo_sel_green",
                          @"imageNorOrange": @"function_list_wind_speed_turbo_nor_orange",
                          @"imageSelOrange": @"function_list_wind_speed_turbo_sel_orange"};
        }
            break;
    }
    
    return iconsDict;
}

+ (NSDictionary<NSString *,NSString *> *)getDeviceFunctionScreenIcon:(BOOL)autoScreen {
    NSDictionary<NSString *,NSString *> *iconsDict;
    
    if (autoScreen) {
        iconsDict = @{@"imageSelBlue": @"function_list_display_auto_blue",
                      @"imageSelGreen": @"function_list_display_auto_green",
                      @"imageSelOrange": @"function_list_display_auto_orange"};
    } else {
        iconsDict = @{@"imageSelBlue": @"function_list_display_on_blue",
                      @"imageSelGreen": @"function_list_display_on_green",
                      @"imageSelOrange": @"function_list_display_on_orange"};
    }
    
    return iconsDict;
}

+ (NSString *)getDeviceControlWindSpeedIcon:(WindSpeed)windSpeed {
    NSString *name;
    
    switch (windSpeed) {
        case WindSpeedSilence:
            name = @"device_control_wind_speed_sel_mute";
            break;
            
        case WindSpeedMin:
            name = @"device_control_wind_speed_sel_min";
            break;
            
        case WindSpeedMidMin:
            name = @"device_control_wind_speed_sel_mid_min";
            break;
            
        case WindSpeedMid:
            name = @"device_control_wind_speed_sel_mid";
            break;
            
        case WindSpeedMidMax:
            name = @"device_control_wind_speed_sel_mid_max";
            break;
            
        case WindSpeedMax:
            name = @"device_control_wind_speed_sel_max";
            break;
            
        case WindSpeedAuto:
            name = @"device_control_wind_speed_sel_auto";
            break;
            
        case WindSpeedTurbo:
        default:
            name = @"device_control_wind_speed_sel_turbo";
            break;
    }
    
    return name;
}

#pragma mark - 设备分享

+ (NSString *)getRoleNameWithShareType:(AUXDeviceShareType)shareType {
    NSString *name;
    
    switch (shareType) {
        case AUXDeviceShareTypeFamily:
            name = @"家人";
            break;
            
        case AUXDeviceShareTypeFriend:
            name = @"朋友";
            break;
            
        case AUXDeviceShareTypeMaster:
        default:
            name = @"主人";
            break;
    }
    
    return name;
}

@end
