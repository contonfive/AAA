//
//  AUXStoreSearchView.h
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2019/5/17.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AUXStoreSearchView : UIView
@property (weak, nonatomic) IBOutlet UIView *backView;

@property (weak, nonatomic) IBOutlet UITextField *searchTextFiled;
@property (weak, nonatomic) IBOutlet UIButton *cancleBtn;

@property (nonatomic, copy) void (^cancleBlock)(void);
@property (nonatomic, copy) void (^searchBlock)(NSString *text);
@end

NS_ASSUME_NONNULL_END
