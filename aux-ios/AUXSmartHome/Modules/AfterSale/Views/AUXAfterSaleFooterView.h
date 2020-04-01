//
//  AUXAfterSaleFooterView.h
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2018/9/20.
//  Copyright © 2018年 AUX Group Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AUXAfterSaleFooterView : UIView
@property (weak, nonatomic) IBOutlet UIButton *phoneButton;

@property (nonatomic, copy) void (^phoneBlock)(void);

@end

NS_ASSUME_NONNULL_END
