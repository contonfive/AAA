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
#include "InstructionParser.h"

typedef NS_ENUM(char, AUXACNetworkQueryType) {
    AUXACNetworkQueryTypeControl = 0x1,               // 查询空调控制状态
    AUXACNetworkQueryTypeStatus = 0x2,                // 查询空调运行状态
    AUXACNetworkQueryTypeSubDevices = 0x9,            // 查询空调子设备
    AUXACNetworkQueryTypeAliasOfSubDevice = 0x7,      // 查询空调子设备名称
    AUXACNetworkQueryTypeAliasesOfSubDevices = 0xa,   // 查询空调子设备名称
    AUXACNetworkQueryTypeSleepDIYPoints = 0x4,        // 查询空调睡眠曲线
    AUXACNetworkQueryTypeUnknow = 0xf,                // 未知查询
};

typedef NS_ENUM(char, AUXACNetworkCMDType) {
    AUXACNetworkCMDTypeControl = 0x0,                   // 设置空调控制状态
    AUXACNetworkCMDTypeSleepDIY = 0x3,                  // 设置空调睡眠曲线
    AUXACNetworkCMDTypeSubDeviceAlias = 0x8,            // 设置子设备别名
    AUXACNetworkCMDTypeSmartPower = 0x5,                // 设置空调智能用电
    AUXACNetworkCMDTypeUnknow = 0xf,                    // 未知设置
};

typedef NS_ENUM(char, DeviceWifiStatus) {
    DeviceWifiStatusNotConnected,
    DeviceWifiStatusConnected,
    DeviceWifiStatusOffline,
};

typedef NS_ENUM(char, WindGearType) {
    WindGearType1,                                      // 挂机风速档位类型
    WindGearType2,                                      // 柜机风速档位类型
};

typedef NS_ENUM(char, WindSpeed) {
    WindSpeedAuto,
    WindSpeedMin,
    WindSpeedMidMin,
    WindSpeedMid,
    WindSpeedMidMax,
    WindSpeedMax,
    WindSpeedSilence,
    WindSpeedTurbo,
    WindSpeedNA,
};

typedef NS_ENUM(char, AirConFunction) {
    AirConFunctionAuto = 0x00,
    AirConFunctionCool = 0x01,
    AirConFunctionDehumidify = 0x02,
    AirConFunctionHeat = 0x04,
    AirConFunctionVentilate = 0x06,
};

typedef NS_ENUM(char, BroadlinkTimerType) {
    BroadlinkTimerTypeMTK = 0x01,
    BroadlinkTimerTypeMVL = 0x02,
    BroadlinkTimerTypeMTKMVL = 0x03,
};

typedef NS_ENUM(int, Broadlink2UartCmd) {
    Broadlink2UartCmdList = 0x7d0,
    Broadlink2UartCmdListRes = 0x7d1,
    Broadlink2UartCmdListData = 0x7d2,
    Broadlink2UartCmdListDataRes = 0x7d3,
    Broadlink2UartCmdAdd = 0x7d4,
    Broadlink2UartCmdAddRes = 0x7d5,
    Broadlink2UartCmdDel = 0x7d6,
    Broadlink2UartCmdDelRes = 0x7d7,
    Broadlink2UartCmdEdit = 0x7d8,
    Broadlink2UartCmdEditRes = 0x7d9,
};

typedef NS_ENUM(int8_t, SmartPowerMode) {
    SmartPowerModeQuick = 0x1,
    SmartPowerModeBalance = 0x2,
    SmartPowerModeEconomize = 0x3,
};

@class AUXACNetworkError;

@interface AUXACControl : NSObject <NSCopying>

// A: 设定温度(00000~11111) + 上下摆风模式(000摆风 111固定)
@property (assign, nonatomic) char temperature;
@property (assign, nonatomic) char upDownSwing;

// B: 左右摆风模式(000摆风 111固定) + 现在时间(00000~10111, hour)
@property (assign, nonatomic) char leftRightSwing;
@property (assign, nonatomic) char nowTimeHour;

// C: 0.5°C的设置 + 手动发送随身感码/自动发送随身感码 + 现在时间(000000~111011, minute)
@property (assign, nonatomic) BOOL half;
@property (assign, nonatomic) BOOL autoFollowingCode;
@property (assign, nonatomic) char nowTimeMinute;

// D: 风速 + 定时时间(00000~10111, hour)
@property (assign, nonatomic) char windSpeed1;
@property (assign, nonatomic) char timerHour;

// E: 强力&静音(00无 01强力 10静音) + 定时时间(000000~111011, minute)
@property (assign, nonatomic) BOOL turbo;
@property (assign, nonatomic) BOOL silence;
@property (assign, nonatomic) char timerMinute;

