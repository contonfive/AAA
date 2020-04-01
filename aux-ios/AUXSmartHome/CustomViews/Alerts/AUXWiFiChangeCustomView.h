//
//  AUXWiFiChangeCustomView.h
//  AUXSmartHome
//
//  Created by AUX on 2019/4/25.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^ConfirmBlcok)(void);
typedef void(^CancelBlcok)(void);

NS_ASSUME_NONNULL_BEGIN

@interface AUXWiFiChangeCustomView : UIView
@property (weak, nonatomic) IBOutlet UIView *backView;
@property (weak, nonatomic) IBOutlet UIView *alertView;
@property (weak, nonatomic) IBOutlet UILabel *firstLabel;
@property (weak, nonatomic) IBOutlet UILabel *secondLabel;

- (void)alertViewWitholdWiFiName:(NSString *)oldwifiname newWiFiName:(NSString *)newWiFiName  confirmAtcion:(ConfirmBlcok)confirmAtcion cancelAction:(CancelBlcok)cancelAction;
- (void)hidden;
@end

NS_ASSUME_NONNULL_END
