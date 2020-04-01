//
//  AUXOnlyOneButtonAlertView.h
//  AUXSmartHome
//
//  Created by AUX on 2019/5/17.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef void(^ConfirmBlock)(void);

@interface AUXOnlyOneButtonAlertView : UIView
@property (weak, nonatomic) IBOutlet UIView *alertView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *sureButton;
+ (AUXOnlyOneButtonAlertView *)alertViewtitle:(NSString*)title buttonTitle:(NSString *)buttonTitle  confirm:(ConfirmBlock)confirmBlock;
@end

NS_ASSUME_NONNULL_END