// F: 功能(000自动 001制冷 010除湿 011保留位 100制热 101保留位 110送风 111保留位) + 清新开启/清新关闭 + 随身感功能开启/随身感功能关闭 + 睡眠开启/睡眠关闭 + 华氏温标/摄氏温标 + 人感功能开启/人感功能关闭
@property (assign, nonatomic, readonly) BOOL autoMode;
@property (assign, nonatomic, readonly) BOOL cool;
@property (assign, nonatomic, readonly) BOOL dehumidify;
@property (assign, nonatomic, readonly) BOOL heat;
@property (assign, nonatomic, readonly) BOOL ventilate;
@property (assign, nonatomic) AirConFunction airConFunc;
@property (assign, nonatomic) BOOL freshing;
@property (assign, nonatomic) BOOL following;
@property (assign, nonatomic) BOOL sleepMode;
@property (assign, nonatomic) BOOL fahrenheit;
@property (assign, nonatomic) BOOL humanDetection;

// G: 保留(2bit) + 室内温度(000000~111111)
@property (assign, nonatomic) char roomTemperature;

// H: 保留(2bit) + 室内湿度(000000~111111)
@property (assign, nonatomic) char humidity;

// I: 定时状态(00无 01关 10开) + 开机/关机 + 辅助电加热打开/辅助电加热关闭 + ECO打开/ECO关闭 + 清洁打开/清洁关闭 + 健康打开/健康关闭 + 空气清新打开/空气清新关闭
@property (assign, nonatomic) char acTimer;
@property (assign, nonatomic) BOOL onOff;
@property (assign, nonatomic) BOOL electricHeating;
@property (assign, nonatomic) BOOL eco;
@property (assign, nonatomic) BOOL clean;
@property (assign, nonatomic) BOOL healthy;
@property (assign, nonatomic) BOOL airFreshing;

// J: 保留(1bit) + 风速(0000000~1100100)
@property (assign, nonatomic) char windSpeed2;

// K: 舒适风 + 自动屏显打开/自动屏显关闭 + 电子锁打开/电子锁关闭 + 屏显打开/屏显关闭 + 防霉功能开启/防霉功能关闭 + 自定义睡眠开启/自定义睡眠关闭 + 控制方式(00 01 10 11)
@property (assign, nonatomic) BOOL comfortWind;
@property (assign, nonatomic) BOOL autoScreen;
@property (assign, nonatomic) BOOL electricLock;
@property (assign, nonatomic) BOOL screenOnOff;
@property (assign, nonatomic) BOOL antiFungus;
@property (assign, nonatomic) BOOL sleepDiy;
@property (assign, nonatomic) char controlMode;

// L: 限制用电开启/限制用电关闭 + 整机功率负荷百分比(000000~1100100)
@property (assign, nonatomic) BOOL powerLimit;
@property (assign, nonatomic) char powerLimitPercent;

// M: 保留(4bit) + 温度小数位(0000~1001)
@property (assign, nonatomic) char temperatureDecimal;

- (instancetype)initControlWith:(uint8_t *)buffer;

- (NSData *)controlBufferData:(uint8_t)address;

- (NSString *)controlBufferHexStr:(uint8_t)address;

- (void)controlBuffer:(uint8_t **)buffer length:(uint8_t *)length address:(uint8_t)address;

- (WindSpeed) getWindSpeedWithType:(WindGearType)type;

- (void)setWindSpeed:(WindSpeed)windSpeed WithType:(WindGearType)type;

@end

@interface AUXACStatus : NSObject

// A: (家用机+单元机: 热泵机型/单冷机型 + 挂机/柜机 + 变频/定速 + 儿童空调/普通 + 除尘提醒/无 + 10分钟上报/APP查询 + 模块保护故障F1/非模块保护故障F1 + 保留位)/(多联机: 保留(4bit) + 机型(0001天花机 0010风管机 0011座吊机 0100壁挂机))
@property (assign, nonatomic) BOOL supportHeat;
@property (assign, nonatomic) BOOL hanging;
@property (assign, nonatomic) BOOL frequencyConversion;
@property (assign, nonatomic) BOOL child;
@property (assign, nonatomic) BOOL cleanNotify;
@property (assign, nonatomic) BOOL fromReport;
@property (assign, nonatomic) BOOL moduleProtectFault;
@property (assign, nonatomic) char innerType;

