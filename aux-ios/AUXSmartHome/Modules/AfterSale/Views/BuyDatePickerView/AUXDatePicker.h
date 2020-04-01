//
//  AUXDatePicker.h
//  Chart-Demo
//
//  Created by yongjing.xiao on 2017/6/16.
//  Copyright © 2017年 xinweilai. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AUXDatePicker;
@protocol AUXDatePickerDelegate <NSObject>
@optional
//选中日期
-(void)datePickerView:(AUXDatePicker *)datePickerView didSelectedDateString:(NSString *)dateString;
//取消日期
-(void)cancelDatePicker;

@end

@interface AUXDatePicker : UIView
//代理
@property (nonatomic ,weak)id<AUXDatePickerDelegate>delegate;

@property (nonatomic,copy) NSString *title;

@property (nonatomic, strong) NSDate *minimumDate;//最小时间
@property (nonatomic, strong) NSDate *maximumDate;//最大时间

@property (nonatomic,assign) BOOL subcribeDate;

-(void)initData;

/**
 设置默认选中
 */
- (void)pickerSelect;

- (void)clearSeparator;

@end
