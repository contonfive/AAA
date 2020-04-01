//
//  AUXDeviceInfoAlertView.m
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2019/4/10.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXDeviceInfoAlertView.h"
#import "AUXUser.h"
#import "AUXNetworkManager.h"
#import "AUXTimerObject.h"
#import "NSString+AUXCustom.h"
#import "UIView+Toast.h"

#define NUM @"0123456789"
#define ALPHA @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
#define ALPHANUM @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"

@interface AUXDeviceInfoAlertView ()<AUXACNetworkProtocol , QMUITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIView *backView;
@property (weak, nonatomic) IBOutlet UIView *alertView;
@property (weak, nonatomic) IBOutlet UIButton *cancleBtn;
@property (weak, nonatomic) IBOutlet UIButton *sureBtn;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *alertViewBottom;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentTextfiledTriailing;
@property (weak, nonatomic) IBOutlet UIButton *photoBtn;


@property (nonatomic, strong) NSArray<NSString *> *existedNameArray;
@property (nonatomic,copy) NSString *changedString;
@property (nonatomic,copy) ConfirmBlock confirmBlock;
@property (nonatomic,copy) CloseBlock closeBlock;

@property (nonatomic,assign) float duration;
@property (nonatomic,strong) NSTimer *subDeviceChangeNameTimer;
@property (nonatomic,copy) NSString *currentDeviceName;
@end

@implementation AUXDeviceInfoAlertView

- (void)awakeFromNib {
    [super awakeFromNib];
    self.alpha = 0;
    
    self.alertView.layer.masksToBounds = YES;
    self.alertView.layer.cornerRadius = 10;

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideAtcion)];
    [self.backView addGestureRecognizer:tap];
    self.backView.userInteractionEnabled = YES;
    
    //监听textfield的输入状态
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidChangeValue:)         name:UITextFieldTextDidChangeNotification object:self.contentTextfiled];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShowOrHide:) name:UIKeyboardWillShowNotification object:nil];
}

+ (AUXDeviceInfoAlertView *)alertViewWithNameType:(AUXNamingType)nameType deviceInfo:(AUXDeviceInfo *)deviceInfo device:(AUXACDevice *)device address:(NSString *)address content:(NSString *)content confirm:(ConfirmBlock)confirmBlock close:(CloseBlock)closeBlock {
    AUXDeviceInfoAlertView *alertView = [[[NSBundle mainBundle] loadNibNamed:@"AUXDeviceInfoAlertView" owner:nil options:nil] firstObject];
    
    
    if (deviceInfo) {
        alertView.deviceInfo = deviceInfo;
    }
    if (device) {
        alertView.device = device;
    }
    if (!AUXWhtherNullString(address)) {
        alertView.address = address;
    }
    if (!AUXWhtherNullString(content)) {
        alertView.contentTextfiled.text = content;
    }
    
    alertView.nameType = nameType;
    alertView.confirmBlock = confirmBlock;
    alertView.closeBlock = closeBlock;
    
    [alertView.contentTextfiled becomeFirstResponder];
    alertView.frame = [UIScreen mainScreen].bounds;
    [kAUXWindowView addSubview:alertView];
    
    return alertView;
}