// B: 功能(000自动 001制冷 010除湿 011保留位 100制热 101保留位 110送风 111保留位) + 左右摆风(00关 11开) + 上下摆风开/上下摆风关 + 睡眠/无 + 开机/停机
@property (assign, nonatomic, readonly) BOOL autoMode;
@property (assign, nonatomic, readonly) BOOL cool;
@property (assign, nonatomic, readonly) BOOL dehumidify;
@property (assign, nonatomic, readonly) BOOL heat;
@property (assign, nonatomic, readonly) BOOL ventilate;
@property (assign, nonatomic) AirConFunction airConFunc;
@property (assign, nonatomic) BOOL leftRightSwing;
@property (assign, nonatomic) BOOL upDownSwing;
@property (assign, nonatomic) BOOL sleepMode;
@property (assign, nonatomic) BOOL onOff;

// C: 清洁/无 + 防霉/无 + 除霜/无 + 回油/无 + 室外强制开停内风机/无 + 交流抽头风机/无 + 空气质量检测(00优良 01一般 10差 11保留位)
@property (assign, nonatomic) BOOL clean;
@property (assign, nonatomic) BOOL antiFungus;
@property (assign, nonatomic) BOOL defrost;
@property (assign, nonatomic) BOOL oilReturn;
@property (assign, nonatomic) BOOL innerFan;
@property (assign, nonatomic) BOOL tapFan;
@property (assign, nonatomic) BOOL highQualityOfAir;
@property (assign, nonatomic) BOOL normalQualityOfAir;
@property (assign, nonatomic) BOOL lowQualityOfAir;

// D: 室内风机转速(0000000停风 00000001静音风 00000010低风 00000011中低风 00000100中风 00000101 中高风 00000110高风 00000111强力风)
@property (assign, nonatomic) WindSpeed windSpeed;

// E: 交流PG风机和直流风机转速

// F: 室内环境温度
@property (assign, nonatomic) char roomTemperature;

// G: 室内盘管进口温度

// H: 室内盘管中部温度

// I: 室内盘管出口温度

// J: 室内机膨胀阀

// K: 室外环境温度

// L: 室外盘管温度

// M: 室外排气温度

// N: 室外回气温度

// O: 压缩机频率

// P: 压缩机电流

// Q: 电源电压

// R: 室外机膨胀阀

// S: 运行功率
@property (assign, nonatomic) char serviceRating;

// T: 故障
@property (assign, nonatomic) char fault_code;
@property (retain, nonatomic) AUXACNetworkError *fault;

// U: 10分钟电量

// V: 室内环境温度小数
@property (assign, nonatomic) char roomTemperatureDecimal;

// W: 额定功率
@property (assign, nonatomic) uint16_t powerRating;

- (instancetype)initStatusWith:(uint8_t *)buffer;

- (AUXACNetworkError *)getFault;

@end

@interface AUXACSleepDIYPoint : NSObject

@property (assign, nonatomic) char temperature;
@property (assign, nonatomic) WindSpeed windSpeed;

- (instancetype)initWith:(uint8_t)temperature windSpeed:(uint8_t)windSpeed;

- (struct uart_instruction_diy_pointer)getDiyPointerStruct;

@end

@interface AUXACBroadlinkTimer : NSObject

@property (assign, nonatomic) BOOL enabled;
@property (assign, nonatomic) char index;
@property (assign, nonatomic) BOOL onOff;
@property (assign, nonatomic) char temperature;
@property (assign, nonatomic) AirConFunction airConFunc;
@property (assign, nonatomic) WindSpeed windSpeed;
@property (assign, nonatomic) int year;
@property (assign, nonatomic) char month;
@property (assign, nonatomic) char day;
@property (assign, nonatomic) char hour;
@property (assign, nonatomic) char minute;

@end

@interface AUXACBroadlinkCycleTimer : NSObject

@property (assign, nonatomic) BOOL enabled;
@property (assign, nonatomic) char index;
@property (assign, nonatomic) BOOL onOff;
@property (assign, nonatomic) char temperature;
@property (assign, nonatomic) AirConFunction airConFunc;
@property (assign, nonatomic) WindSpeed windSpeed;
@property (copy, nonatomic) NSArray<NSNumber *> *week;
@property (assign, nonatomic) char hour;
@property (assign, nonatomic) char minute;

@end

@interface AUXACSmartPower : NSObject

@property (assign, nonatomic) BOOL enabled;
@property (assign, nonatomic) SmartPowerMode mode;
@property (copy, nonatomic) NSString *addTime;
@property (assign, nonatomic) int quantity;
@property (copy, nonatomic) NSString *startTime;
@property (copy, nonatomic) NSString *endTime;
//@property (assign, nonatomic) BOOL repeat;

@end

@interface AUXACPeakValleyPower : NSObject

@property (assign, nonatomic) BOOL enabled;
@property (copy, nonatomic) NSString *addTime;
@property (copy, nonatomic) NSString *peakStartTime;
@property (copy, nonatomic) NSString *peakEndTime;
@property (copy, nonatomic) NSString *valleyStartTime;
@property (copy, nonatomic) NSString *valleyEndTime;

@end
