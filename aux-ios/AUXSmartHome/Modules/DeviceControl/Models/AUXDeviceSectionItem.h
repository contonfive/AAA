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

#import "AUXTableViewSectionItem.h"
#import "AUXDefinitions.h"

/**
 用于构造设备控制界面 tableView 的 section header
 */
@interface AUXDeviceSectionItem : AUXTableViewSectionItem

@property (nonatomic, assign) AUXDeviceFunctionType type;   // 功能类型

@property (nonatomic, assign) BOOL hideIndicator;
@property (nonatomic, assign) BOOL canClicked;      // 是否可以点击

@property (nonatomic, assign) NSInteger offSection;

@end