#pragma mark setter
- (void)setNameType:(AUXNamingType)nameType {
    _nameType = nameType;
    if (_nameType == AUXNamingTypeDeviceSN) {
        self.titleLabel.text = @"设备SN码";
    } else if (_nameType == AUXNamingTypeDeviceName) {
        self.titleLabel.text = @"设备名称";
        self.currentDeviceName = self.contentTextfiled.text;
        
    } else if (_nameType == AUXNamingTypeSubdeviceName) {
        self.titleLabel.text = @"子设备名称";
    } else if (_nameType == AUXNamingTypeSleepDIY) {
        self.titleLabel.text = @"睡眠DIY名称";
    } else if (_nameType == AUXNamingTypeSceneName) {
        self.titleLabel.text = @"场景名称";
    } else if (_nameType == AUXNamingTypeUserNickName) {
        self.titleLabel.text = @"昵称";
    } else if (_nameType == AUXNamingTypeUserName) {
        self.titleLabel.text = @"姓名";
    }
    
    self.contentTextfiled.delegate = self;
    self.contentTextfiled.placeholder = [NSString stringWithFormat:@"请输入%@" , self.titleLabel.text];
    
    if (_nameType == AUXNamingTypeDeviceSN) {
        self.contentTextfiledTriailing.constant = 40;
        self.photoBtn.hidden = NO;
    } else {
        self.contentTextfiledTriailing.constant = 10;
        self.photoBtn.hidden = YES;
    }
    [self layoutIfNeeded];
    
    switch (_nameType) {
        case AUXNamingTypeDeviceName: { // 修改设备名
            // 提取当前所有设备的名字
            NSMutableArray<NSString *> *nameArray = [[NSMutableArray alloc] init];
            for (AUXDeviceInfo *deviceInfo in [AUXUser defaultUser].deviceInfoArray) {
                
                if ([deviceInfo isEqual:self.deviceInfo]) {
                    continue;
                }
                
                NSString *name = deviceInfo.alias;
                
                if ([name length] > 0) {
                    [nameArray addObject:name];
                }
            }
            self.existedNameArray = nameArray;
            
            self.contentTextfiled.maximumTextLength = 20;
            self.contentTextfiled.text = self.deviceInfo.alias;
            
        }
            break;
            
        case AUXNamingTypeSubdeviceName: { // 修改子设备名
            [self.device.delegates addObject:self];
            
            // 提取当前所有设备的名字
            NSMutableArray<NSString *> *nameArray = [[NSMutableArray alloc] init];
            for (NSString *address in self.device.aliasDic.allKeys) {
                
                if ([address isEqual:self.address]) {
                    continue;
                }
                
                NSString *name = self.device.aliasDic[address];
                [nameArray addObject:name];
            }
            self.existedNameArray = nameArray;
            
            self.contentTextfiled.maximumTextLength = 20;
            self.contentTextfiled.text = self.device.aliasDic[self.address];
            
            if (self.deviceInfo.suitType == AUXDeviceSuitTypeGateway) {
                self.contentTextfiled.maximumTextLength = 14;
            }
        }
            break;
            
        case AUXNamingTypeDeviceSN: {
            self.contentTextfiled.maximumTextLength = NSUIntegerMax;
            self.contentTextfiled.keyboardType = UIKeyboardTypeASCIICapable;
        }
            break;
        case AUXNamingTypeSleepDIY: {
            self.contentTextfiled.maximumTextLength = 20;
        }
        case AUXNamingTypeSceneName: {
            self.contentTextfiled.maximumTextLength = 20;
        }
            break;
            
        default:
            break;
    }
}

- (void)setDeviceSn:(NSString *)deviceSn {
    _deviceSn = deviceSn;
    
    if (!AUXWhtherNullString(_deviceSn)) {
        
        self.contentTextfiled.text = _deviceSn;
    }
}

#pragma mark TextFiled 监听
- (void)textFieldDidChangeValue:(NSNotification *)notification {
    UITextField *textField = (UITextField *)[notification object];
    
    if (textField == self.contentTextfiled) {
        
        if ([textField.text isStringWithEmoji]) {
            textField.text = self.changedString;
            return;
        }
        
        if ([textField.text containsString:@" "]) {
            textField.text = [textField.text stringByReplacingOccurrencesOfString:@" " withString:@"\u00a0"];
        }
        
        UITextRange *selectedRange = textField.markedTextRange;
        if ([textField positionFromPosition:selectedRange.start offset:0]) {
            // 正在操作，不计算长度
            return;
        }
        self.changedString = textField.text;
    }
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.sureBtn sendActionsForControlEvents:UIControlEventTouchUpInside];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if (self.nameType == AUXNamingTypeDeviceSN) {
        NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:ALPHANUM] invertedSet];
        NSString *filtered = [[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
        return [string isEqualToString:filtered];
    }
    return YES;
}

- (void)textField:(QMUITextField *)textField didPreventTextChangeInRange:(NSRange)range replacementString:(NSString *)replacementString {
    
    NSString *errorMessage = [NSString stringWithFormat:@"%@不能超过%ld位" , self.titleLabel.text , self.contentTextfiled.maximumTextLength];
    
    [self.currentVC showErrorViewWithMessage:errorMessage];
}

