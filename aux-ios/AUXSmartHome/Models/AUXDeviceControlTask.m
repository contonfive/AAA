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

#import "AUXDeviceControlTask.h"

@implementation AUXDeviceControlTask

+ (instancetype)controlTaskWithAddress:(NSString *)address control:(AUXACControl *)control {
    AUXDeviceControlTask *task = [[AUXDeviceControlTask alloc] init];
    task.address = address;
    task.control = [control copy];
    return task;
}

@end


@interface AUXDeviceControlQueue ()

@property (nonatomic, strong) AUXDeviceInfo *deviceInfo;
@property (nonatomic, strong) AUXACDevice *device;

/// 任务队列
@property (nonatomic, strong) NSMutableArray<AUXDeviceControlTask *> *taskQueue;

// 多联机子设备控制间隔350毫秒
@property (nonatomic, strong) NSTimer *timer;

@end

@implementation AUXDeviceControlQueue

+ (instancetype)controlQueueWithDeviceInfo:(AUXDeviceInfo *)deviceInfo device:(AUXACDevice *)device {
    AUXDeviceControlQueue *task = [[AUXDeviceControlQueue alloc] init];
    task.deviceInfo = deviceInfo;
    task.device = device;
    return task;
}

- (NSMutableArray<AUXDeviceControlTask *> *)taskQueue {
    if (!_taskQueue) {
        _taskQueue = [[NSMutableArray alloc] init];
    }
    return _taskQueue;
}

- (void)appendTask:(AUXDeviceControlTask *)task {
    if (!task) {
        return;
    }
    
    if (task.address.length == 0 || !task.control) {
        return;
    }
    
//    NSLog(@"设备 %@ %@ 添加控制任务 地址: %@", self.deviceInfo.alias, self.deviceInfo.mac, task.address);
    
    [self.taskQueue addObject:task];
}

- (void)start {
    
    if (!self.deviceInfo || !self.device) {
        return;
    }
    
    if (self.timer && self.timer.isValid) {
        return;
    }
    
//    NSLog(@"设备 %@ %@ 开始执行控制任务...", self.deviceInfo.alias, self.deviceInfo.mac);
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.35 target:self selector:@selector(controlDevice) userInfo:nil repeats:YES];
}

- (void)stop {
    
    if (!self.timer) {
        return;
    }
    
    [self.timer invalidate];
    self.timer = nil;
}

- (void)pause {
    if (self.timer) {
        [self.timer invalidate];
    }
}

- (void)resume {
    if (self.timer) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:0.35 target:self selector:@selector(controlDevice) userInfo:nil repeats:YES];
    }
}

- (void)controlDevice {
    if (self.taskQueue.count == 0) {
//        NSLog(@"设备 %@ %@ 控制任务执行完成...", self.deviceInfo.alias, self.deviceInfo.mac);
        [self.timer invalidate];
        self.timer = nil;
        return;
    }
    
    AUXDeviceControlTask *task = self.taskQueue.firstObject;
    if (self.taskQueue.count>0) {
        [self.taskQueue removeObjectAtIndex:0];
    }
    
//    NSLog(@"➔ 设备 %@ %@ 当前控制地址 %@", self.deviceInfo.alias, self.deviceInfo.mac, task.address);
    
    if (!task.control || !self.device) {
        NSLog(@"callStackSymbols--%@" , [NSThread callStackSymbols]);
        return ;
    }
    
    [[AUXACNetwork sharedInstance] sendCommand2Device:self.device controlInfo:task.control atAddress:task.address withType:self.device.deviceType];
}

@end
