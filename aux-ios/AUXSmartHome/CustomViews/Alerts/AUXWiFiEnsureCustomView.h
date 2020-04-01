//
//  AUXWiFiEnsureCustomView.h
//  AUXSmartHome
//
//  Created by AUX on 2019/4/25.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^ConfirmBlcok)(void);
typedef void(^ChangeBlcok)(void);
NS_ASSUME_NONNULL_BEGIN

@interface AUXWiFiEnsureCustomView : UIView
@property (weak, nonatomic) IBOutlet UIView *backView;
@property (weak, nonatomic) IBOutlet UIView *alertView;
@property (weak, nonatomic) IBOutlet UILabel *wifiNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *wifiPasswordLabel;

+ (void)alertViewWithWiFiName:(NSString *)wifiname  pwd:(NSString *)pwd confirmAtcion:(ConfirmBlcok)confirmAtcion changeAction:(ChangeBlcok)changeAction;
@end

NS_ASSUME_NONNULL_END
