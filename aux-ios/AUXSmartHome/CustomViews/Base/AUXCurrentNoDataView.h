//
//  AUXCurrentNoDataView.h
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2019/5/10.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AUXCurrentNoDataView : UIView

@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topLayoutConstraint;


@end

NS_ASSUME_NONNULL_END