#pragma mark 通知监听
- (void)keyboardWillShowOrHide:(NSNotification *)notification {
    NSDictionary *dict = notification.userInfo;
    float duration = [[dict objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    self.duration = duration;
    
    CGRect endRect = [[dict objectForKey:UIKeyboardFrameEndUserInfoKey]CGRectValue];
    
    self.alpha = 0;
    [UIView animateWithDuration:duration animations:^{
        self.alertViewBottom.constant = CGRectGetHeight(endRect);
        self.alpha = 1;
        [self layoutIfNeeded];
    }];
    
}


#pragma mark atcion
- (IBAction)photoScanAtcion:(id)sender {
    if (self.deviceSnBlock) {
        self.deviceSnBlock();
    }
    
    [self hideAtcion];
}

- (void)hideAtcion {
    
    [self.contentTextfiled resignFirstResponder];
    
    [UIView animateWithDuration:self.duration animations:^{
        self.alpha = 0;
        self.alertViewBottom.constant = 0;
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)showAtcion {
    [self.contentTextfiled becomeFirstResponder];
}

- (IBAction)cancleAtcion:(id)sender {
    [self hideAtcion];
    
    if (self.closeBlock) {
        self.closeBlock();
    }
}

- (IBAction)sureAtcion:(id)sender {
    if (!(self.nameType == AUXNamingTypeSceneName || self.nameType == AUXNamingTypeUserNickName || self.nameType == AUXNamingTypeUserName)) {
        if (!self.deviceInfo) {
            return;
        }
        
        if (self.deviceInfo.virtualDevice) {
            [self.currentVC showFailure:kAUXLocalizedString(@"VirtualAletMessage")];
            return ;
        }
    }

    NSString *text = self.contentTextfiled.text;
    
    switch (self.nameType) {
        case AUXNamingTypeDeviceName:
            if (!AUXWhtherNullString(text)) {
                
                if (![self.currentDeviceName isEqualToString:text]) {
                    [self changeDeviceName:text];
                }
            } else {
                [self showToastshortWithmessageinCenter:@"请输入设备名称"];
                return ;
            }
            break;
            
        case AUXNamingTypeSubdeviceName:
            if (!AUXWhtherNullString(text)) {
                [self changeSubdeviceName:text];
                return ;
            } else {
                [self showToastshortWithmessageinCenter:@"请输入设备名称"];
                return ;
            }
            
            break;
            
        case AUXNamingTypeDeviceSN:
            
            if (!AUXWhtherNullString(text)) {
                [self changeDeviceSN:text];
            } else {
                [self showToastshortWithmessageinCenter:@"请输入SN码"];
                return ;
            }
            break;
        case AUXNamingTypeSleepDIY:
            
            if (!AUXWhtherNullString(text)) {
                if (self.confirmBlock) {
                    self.confirmBlock(text);
                }
            } else {
                [self showToastshortWithmessageinCenter:@"请输入睡眠DIY名称"];
                return ;
            }
            break;
        case AUXNamingTypeSceneName:
            if (text.length!=0) {
                if (self.confirmBlock) {
                    self.confirmBlock(text);
                }
            } else {
                [self showToastshortWithmessageinCenter:@"请填写场景名称"];
                return ;
            }
            break;
        case AUXNamingTypeUserNickName:
                if (self.confirmBlock) {
                    self.confirmBlock(text);
                }
            break;
        case AUXNamingTypeUserName:
            if (self.confirmBlock) {
                self.confirmBlock(text);
            }
            break;
            
        default:
            break;
    }
    [self hideAtcion];
}


/// 修改设备名
- (void)changeDeviceName:(NSString *)text {
    if ([text length] == 0) {
        [self.currentVC showErrorViewWithMessage:@"请输入设备名称"];
        return;
    }
    
    if ([self.existedNameArray containsObject:text] ) {
        [self.currentVC showErrorViewWithMessage:@"该设备名已存在"];
        return;
    }
    [self.currentVC showLoadingHUD];
    
    [[AUXNetworkManager manager] updateDeviceInfoWithMac:self.deviceInfo.mac deviceSN:nil alias:text completion:^(NSError * _Nonnull error) {
        [self.currentVC hideLoadingHUD];
        switch (error.code) {
            case AUXNetworkErrorNone: {
                [[NSNotificationCenter defaultCenter] postNotificationName:AUXDeviceNameDidChangeNotification object:text];
                
                if (self.confirmBlock) {
                    self.confirmBlock(text);
                }
                @weakify(self);
                [self.currentVC showSuccess:@"保存成功" completion:^{
                    @strongify(self);
                    [self hideAtcion];
                }];
            }
                break;
                
            case AUXNetworkErrorAccountCacheExpired:
                [self.currentVC alertAccountCacheExpiredMessage];
                break;
                
            default:
                [self.currentVC showErrorViewWithMessage:@"保存失败"];
                break;
        }
    }];
}


/// 修改子设备名
- (void)changeSubdeviceName:(NSString *)text {
    if ([text length] == 0) {
        [self.currentVC showErrorViewWithMessage:@"请输入设备名称"];
        return;
    }
    
    if (self.deviceInfo.suitType == AUXDeviceSuitTypeGateway) {
        if ([text length] > 14) {
            [self.currentVC showErrorViewWithMessage:@"设备名称不能超过14个字符"];
            return;
        }
    } else {
        if ([text length] > 20) {
            [self.currentVC showErrorViewWithMessage:@"设备名称不能超过20个字符"];
            return;
        }
    }
    
    if ([self.existedNameArray containsObject:text]) {
        [self.currentVC showErrorViewWithMessage:@"该设备名已存在"];
        return;
    }
    
    [self.currentVC showLoadingHUD];
    
    self.subDeviceChangeNameTimer = [AUXTimerObject scheduledWeakTimerWithTimeInterval:DeviceControlCommondMaxTime target:self selector:@selector(invalidateTimer) userInfo:nil repeats:NO];
    [[AUXACNetwork sharedInstance] setSubDeviceAlias:text forDevice:self.device withType:self.device.deviceType atAddress:self.address];
}

- (void)invalidateTimer {
    [self.currentVC hideLoadingHUD];
    
    if (self.subDeviceChangeNameTimer) {
        [self.subDeviceChangeNameTimer invalidate];
        self.subDeviceChangeNameTimer = nil;
        
        [self hideAtcion];
    }
}

/// 修改设备SN码
- (void)changeDeviceSN:(NSString *)text {
    if ([text length] == 0) {
        [self.currentVC showErrorViewWithMessage:kAUXLocalizedString(@"PleaseInputSN")];
        return;
    }
    
    if (![text isStringOnlyWithNumberOrLetter]) {
        [self.currentVC showErrorViewWithMessage:kAUXLocalizedString(@"SNMeaageType")];
        return;
    }
    
//    @weakify(self);
    [self.currentVC alertWithMessage:@"确定SN码正确吗?\nSN码一旦上传将不可修改。" confirmTitle:kAUXLocalizedString(@"Sure") confirmBlock:^{
//        @strongify(self);
        [self changeDeviceSNByServer:text];
    } cancelTitle:kAUXLocalizedString(@"Cancle") cancelBlock:nil];
}

/// 修改设备SN码
- (void)changeDeviceSNByServer:(NSString *)deviceSN {
    
    [self.currentVC showLoadingHUD];
    [[AUXNetworkManager manager] updateDeviceInfoWithMac:self.deviceInfo.mac deviceSN:deviceSN alias:nil completion:^(NSError * _Nonnull error) {
        [self.currentVC hideLoadingHUD];
        switch (error.code) {
            case AUXNetworkErrorNone: {
                self.deviceInfo.sn = deviceSN;
                
                [[NSNotificationCenter defaultCenter] postNotificationName:AUXDeviceSNDidChangeNotification object:deviceSN];
                
                if (self.confirmBlock) {
                    self.confirmBlock(deviceSN);
                }
                
                @weakify(self);
                [self.currentVC showSuccess:@"保存成功" completion:^{
                    @strongify(self);
                    [self hideAtcion];
                }];
            }
                break;
                
            case AUXNetworkErrorAccountCacheExpired:
                
                [self.currentVC alertAccountCacheExpiredMessage];
                break;
                
            default:
                [self.currentVC showErrorViewWithError:error defaultMessage:@"保存失败"];
                break;
        }
    }];
}

#pragma mark - AUXACDeviceProtocol

- (void)auxACNetworkDidSetSubDeviceAliasForDevice:(AUXACDevice *)device atAddress:(NSString *)address success:(BOOL)success withError:(NSError *)error {
    [self.currentVC hideLoadingHUD];
    
    if (self.subDeviceChangeNameTimer) {
        [self.subDeviceChangeNameTimer invalidate];
        self.subDeviceChangeNameTimer = nil;
    }
    
    if (success) {
        [device setNeedUpdateSubDeviceAliases];
        
        NSString *text = self.contentTextfiled.text;
        [[NSNotificationCenter defaultCenter] postNotificationName:AUXDeviceNameDidChangeNotification object:text];
        
        if (self.confirmBlock) {
            self.confirmBlock(text);
        }
        
        @weakify(self);
        [self.currentVC showSuccess:@"保存成功" completion:^{
            @strongify(self);
            [self hideAtcion];
        }];
    } else {
        [self.currentVC showErrorViewWithError:error defaultMessage:@"设备名设置失败"];
    }
}

#pragma mark  短Toast弹框 3s 显示在中间
-(void)showToastshortWithmessageinCenter:(NSString *)message
{
    UIApplication *app = [UIApplication sharedApplication];
    [app.keyWindow makeToast:message duration:3.0 position:CSToastPositionCenter style:nil];
}
@end

