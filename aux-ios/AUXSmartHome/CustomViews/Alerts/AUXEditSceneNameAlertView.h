//
//  AUXEditSceneNameAlertView.h
//  AUXSmartHome
//
//  Created by AUX on 2019/4/9.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AUXEditSceneNameAlertView : UIView
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (nonatomic, copy) void (^confirmBlock)(NSString*name);
@property (nonatomic, copy) void (^cancelBlock)(void);
+ (instancetype)editSceneNameAlertViewcancelBlock:(void (^)(void))cancelBlock confirmBlock:(void (^)(NSString*name))confirmBlock;
@end

NS_ASSUME_NONNULL_END
