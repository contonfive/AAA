/*
 * =============================================================================
 *
 * AUX Group Confidential
 *
 * OCO Source Materials
 *
 * (C) Copyright AUX Group Co., Ltd. 2017 All Rights Reserved.
 *
 * The source code for this program is not published or otherwise divested
 * of its trade secrets, unauthorized application or modification of this
 * source code will incur legal liability.
 * =============================================================================
 */

#import "AUXConfigSucceedViewController.h"
#import "AUXButton.h"
#import "AUXUser.h"
#import "AUXNetworkManager.h"
#import "AUXArchiveTool.h"
#import "NSString+AUXCustom.h"
#import "UIColor+AUXCustom.h"
#import "AUXSuccessJumpAlert.h"
#import "AUXSNCodeSearchViewController.h"
#import "AUXScanCodeViewController.h"


@interface AUXConfigSucceedViewController () <UITextFieldDelegate, QMUINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (nonatomic, strong) NSArray<NSString *> *existedNameArray;
@property (nonatomic,copy) NSString *changedString;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;//确定按钮
@end

@implementation AUXConfigSucceedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.nameTextField.placeholder = @"请填写设备名称";
    self.nameTextField.layer.masksToBounds = YES;
    self.nameTextField.layer.cornerRadius = 2;
    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.title = nil;
    for (id obj in self.view.subviews)  {
        if ([obj isKindOfClass:[UIButton class]]) {
            UIButton* theButton = (UIButton*)obj;
            theButton.layer.masksToBounds = YES;
            theButton.layer.cornerRadius = theButton.bounds.size.height/2;
            theButton.layer.borderWidth = 1;
            theButton.layer.borderColor = [[UIColor colorWithHexString:@"E5E5E5"] CGColor];
        }
    }
    self.nextButton.layer.borderColor = [[UIColor colorWithHexString:@"256BBD"] CGColor];
    self.nextButton.layer.borderWidth = 2;
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
    self.nameTextField.text = [self getDeviceNameWithBaseName:@"空调"];
    self.nameTextField.delegate = self;
    //监听textfield的输入状态
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidChangeValue:) name:UITextFieldTextDidChangeNotification object:self.nameTextField];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textFieldEditChanged:)
                                                name:@"UITextFieldTextDidChangeNotification" object:nil];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    self.navigationController.navigationBarHidden = YES;
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    self.navigationController.interactivePopGestureRecognizer.delegate = nil;
    
}
#pragma mark 判断当前要设置的名字是否已存在，如果存在，则后缀一个递增的数字
- (NSString *)getDeviceNameWithBaseName:(NSString *)baseName {
    NSString *currentName = baseName;
    int i = 0;
    while ([self.existedNameArray containsObject:currentName]) {
        i = i + 1;
        currentName = [NSString stringWithFormat:@"%@%@", baseName, @(i)];
    }
    return currentName;
}

#pragma mark TextFiled 监听
- (void)textFieldDidChangeValue:(NSNotification *)notification {
    UITextField *textField = (UITextField *)[notification object];
    if (textField == self.nameTextField) {
        if ([self.nameTextField.text isStringWithEmoji]) {
            textField.text = self.changedString;
            return;
        }
        if ([self.nameTextField.text containsString:@" "]) {
            self.nameTextField.text = [self.nameTextField.text stringByReplacingOccurrencesOfString:@" " withString:@"\u00a0"];
        }
        UITextRange *selectedRange = textField.markedTextRange;
        if ([textField positionFromPosition:selectedRange.start offset:0]) {
            // 正在操作，不计算长度
            return;
        }
        self.changedString = textField.text;
    }
}

#pragma mark  选择空调名字按钮的点击s事件
- (IBAction)selectNameButtonAction:(UIButton *)sender {
    self.nameTextField.text =sender.titleLabel.text;
}

