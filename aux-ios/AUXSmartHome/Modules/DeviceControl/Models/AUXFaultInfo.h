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

/**
 设备故障信息
 */
@interface AUXFaultInfo : NSObject

@property (nonatomic, strong) NSString *faultId;        // 主键uuid faultId=-1时为滤网故障
@property (nonatomic, strong) NSString *faultName;      // 故障名称
@property (nonatomic, strong) NSString *faultReason;    // 故障原因
@property (nonatomic, assign) NSInteger faultCode;
@property (nonatomic, strong) NSString *mac;            // mac地址
@property (nonatomic, strong) NSString *occurrenceTime; // 发生时间 YYYY-MM-dd HH:mm:ss
@property (nonatomic, strong) NSString *phone;          // 手机号
@property (nonatomic, strong) NSString *resolveTime;    // 解决时间 YYYY-MM-dd HH:mm:ss
@property (nonatomic, assign) NSInteger status;         // 状态 0未解决 1已解决
@property (nonatomic, strong) NSString *username;       // 用户名

@end
