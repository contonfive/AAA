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
#import <UIKit/UIKit.h>
#import <YYModel/YYModel.h>

#import "AUXDefinitions.h"

/**
 设备功能项。用于构造设备控制界面中的功能列表。
 */
@interface AUXDeviceFunctionItem : NSObject <YYModel>

@property (nonatomic, assign) AUXDeviceFunctionType type;   // 功能类型

@property (nonatomic, strong) NSString *title;      // 标题

@property (nonatomic, strong) NSString *imageNor;       // 图标

@property (nonatomic, strong) NSString *imageSel;       // 选中图标

/// 标识功能是否选中
@property (nonatomic, assign) BOOL selected;
/// 标识功能是否可用
@property (nonatomic, assign) BOOL disabled;

@end
