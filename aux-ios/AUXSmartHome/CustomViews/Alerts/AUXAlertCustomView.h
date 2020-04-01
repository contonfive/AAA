//
//  AUXAlertCustomView.h
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2019/4/12.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^ConfirmBlcok)(void);
typedef void(^CancleBlcok)(void);

NS_ASSUME_NONNULL_BEGIN

@interface AUXAlertCustomView : UIView

@property (weak, nonatomic) IBOutlet UIView *backView;
@property (weak, nonatomic) IBOutlet UIView *alertView;
@property (weak, nonatomic) IBOutlet UILabel *alertMessageLabel;
@property (weak, nonatomic) IBOutlet UIButton *sureBtn;
@property (weak, nonatomic) IBOutlet UIButton *cancleBtn;
@property (weak, nonatomic) IBOutlet UIButton *expireBtn;

@property (weak, nonatomic) IBOutlet UIView *horizonView;
@property (weak, nonatomic) IBOutlet UIView *verticallyView;


+ (AUXAlertCustomView *)alertViewWithMessage:(NSString *)message confirmAtcion:(ConfirmBlcok)confirmAtcion cancleAtcion:(CancleBlcok)cancleAtcion;

@property (nonatomic,assign) BOOL onlyShowSureBtn;
@property (nonatomic,copy) NSString *confirmTitle;
@property (nonatomic,copy) NSString *cancleTitle;

@end

NS_ASSUME_NONNULL_END
