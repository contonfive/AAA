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

#import "AUXBindAccountViewController.h"
#import "AUXUserCenterViewController.h"
#import "AUXStoreDetailViewController.h"
#import "AUXStoreViewController.h"

#import "AUXLocalNetworkTool.h"
#import "AUXNetworkManager.h"
#import "AUXConfiguration.h"
#import "AUXTextField.h"
#import "AUXButton.h"
#import "AUXArchiveTool.h"
#import "UIColor+AUXCustom.h"

#import "AUXUseProtocolViewController.h"
#import "NSUserDefaults+AUXCuxtom.h"

#import "AUXCodeViewController.h"


@interface AUXBindAccountViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIView *underLine;
@property (weak, nonatomic) IBOutlet AUXTextField *phoneTextField;
@end

@implementation AUXBindAccountViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.phoneTextField.delegate = self;
    
    if (self.bindAccountType == AUXBindAccountTypeOfAfterSale) {
        self.customBackAtcion = YES;
    }

    if (self.isRegist) {
        UIButton *rightBtn = [[UIButton alloc]init];
        rightBtn.frame = CGRectMake(0, 0, 40, 30);
        [rightBtn setTitleColor:[UIColor colorWithHexString:@"333333"] forState:UIControlStateNormal];
        rightBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [rightBtn setTitle:@"跳过" forState:UIControlStateNormal];
        [rightBtn addTarget:self action:@selector(skipBarbuttonAction) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem * rightItem = [[UIBarButtonItem alloc]initWithCustomView:rightBtn];
        self.navigationItem.rightBarButtonItem = rightItem;
    }
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(phoneChanged:)name:@"UITextFieldTextDidChangeNotification" object:self.phoneTextField];
    
}

#pragma mark  :UITextField输入长度
-(void)phoneChanged:(NSNotification *)obj
{
    UITextField *textField = (UITextField *)obj.object;
    if (textField == self.phoneTextField) {
        NSString *text = textField.text;
        //获取高亮部分
        UITextRange *selectedRange = [textField markedTextRange];
        UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
        if (!position) {
            if (text.length > 11) {
                [self showToastshortWithmessageinCenter:@"手机号不能超过11位"];
                NSRange range = [text rangeOfComposedCharacterSequenceAtIndex:11];
                if (range.length == 1) {
                    textField.text = [text substringToIndex:11];
                }else{
                    NSRange range = [text rangeOfComposedCharacterSequencesForRange:NSMakeRange(0, 11)];
                    textField.text = [text substringWithRange:range];
                }
            }
        }
    }
}

- (void)backAtcion {
    [super backAtcion];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark  下一步按钮的点击事件
- (IBAction)nextButtonAction:(id)sender {
    if (![self isPhoneValid:self.phoneTextField.text]) {
        return;
    }
    AUXCodeViewController *codeViewController = [AUXCodeViewController instantiateFromStoryboard:kAUXStoryboardNameLogin];
    codeViewController.phoneNumber = self.phoneTextField.text;
    codeViewController.getCodeType = @"binding";
    codeViewController.bindAccountType = self.bindAccountType;
    codeViewController.homepageTabBarController = self.homepageTabBarController;
    [self.navigationController pushViewController:codeViewController animated:YES];
}

#pragma mark  跳过按钮的点击事件
- (void)skipBarbuttonAction {
    
    if (self.bindAccountType == AUXBindAccountTypeOfLogin) {
        if (self.homepageTabBarController) {
            self.homepageTabBarController.selectedIndex = kAUXTabDeviceSelected;
            [self.homepageTabBarController dismissViewControllerAnimated:YES completion:nil];
        }
    } else{
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

#pragma mark  判断手机号
- (BOOL)isPhoneValid:(NSString *)phone {
    if ([phone length] == 0) {
        [self showToastshortWithmessageinCenter:@"请输入手机号"];
        return NO;
    }
    if (!AUXCheckPhoneNumber(phone)) {
        [self showToastshortWithmessageinCenter:@"请输入正确的手机号"];
        return NO;
    }
    return YES;
}

#pragma mark - 开始编辑
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    self.underLine.backgroundColor = [UIColor colorWithHexString:@"333333"];
}

-(void)textFieldDidEndEditing:(UITextField *)textField{
    self.underLine.backgroundColor = [UIColor colorWithHexString:@"EEEEEE"];
}

#pragma mark  点击空白收回键盘
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}


@end



