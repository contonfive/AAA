//
//  AUXPushLimitMessageTimePick.h
//  AUXSmartHome
//
//  Created by AUX on 2019/4/29.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AUXPushLimitMessageTimePick : UIView
-(instancetype)initWithFrame:(CGRect)frame;
@property (nonatomic,assign)NSInteger oldStarttime;
@property (nonatomic,assign)NSInteger oldEndtime;
@property (nonatomic,assign)NSInteger starttime;
@property (nonatomic,assign)NSInteger endtime;




@end

NS_ASSUME_NONNULL_END
