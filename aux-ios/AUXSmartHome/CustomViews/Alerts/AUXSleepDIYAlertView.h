//
//  AUXSleepDIYAlertView.h
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2019/4/13.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AUXSleepDIYAlertView : UIView
@property (weak, nonatomic) IBOutlet UIImageView *backImageView;

@property (weak, nonatomic) IBOutlet UILabel *alertContentLabel;
@property (weak, nonatomic) IBOutlet UIButton *closeBtn;

@property (nonatomic, copy) void (^closeBlock)(void);

@end

NS_ASSUME_NONNULL_END
