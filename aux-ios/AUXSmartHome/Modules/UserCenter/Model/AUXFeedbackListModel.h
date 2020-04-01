//
//  AUXFeedbackListModel.h
//  AUXSmartHome
//
//  Created by AUX on 2019/4/22.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AUXFeedbackListModel : NSObject
@property (nonatomic,copy)NSString *content;
@property (nonatomic,copy)NSString *feedbackId;
@property (nonatomic,copy)NSString *typeLabel;
@property (nonatomic,assign)NSInteger unreadNum;

@end

NS_ASSUME_NONNULL_END
