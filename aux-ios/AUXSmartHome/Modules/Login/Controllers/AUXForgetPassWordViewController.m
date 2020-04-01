//
//  AUXForgetPassWordViewController.m
//  AUXSmartHome
//
//  Created by AUX on 2019/3/25.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXForgetPassWordViewController.h"
#import "AUXCodeViewController.h"
#import "UIColor+AUXCustom.h"
#import "AUXNetworkManager.h"


@interface AUXForgetPassWordViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *phoneTextField;
@property (weak, nonatomic) IBOutlet UIView *underLine;
@end

@implementation AUXForgetPassWordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.phoneTextField.text = self.phoneNumber;
    self.phoneTextField.delegate = self;
    
  
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textFieldEditChanged:)
                                                name:@"UITextFieldTextDidChangeNotification" object:nil];
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
            if (text.length > 11) {
                [self showToastshortWithmessageinCenter:@"手机号长能超过11位"];
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


#pragma mark  下一步
- (IBAction)nextButtonAction:(UIButton *)sender {
    if (!AUXCheckPhoneNumber(self.phoneTextField.text)) {
        [self showToastshortWithmessageinCenter:@"请输入正确的手机号"];
        return;
    }    
    [[AUXNetworkManager manager] forgetPwdPhone:self.phoneTextField.text completion:^(NSString * _Nonnull code, NSError * _Nonnull error) {
        
        if (error.code == AUXNetworkErrorNone) {
            AUXCodeViewController *codeViewController = [AUXCodeViewController instantiateFromStoryboard:kAUXStoryboardNameLogin];
            codeViewController.phoneNumber = self.phoneTextField.text;
            codeViewController.getCodeType = self.getCodeType;
            [self.navigationController pushViewController:codeViewController animated:YES];
        }else if (error.code == AUXNetworkErrorInvalidCode1){
            AUXCodeViewController *codeViewController = [AUXCodeViewController instantiateFromStoryboard:kAUXStoryboardNameLogin];
            codeViewController.phoneNumber = self.phoneTextField.text;
            codeViewController.getCodeType = self.getCodeType;
            [self showToastshortWitherror:error];
            [self.navigationController pushViewController:codeViewController animated:YES];
        }else {
            [self showToastshortWitherror:error];
        }
    }];
}


#pragma mark - 开始编辑
- (void)textFieldDidBeginEditing:(UITextField *)textField{
        self.underLine.backgroundColor = [UIColor colorWithHexString:@"333333"];
}

-(void)textFieldDidEndEditing:(UITextField *)textField{
    self.underLine.backgroundColor = [UIColor colorWithHexString:@"EEEEEE"];
}

#pragma mark  点击空白处收回键盘
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}


- (void)viewDidDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter]removeObserver:self];

}


@end
