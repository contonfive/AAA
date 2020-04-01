//
//  AUXSuccessJumpAlert.h
//  AUXSmartHome
//
//  Created by AUX on 2019/5/14.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^ConfirmBlock)(void);
typedef void(^CloseBlock)(void);

NS_ASSUME_NONNULL_BEGIN

@interface AUXSuccessJumpAlert : UIView

@property (weak, nonatomic) IBOutlet UIView *backView;
@property (weak, nonatomic) IBOutlet UIView *alertView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UIButton *sureButton;

@property (weak, nonatomic) IBOutlet UIButton *reSetButton;

+ (AUXSuccessJumpAlert *)alertViewtitle:(NSString*)title firstStr:(NSString*)firstStr secondStr:(NSString *)secondStr confirm:(ConfirmBlock)confirmBlock close:(CloseBlock)closeBlock;



@end

NS_ASSUME_NONNULL_END
