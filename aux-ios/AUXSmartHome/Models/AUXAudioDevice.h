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

@class AUXDeviceInfo;

/**
 语音控制设备模型 (语意识别接口交互)
 */
@interface AUXAudioDevice : NSObject

@property (nonatomic, strong) NSString *mac;                   

/// 设备别名。为了单元机和多联机的统一，setValue 方法不会更新该属性，请另行设置。
@property (nonatomic, strong) NSString *alias;

/// 设备地址。为了单元机和多联机的统一，setValue 方法不会更新该属性，请另行设置。
@property (nonatomic, assign) NSInteger address;

@property (nonatomic, assign) NSInteger windSpeedGear;          // 风速档位 3（挂机）/5（柜机）
@property (nonatomic, strong) NSString *supportFunc;            // 支持模式（0：自动 1：制冷 2：除湿 4：制热 6：送风）例："01246"
@property (nonatomic, assign) NSInteger temperature;            // 16-32
@property (nonatomic, assign) char upDownSwing;                 // 上下摆风开／关
@property (nonatomic, assign) char leftRightSwing;              // 左右摆风开／关
@property (nonatomic, assign) NSInteger windSpeed1;             // 挂机（1：高风 2：中风 3：低风 5：自动）；柜机（3：低风 2：中低 1：中风 6：中高 5：高风 7：自动）
@property (nonatomic, assign) BOOL half;                        // +0.5（22.5度）
@property (nonatomic, assign) BOOL turbo;                       // 强力（和静音，其他风速互斥）
@property (nonatomic, assign) BOOL silence;                     // 静音（和强力，其他风速互斥）
@property (nonatomic, assign) NSInteger airConFunc;             // 模式（0：自动 1：制冷 2：除湿 4：制热 6：送风）
@property (nonatomic, assign) BOOL sleepMode;                   // 睡眠模式开/关
@property (nonatomic, assign) BOOL onOff;                       // 空调开/关
@property (nonatomic, assign) BOOL electricHeating;             // 电加热开/关（制热模式下有效，提高制热效果）
@property (nonatomic, assign) BOOL eco;                         // eco开/关（制冷模式下有效，减少耗电）
@property (nonatomic, assign) BOOL clean;                       // 清洁开/关
@property (nonatomic, assign) BOOL healthy;                     // 健康开/关
@property (nonatomic, assign) BOOL autoScreen;                  // 自动屏显开/关
@property (nonatomic, assign) BOOL electricLock;                // 锁定开/关
@property (nonatomic, assign) BOOL screenOnOff;                 // 屏显开/关
@property (nonatomic, assign) BOOL antiFungus;                  // 防霉开/关
@property (nonatomic, assign) NSInteger roomTemperature;        // 室温
@property (nonatomic, assign) NSInteger faultCode;              // 故障代码
@property (nonatomic, assign) NSInteger moduleProtectFault;     // 模块保护代码（故障代码与模块保护代码都为0时空调正常运行）

/**
 更新语音设备的值

 @param deviceInfo 设备信息 (服务器获取)
 @param deviceControl 设备控制状态
 @param deviceStatus 设备运行状态
 
 @note 该方法不会设置 alias、address 的值，这两个属性请另外调用属性来设置。
 */
- (void)setValueWithDeviceInfo:(AUXDeviceInfo *)deviceInfo deviceControl:(AUXACControl *)deviceControl deviceStatus:(AUXACStatus *)deviceStatus;

- (void)updateDeviceControl:(AUXACControl *)deviceControl;

@end

/**
 语音控制设备模型 (语意识别接口交互，服务器答复)
 */
@interface AUXAnswerAudioDevice : AUXAudioDevice

@property (nonatomic, assign) NSInteger cmd_code;
@property (nonatomic, assign) NSString *cmd_str;
@property (nonatomic, strong) NSString *share;

@end
