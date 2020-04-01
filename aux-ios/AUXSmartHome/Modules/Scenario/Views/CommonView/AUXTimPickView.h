//
//  AUXTimPickView.h
//  AUXSmartHome
//
//  Created by AUX on 2019/4/12.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AUXTimPickView : UIView
-(instancetype)initWithFrame:(CGRect)frame;
@property (nonatomic,strong)NSString *timeStr;
@end

NS_ASSUME_NONNULL_END
