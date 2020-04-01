//
//  AUXWiFiChangedAlertView.h
//  AUXSmartHome
//
//  Created by AUX on 2019/4/2.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AUXWiFiChangedAlertView : UIView
@property (weak, nonatomic) IBOutlet UILabel *firstLabel;
@property (weak, nonatomic) IBOutlet UILabel *seccondLabel;
@property (nonatomic, copy) void (^confirmBlock)(void);
@property (nonatomic, copy) void (^giveUpBlock)(void);

+ (instancetype)wifiChangeAlertView;

@end

NS_ASSUME_NONNULL_END
