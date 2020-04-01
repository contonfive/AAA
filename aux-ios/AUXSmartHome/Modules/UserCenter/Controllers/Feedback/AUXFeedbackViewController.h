//
//  AUXFeedbackViewController.h
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2018/8/1.
//  Copyright © 2018年 AUX Group Co., Ltd. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "AUXBaseViewController.h"

typedef NS_ENUM(NSInteger, AUXFeedBackQuestionType) {
    AUXFeedBackQuestionTypeOfAccount = 1,
    AUXFeedBackQuestionTypeOfAddDevice = 2,
    AUXFeedBackQuestionTypeOfDeviceManager = 3,
    AUXFeedBackQuestionTypeOfFunctionAbnormal = 4,
    AUXFeedBackQuestionTypeOfSceneMode = 5,
    AUXFeedBackQuestionTypeOfOtherQuestion = 6,
};

@interface AUXFeedbackViewController : AUXBaseViewController
@property (nonatomic,assign) AUXFeedBackQuestionType feedBackType;
@property (nonatomic,copy) NSString *typeLabel;
@end
