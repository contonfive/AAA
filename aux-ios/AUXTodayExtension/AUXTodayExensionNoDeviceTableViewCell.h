//
//  AUXTodayExensionNoDeviceTableViewCell.h
//  AUXTodayExtension
//
//  Created by AUX Group Co., Ltd on 2018/6/4.
//  Copyright © 2018年 AUX Group Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AUXDefinitions.h"

@interface AUXTodayExensionNoDeviceTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *centerTitleLabel;

@property (nonatomic,assign) BOOL shouldAgainLogin;
@property (nonatomic,assign,setter=setShouldLogin:) BOOL shouldLogin;
@property (nonatomic,assign,setter=setShouldAddDevice:) BOOL shouldAddDevice;

@property (nonatomic,assign) AUXExtensionPushToMainAppType toMainAppType;

@property (nonatomic, copy) void (^cellTapAtcion)(AUXExtensionPushToMainAppType toMainAppType);

@end