#pragma mark  确定按钮的点击事件
- (IBAction)actionNextStep:(id)sender {
    NSString *deviceName = self.nameTextField.text;
    if ([deviceName length] == 0) {
        [self showToastshortWithmessageinCenter:@"请输入设备名"];
        return;
    }
    if ([self.existedNameArray containsObject:deviceName]) {
        [self showToastshortWithmessageinCenter:@"该设备名已存在"];
        return;
    }
    [self showLoadingHUD];
    [[AUXNetworkManager manager] updateDeviceInfoWithMac:self.deviceInfo.mac deviceSN:nil alias:deviceName completion:^(NSError * _Nonnull error) {
        [self hideLoadingHUD];
        switch (error.code) {
            case AUXNetworkErrorNone: {
                [self showToastshortWithmessageinCenter:@"名字设置成功"];
                NSMutableArray<UIViewController *> *viewControllers = [self.navigationController.viewControllers mutableCopy];
                    [viewControllers removeObjectsInRange:NSMakeRange(1, viewControllers.count - 1)];
                    [self.navigationController setViewControllers:viewControllers animated:YES];
            }
                break;
            case AUXNetworkErrorAccountCacheExpired:
                [self alertAccountCacheExpiredMessage];
                break;
                
            case AUXNetworkErrorNotDeviceOwner:{
                [AUXSuccessJumpAlert alertViewtitle:@"啊哦，设备已经被别人配走了…" firstStr:@"重新配网" secondStr:@"确认" confirm:^{
                    NSLog(@"确认");
                    NSMutableArray<UIViewController *> *viewControllers = [self.navigationController.viewControllers mutableCopy];
                        [viewControllers removeObjectsInRange:NSMakeRange(1, viewControllers.count - 1)];
                        [self.navigationController setViewControllers:viewControllers animated:YES];
                   
                } close:^{
                    NSLog(@"重新配网");
                    if (self.isfromScan) {
                        AUXScanCodeViewController *scanCodeViewController = nil;
                        for (AUXBaseViewController *tempVc in self.navigationController.viewControllers) {
                            if ([tempVc isKindOfClass:[AUXScanCodeViewController class]]) {
                                scanCodeViewController = (AUXScanCodeViewController*)tempVc;
                                [self.navigationController popToViewController:scanCodeViewController animated:YES];
                            }
                        }
                    }else{
                        AUXSNCodeSearchViewController *snCodeSearchViewController = nil;
                        for (AUXBaseViewController *tempVc in self.navigationController.viewControllers) {
                            if ([tempVc isKindOfClass:[AUXSNCodeSearchViewController class]]) {
                                snCodeSearchViewController = (AUXSNCodeSearchViewController*)tempVc;
                                [self.navigationController popToViewController:snCodeSearchViewController animated:YES];
                            }
                        }
                    }
                }];
            }
                break;
            default:
                [self showToastshortWitherror:error];
                break;
        }
    }];
}

#pragma mark  点击空白处收回键盘
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

#pragma mark  :UITextField输入长度
-(void)textFieldEditChanged:(NSNotification *)obj
{
    UITextField *textField = (UITextField *)obj.object;
    NSString *text = textField.text;
    
    
    //获取高亮部分
    UITextRange *selectedRange = [textField markedTextRange];
    UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
    if (!position) {
        if (text.length > 20) {
            [self showToastshortWithmessageinCenter:@"空调命名不能大于20位"];
            NSRange range = [text rangeOfComposedCharacterSequenceAtIndex:20];
            if (range.length == 1) {
                textField.text = [text substringToIndex:20];
            }else{
                NSRange range = [text rangeOfComposedCharacterSequencesForRange:NSMakeRange(0, 20)];
                textField.text = [text substringWithRange:range];
            }
        }
    }
}

//MARK: 视图消失
-(void)viewDidDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"UITextFieldTextDidChangeNotification" object:nil];
}



- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.view endEditing:YES];
    [self actionNextStep:(id)self.nextButton];
    return YES;
}

@end

