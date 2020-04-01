//
//  AUXTodayExtensionTableViewCell.h
//  AUXTodayExtension
//
//  Created by AUX Group Co., Ltd on 2018/5/31.
//  Copyright © 2018年 AUX Group Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AUXDeviceInfo.h"
#import "AUXTodayExtensionViewController.h"


@interface AUXTodayExtensionTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subTitleLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *iconImageViewTop;

@property (weak, nonatomic) IBOutlet UIView *statusBackView;
@property (weak, nonatomic) IBOutlet UILabel *tempretureLabel;
@property (weak, nonatomic) IBOutlet UILabel *modelLabel;
@property (weak, nonatomic) IBOutlet UILabel *weedGeerLabel;

@property (weak, nonatomic) IBOutlet UIButton *powerOnButton;
@property (weak, nonatomic) IBOutlet UIButton *offOnlineButton;

@property (weak, nonatomic) IBOutlet UIView *faultBackView;


@property (weak, nonatomic) IBOutlet UIView *controlBackView;
@property (weak, nonatomic) IBOutlet UIButton *coolButton;
@property (weak, nonatomic) IBOutlet UIButton *onOffButton;
@property (weak, nonatomic) IBOutlet UIButton *heatUpButton;

@property (weak, nonatomic) IBOutlet UIView *backView;


@property (nonatomic, copy) void (^cellTapAtcion)(AUXExtensionPushToMainAppType toMainAppType);
@property (nonatomic,copy) void (^weedGeerChange)(CGFloat);
@property (nonatomic,copy) void (^coolAtcion)(void);
@property (nonatomic,copy) void (^heatUpAtcion)(void);
@property (nonatomic,copy) void (^onOffAtcion)(void);

@property (nonatomic,copy) void (^deviceTap)(BOOL isOffLine);

@property (nonatomic, copy) void (^hideLoadingBlock)(void);
@property (nonatomic, copy) void (^showLoadingBlock)(void);


/**
 操作失败，失败原因errorText
 */
@property (nonatomic, copy) void (^sendControlError)(NSString *errorText);

@property (nonatomic,strong) AUXDeviceInfo *deviceInfo;

@end
