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

/**
 用于构造 tableView 的 section header 
 */
@interface AUXTableViewSectionItem : NSObject

@property (nonatomic, strong) NSString *title;      // 标题
@property (nonatomic,copy) NSString *imageStr;

@property (nonatomic, assign) NSInteger section;
@property (nonatomic, assign) NSInteger rowCount;   // section 的行数
@property (nonatomic, assign) CGFloat rowHeight;

@end
