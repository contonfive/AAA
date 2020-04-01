//
//  AUXAddContactFooterView.h
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2018/9/25.
//  Copyright © 2018年 AUX Group Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AUXButton.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUXAddContactFooterView : UIView

@property (weak, nonatomic) IBOutlet AUXButton *saveButton;

@property (nonatomic, copy) void (^saveBlock)(void);
@end

NS_ASSUME_NONNULL_END
