//
//  AUXCommonAlertView.h
//  AUXSmartHome
//
//  Created by AUX on 2019/5/7.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^ConfirmBlock)(NSString *name);
typedef void(^CloseBlock)(void);
NS_ASSUME_NONNULL_BEGIN

@interface AUXCommonAlertView : UIView
@property (weak, nonatomic) IBOutlet UIView *alertView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIView *textFieldbackView;
@property (weak, nonatomic) IBOutlet UITextField *detailTextField;
@property (nonatomic,assign) AUXNamingType nameType;


+ (AUXCommonAlertView *)alertViewWithnameType:(AUXNamingType)nameType nameLabelText:(NSString*)nameLabelText detailLabelText:(NSString *)detailLabelText confirm:(ConfirmBlock)confirmBlock close:(CloseBlock)closeBlock;

@end

NS_ASSUME_NONNULL_END
