//
//  AUXSelectGenderView.h
//  AUXSmartHome
//
//  Created by AUX on 2019/4/28.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^MGenderBlcok)(void);
typedef void(^FGenderBlcok)(void);
NS_ASSUME_NONNULL_BEGIN


@interface AUXSelectGenderView : UIView
@property (weak, nonatomic) IBOutlet UIView *backView;
@property (weak, nonatomic) IBOutlet UIView *alertView;
@property (weak, nonatomic) IBOutlet UIImageView *mImageView;
@property (weak, nonatomic) IBOutlet UIImageView *fImageView;

+ (void)alertViewWithMessage:(NSString *)message mGenderAtcion:(MGenderBlcok)mGenderAtcion fGenderAction:(FGenderBlcok)fGenderAction;

@end

NS_ASSUME_NONNULL_END
