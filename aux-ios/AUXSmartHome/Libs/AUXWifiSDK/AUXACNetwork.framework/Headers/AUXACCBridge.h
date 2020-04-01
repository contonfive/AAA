//
//  AUXACCBridge.h
//  AUXACNetwork
//
//  Created by 陈凯 on 12/09/2018.
//  Copyright © 2018 陈凯. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AUXACInfo.h"

@interface AUXACCBridge : NSObject

+ (NSString *)queryBufferHexStr:(uint8_t *)payload size:(uint8_t)payload_size src:(uint8_t)src dst:(uint8_t)dst;

+ (NSData *)queryBufferData:(uint8_t *)payload size:(uint8_t)payload_size src:(uint8_t)src dst:(uint8_t)dst;

+ (NSArray<AUXACSleepDIYPoint *> *)parseSleepDiy:(uint8_t *)buffer;

+ (NSString *)sleepDiyBufferHexStr:(NSArray<AUXACSleepDIYPoint *> *)pointers dst:(uint8_t)dst;

+ (NSData *)sleepDiyBufferData:(NSArray<AUXACSleepDIYPoint *> *)pointers dst:(uint8_t)dst;

+ (NSArray *)parseSubDst:(uint8_t *)buffer;

+ (NSString *)parseSetAliasBufferHexStr:(NSString *)alias dst:(uint8_t)dst;

+ (NSData *)parseSetAliasBufferData:(NSString *)alias dst:(uint8_t)dst;

+ (NSString *)queryAliasesBufferHexStr:(NSArray<NSString *> *)addrArray src:(uint8_t)src dst:(uint8_t)dst;

+ (NSData *)queryAliasesBufferData:(NSArray<NSString *> *)addrArray src:(uint8_t)src dst:(uint8_t)dst;

+ (NSDictionary *)parseAliases:(uint8_t *)buffer length:(uint8_t)length;

+ (NSArray<NSNumber *> *)parseCycleTimerData:(AUXACBroadlinkCycleTimer *)timer control:(AUXACControl *)control cmdType:(Broadlink2UartCmd)cmdType hardwareType:(BroadlinkTimerType)hardwareType;

+ (NSArray<AUXACBroadlinkCycleTimer *> *)parseCycleTimerArray:(NSArray<NSNumber *> *)info hardwareType:(BroadlinkTimerType)hardwareType;

+ (BOOL)validateBufferHexStr:(NSString *)strBuffer;

+ (BOOL)getPasscode:(NSString **)passcode byIp:(NSString *)ip;

@end
