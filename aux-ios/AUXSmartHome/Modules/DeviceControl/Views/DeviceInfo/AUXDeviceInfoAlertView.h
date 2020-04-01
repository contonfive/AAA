//
//  AUXDeviceInfoAlertView.h
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2019/4/10.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AUXDeviceInfo.h"
#import "AUXBaseViewController.h"

#import "QMUITextField.h"

typedef void(^ConfirmBlock)(NSString *name);
typedef void(^CloseBlock)(void);
NS_ASSUME_NONNULL_BEGIN

@interface AUXDeviceInfoAlertView : UIView

@property (weak, nonatomic) IBOutlet QMUITextField *contentTextfiled;

@property (nonatomic,strong) AUXBaseViewController *currentVC;
@property (nonatomic,assign) AUXNamingType nameType;
@property (nonatomic,strong) AUXDeviceInfo *deviceInfo;
@property (nonatomic, strong) AUXACDevice *device;
@property (nonatomic, strong) NSString *address;    // 子设备地址
@property (nonatomic,copy) NSString *deviceSn;  //用于使用二维码扫描设备sn

+ (AUXDeviceInfoAlertView *)alertViewWithNameType:(AUXNamingType)nameType deviceInfo:(AUXDeviceInfo *)deviceInfo device:(AUXACDevice *)device address:(NSString *)address content:(NSString *)content confirm:(ConfirmBlock)confirmBlock close:(CloseBlock)closeBlock;

@property (nonatomic, copy) void (^deviceSnBlock)(void);

- (void)showAtcion;
@end

NS_ASSUME_NONNULL_END
