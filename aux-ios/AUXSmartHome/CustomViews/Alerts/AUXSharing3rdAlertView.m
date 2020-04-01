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

#import "AUXSharing3rdAlertView.h"

@interface AUXSharing3rdAlertView()

@property (weak, nonatomic) IBOutlet UIView *container;
@property (weak, nonatomic) IBOutlet UIView *weChatView;
@property (weak, nonatomic) IBOutlet UIView *qqView;

@end

@implementation AUXSharing3rdAlertView

+ (instancetype)sharing3rdAlertViewWithCancelBlock:(void (^)(void))cancelBlock weChatBlock:(void (^)(void))weChatBlock qqBlock:(void (^)(void))qqBlock {
    AUXSharing3rdAlertView *alertView = [[[NSBundle mainBundle] loadNibNamed:@"AUXCustomAlertView" owner:nil options:nil] objectAtIndex:3];
    alertView.cancelBlock = cancelBlock;
    alertView.weChatBlock = weChatBlock;
    alertView.qqBlock = qqBlock;
    
//    alertView.container.layer.shadowColor = [[UIColor grayColor] CGColor];
//    alertView.container.layer.shadowOffset=CGSizeMake(2,2);
//    alertView.container.layer.shadowOpacity = 0.5;
    
    [alertView.weChatView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:alertView action:@selector(weChatAction)]];
    [alertView.qqView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:alertView action:@selector(qqAction)]];
    
    alertView.translatesAutoresizingMaskIntoConstraints = NO;
//    alertView.clipsToBounds = NO;
    [[alertView.heightAnchor constraintEqualToAnchor:alertView.container.heightAnchor] setActive:YES];
    
    return alertView;
}

- (IBAction)cancel:(UIButton *)sender {
    self.cancelBlock();
}

- (void)weChatAction {
    self.weChatBlock();
}

- (void)qqAction {
    self.qqBlock();
}

@end
