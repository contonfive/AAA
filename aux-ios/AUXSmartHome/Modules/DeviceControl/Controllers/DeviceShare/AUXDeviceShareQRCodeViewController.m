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

#import "AUXDeviceShareQRCodeViewController.h"

#import "AUXDeviceListViewController.h"
#import "NSString+AUXCustom.h"
#import "UIColor+AUXCustom.h"

#import "AUXLFCGzipUtillity.h"
#import "AUXConfiguration.h"
#import "MIQRCodeGenerator.h"
#import "WXApi.h"
#import "TencentOpenAPI/QQApiInterface.h"
#import "AUXPopWindow.h"
#import "AUXSharing3rdAlertView.h"
#import "RACEXTScope.h"
#import "AUXButton.h"

#import "AUXWXApiRequestHandle.h"
#import "AUXNetworkManager.h"

#import "AppDelegate.h"

#define BUFFER_SIZE 1024 * 100

@interface AUXDeviceShareQRCodeViewController () <QMUINavigationControllerDelegate , AUXWXRequestHandleDelegate>

@property (weak, nonatomic) IBOutlet UILabel *tipLabel1;
@property (weak, nonatomic) IBOutlet UILabel *tipLabel2;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet AUXButton *shareSuccessBtn;

@property (nonatomic, strong) NSString *name;
@property (nonatomic,copy) NSString *ownerUid;

@property (nonatomic,copy) NSString *gzipQRContent;

@end

@implementation AUXDeviceShareQRCodeViewController

- (IBAction)sharing3rd:(UIBarButtonItem *)sender {
    @weakify(self)
    [AUXPopWindow.sharedInstance setPresentView:[AUXSharing3rdAlertView sharing3rdAlertViewWithCancelBlock:^{
        [AUXPopWindow.sharedInstance hideWithAnimation];
    } weChatBlock:^{
        @strongify(self)
        [self sharing2WeChat];
        [AUXPopWindow.sharedInstance hideWithAnimation];
    } qqBlock:^{
        @strongify(self)
        [self sharing2QQ];
        [AUXPopWindow.sharedInstance hideWithAnimation];
    }]];
    [AUXPopWindow.sharedInstance showWithAnimation];
}

- (void)sharing2WeChat {
    
    SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
    req.scene = WXSceneSession;
    req.bText = YES;
    req.text = self.gzipQRContent;
    [WXApi sendReq:req];
}

- (void)sharing2QQ {
    
    QQApiTextObject* obj = [QQApiTextObject objectWithText:self.gzipQRContent];
    SendMessageToQQReq* req = [SendMessageToQQReq reqWithContent:obj];
    [QQApiInterface sendReq:req];
}

- (IBAction)shareSuccessAtcion:(id)sender {
    
    for (AUXBaseViewController *baseViewController in self.navigationController.viewControllers) {
        
        if ([baseViewController isKindOfClass:NSClassFromString(@"AUXDeviceShareViewController")] || [baseViewController isKindOfClass:NSClassFromString(@"AUXUserCenterDeviceShareViewController")]) {
            [self.navigationController popToViewController:baseViewController animated:YES];
        }
    }
    
}

- (NSString *)name {
    if (!_name) {
        _name = [AUXUser defaultUser].nickName;
    }
    return _name;
}

- (NSString *)ownerUid {
    if (!_ownerUid) {
        _ownerUid = [AUXUser defaultUser].uid;
    }
    return _ownerUid;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.shareSuccessBtn.layer.borderWidth = 2;
    self.shareSuccessBtn.layer.borderColor = [UIColor colorWithHexString:@"256BBD"].CGColor;
    
    if (self.qrCodeStatus == AUXQRCodeStatusOfShareDevice) {
        
        self.title = @"分享二维码";
    } else if (self.qrCodeStatus == AUXQRCodeStatusOfShareFamilyInvitation) {
        NSString *tip1 = [NSString stringWithFormat:@"邀请成员扫描下方二维码加入""%@" , self.familyName];
        self.tipLabel1.text = tip1;
        self.title = @"添加成员";
    }
    
    NSString *timeString = @"15分钟";
    NSString *tip2 = [NSString stringWithFormat:@"二维码 %@ 内有效", timeString];
    NSRange range = [tip2 rangeOfString:timeString];
    NSMutableAttributedString *attributedTip2 = [[NSMutableAttributedString alloc] initWithString:tip2];
    [attributedTip2 addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"10BFCA"] range:range];
    self.tipLabel2.attributedText = attributedTip2;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        UIImage *image = [MIQRCodeGenerator createQRCodeForString:self.qrContent withSize:CGRectGetWidth(self.imageView.frame) * 2.0];
        self.imageView.image = image;
    });
    
    
    if (self.qrCodeStatus == AUXQRCodeStatusOfShareDevice) {
        [[AUXNetworkManager manager] getDeviceShareMessageWithQRContent:self.qrContent name:self.name  deviceName:self.deviceNames ownerUid:self.ownerUid  completion:^(NSString * _Nullable message, NSError * _Nonnull error) {
            self.gzipQRContent = message;
        }];
    } else if (self.qrCodeStatus == AUXQRCodeStatusOfShareFamilyInvitation) {
        self.gzipQRContent = @"testtesttesttesttesttesttesttesttesttest";
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
