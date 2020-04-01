//
//  AUXDatePickView.h
//  AUXSmartHome
//
//  Created by AUX on 2019/4/10.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AUXDatePickView : UIView

-(instancetype)initWithFrame:(CGRect)frame;
@property (nonatomic,strong)NSString *timeStr;
@property (nonatomic,assign) NSInteger firstNumber;
@property (nonatomic,assign) NSInteger seccondNumber;
@end

NS_ASSUME_NONNULL_END
