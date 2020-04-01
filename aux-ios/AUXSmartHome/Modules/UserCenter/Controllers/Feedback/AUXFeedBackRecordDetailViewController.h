//
//  AUXFeedBackRecordDetailViewController.h
//  AUXSmartHome
//
//  Created by AUX on 2019/4/22.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AUXBaseViewController.h"
#import "AUXFeedbackListModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUXFeedBackRecordDetailViewController : AUXBaseViewController
@property (nonatomic,strong)AUXFeedbackListModel*feedbackListModel;
@end

NS_ASSUME_NONNULL_END
