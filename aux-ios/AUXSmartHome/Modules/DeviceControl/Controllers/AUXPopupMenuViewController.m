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

#import "AUXPopupMenuViewController.h"

@interface AUXPopupMenuViewController ()

@end

@implementation AUXPopupMenuViewController

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        /**
         definesPresentationContext = YES
         在present一个viewController时会需要一个提供背景的viewController，设置definespresentationcontext为true可以把当前的viewController设置为present的背景，present时会从当前容器中找presentationcontext，没有找到就默认为当前容器的rootViewController
         */
        self.definesPresentationContext = YES;
        //可以定义模态过渡转场的样式
        self.providesPresentationContextTransitionStyle = YES;
        /**
         UIModalTransitionStyle是弹出模态ViewController时的四种动画风格，UIModalTransitionStyleCoverVertical是从底部滑入，UIModalTransitionStyleFlipHorizontal是水平翻转，UIModalTransitionStyleCrossDissolve是交叉溶解，UIModalTransitionStylePartialCurl是翻页效果。
         */
        self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        /**
         UIModalPresentationStyle是弹出模态ViewController时弹出风格，UIModalPresentationFullScreen是弹出VC时，VC充满全屏，UIModalPresentationPageSheet是如果设备横屏，VC的显示方式则从横屏下方开始，UIModalPresentationFormSheet是VC显示都是从底部，宽度和屏幕宽度一样。UIModalPresentationCurrentContext是VC的弹出方式和VC父VC的弹出方式相同。.
         */
        self.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIImage *image = self.menuBackgroundImageView.image;
    CGSize size = image.size;
    image = [image stretchableImageWithLeftCapWidth:(size.width / 2.0) topCapHeight:(size.height / 2.0)];
    self.menuBackgroundImageView.image = image;
    
    self.menuView.clipsToBounds = NO;
    self.menuView.layer.masksToBounds = NO;
    self.menuView.layer.shadowColor = [UIColor lightGrayColor].CGColor;
    self.menuView.layer.shadowOpacity = 1.0;
    self.menuView.layer.shadowOffset = CGSizeMake(0, 0);
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionTapToDismiss:)];
    [self.view addGestureRecognizer:tapGesture];
    
    for (UIButton *button in self.menuButtonCollection) {
        [button addTarget:self action:@selector(actionMenuButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dismiss {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Actions

- (void)actionTapToDismiss:(UIGestureRecognizer *)sender {
    
    CGPoint point = [sender locationInView:self.view];
    
    if (!CGRectContainsPoint(self.menuView.frame, point)) {
        [self dismiss];
    }
}

#pragma mark - Actions

- (void)actionMenuButtonClicked:(UIButton *)sender {
    
    NSInteger index = -1;
    AUXPopupMenuSelectBlock selectBlock = self.menuSelectBlock;
    
    for (UIButton *button in self.menuButtonCollection) {
        if ([button isEqual:sender]) {
            index = button.tag - kAUXPopupMenuButtonTag;
            continue;
        }
    }
    
    [self.presentingViewController dismissViewControllerAnimated:YES completion:^{
        
        if (selectBlock) {
            selectBlock(index);
        }
    }];
}

@end
