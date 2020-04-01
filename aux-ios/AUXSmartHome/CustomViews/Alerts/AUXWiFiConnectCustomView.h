//
//  AUXWiFiConnectCustomView.h
//  AUXSmartHome
//
//  Created by AUX on 2019/4/25.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef void(^ConfirmBlcok)(void);

@interface AUXWiFiConnectCustomView : UIView
@property (weak, nonatomic) IBOutlet UIView *backView;
@property (weak, nonatomic) IBOutlet UIView *alertView;

+ (void)alertWiFiConnectCustomViewconfirmAtcion:(ConfirmBlcok)confirmAtcion;

@end

NS_ASSUME_NONNULL_END
