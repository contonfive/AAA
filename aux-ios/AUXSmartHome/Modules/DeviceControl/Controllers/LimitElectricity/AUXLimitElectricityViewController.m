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

#import "AUXLimitElectricityViewController.h"
#import "AUXAlertCustomView.h"
#import "UILabel+AUXCustom.h"
#import "UIColor+AUXCustom.h"

@interface AUXLimitElectricityViewController ()

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentViewHeight;

@property (weak, nonatomic) IBOutlet UIButton *switchButton;
@property (weak, nonatomic) IBOutlet UILabel *tipLabel;

@property (weak, nonatomic) IBOutlet UIView *percentageContentView;

@property (weak, nonatomic) IBOutlet UIView *sliderContentView;
@property (weak, nonatomic) IBOutlet UISlider *slider;

@property (weak, nonatomic) IBOutlet UILabel *percentageLabel;

@property (weak, nonatomic) IBOutlet UILabel *minLabel;
@property (weak, nonatomic) IBOutlet UILabel *maxLabel;
@property (weak, nonatomic) IBOutlet UIImageView *minImageView;
@property (weak, nonatomic) IBOutlet UIImageView *maxImageView;

@property (weak, nonatomic) IBOutlet UILabel *bottomTipLabel;
@property (weak, nonatomic) IBOutlet UILabel *secondlabel;
@property (weak, nonatomic) IBOutlet UILabel *thirtyLabel;

@property (nonatomic, strong) UITapGestureRecognizer *sliderTapGesture;

@property (nonatomic, assign) NSInteger minPercentage;
@property (nonatomic, assign) NSInteger maxPercentage;

@property (nonatomic,assign) BOOL lastState;
@property (nonatomic,assign) NSInteger lastPersent;

@end

@implementation AUXLimitElectricityViewController

- (instancetype)initWithCoder:(NSCoder *)coder {
    
    self = [super initWithCoder:coder];
    if (self) {
        self.minPercentage = kAUXElectricityLimitPercentageMin;
        self.maxPercentage = kAUXElectricityLimitPercentageMax;
        
        _percentage = self.minPercentage;
        _on = NO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGFloat value = (self.percentage - self.minPercentage) / (CGFloat)(self.maxPercentage - self.minPercentage);
    self.slider.value = value;
    
    self.percentageLabel.text = [NSString stringWithFormat:@"%@%%", @(self.percentage)];
    
    self.switchButton.selected = self.on;
    
    [self.bottomTipLabel setLabelAttributedStringWithTextArray:@[@"限制空调" , @"最大功率"] color:[UIColor colorWithHexString:@"10BFCA"]];
    [self.secondlabel setLabelAttributedStringWithTextArray:@[@"百分比越小" , @"功率越低"] color:[UIColor colorWithHexString:@"10BFCA"]];
    
    [self updateUIAnimated:NO];
    
    self.lastState = self.on;
    self.lastPersent = self.percentage;

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.customBackAtcion = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)initSubviews {
    [super initSubviews];
    
    [self.slider setThumbImage:[UIImage imageNamed:@"device_btn_slide_small"] forState:UIControlStateNormal];
    
    self.sliderTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionTapSlider:)];
    [self.sliderContentView addGestureRecognizer:self.sliderTapGesture];
}

#pragma mark getter & setter
- (void)setPercentage:(NSInteger)percentage {
    
    if (percentage < self.minPercentage) {
        percentage = self.minPercentage;
    } else if (percentage > self.maxPercentage) {
        percentage = self.maxPercentage;
    }
    
    _percentage = percentage;
    self.percentageLabel.text = [NSString stringWithFormat:@"%@%%", @(percentage)];
    
    CGFloat value = (percentage - self.minPercentage) / (CGFloat)(self.maxPercentage - self.minPercentage);
    [self.slider setValue:value animated:YES];
}

- (void)setOn:(BOOL)on {
    [self setOn:on animated:NO];
}

- (void)setOn:(BOOL)on animated:(BOOL)animated {
    if (_on == on) {
        return;
    }
    
    _on = (on != 0) ? YES : NO;
    self.switchButton.selected = on;
    [self updateUIAnimated:animated];
}

#pragma mark UI更新
- (void)updateUIAnimated:(BOOL)animated {
    
    if (self.on) {
        [self showSliderAnimated:animated];
    } else {
        [self hideSliderAnimated:animated];
    }
}

- (void)showSliderAnimated:(BOOL)animated {
    
    if (animated) {
        self.contentViewHeight.constant = 152;
        self.percentageContentView.hidden = NO;
        self.percentageContentView.alpha = 0;
        
        [UIView animateWithDuration:0.25 animations:^{
            self.percentageContentView.alpha = 1;
            [self.view layoutIfNeeded];
        }];
    } else {
        self.contentViewHeight.constant = 152;
        self.percentageContentView.hidden = NO;
        [self.view layoutIfNeeded];
    }
}

- (void)hideSliderAnimated:(BOOL)animated {

    if (animated) {
        self.contentViewHeight.constant = 60;
        [UIView animateWithDuration:0.25 animations:^{
            self.percentageContentView.alpha = 0;
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            self.percentageContentView.hidden = YES;
            self.percentageContentView.alpha = 1;
        }];
    } else {
        self.contentViewHeight.constant = 60;
        self.percentageContentView.hidden = YES;
        [self.view layoutIfNeeded];
    }
}

#pragma mark - Actions
- (void)backAtcion {
    [super backAtcion];
    
    if (self.lastState == self.on && self.lastPersent == self.percentage) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [AUXAlertCustomView alertViewWithMessage:@"是否放弃更改?" confirmAtcion:^{
            [self.navigationController popViewControllerAnimated:YES];
        } cancleAtcion:^{
            
        }];
    }
}

- (IBAction)confirmAtcion:(id)sender {
    if (self.controlBlock) {
        self.controlBlock(_on, _percentage);
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)actionSwitch:(id)sender {
    self.switchButton.selected = !self.switchButton.selected;
    
    _on = self.switchButton.selected;
    
    [self updateUIAnimated:YES];
}

- (IBAction)actionSliderValueChanged:(id)sender {
    
    if (self.sliderTapGesture.enabled) {
        self.sliderTapGesture.enabled = NO;
    }
    
    CGFloat value = self.slider.value;
    
    NSInteger percentage = self.minPercentage + (self.maxPercentage - self.minPercentage) * value;
    self.percentageLabel.text = [NSString stringWithFormat:@"%@%%", @(percentage)];
    
    if (percentage > self.minPercentage) {
        self.minImageView.highlighted = YES;
    }
    if (percentage >= self.maxPercentage) {
        self.maxImageView.highlighted = YES;
    } else {
        self.maxImageView.highlighted = NO;
    }
}

// 滑动结束
- (IBAction)actionSliderEndSlide:(id)sender {
    
    CGFloat value = self.slider.value;
    
    NSInteger percentage = self.minPercentage + (self.maxPercentage - self.minPercentage) * value;
    
    self.sliderTapGesture.enabled = YES;
    
    if (self.percentage == percentage) {
        return;
    }
    
    _percentage = percentage;
}

// 点击 slider 调节
- (void)actionTapSlider:(UIGestureRecognizer *)sender {
    
    if (sender.state == UIGestureRecognizerStateRecognized) {
        CGPoint point = [sender locationInView:self.sliderContentView];
        
        CGFloat minX = CGRectGetMinX(self.slider.frame);
        CGFloat maxX = CGRectGetMaxX(self.slider.frame);
        
        if (point.x < minX - 5 || point.x > maxX + 5) {
            return;
        }
        
        CGFloat width = CGRectGetWidth(self.slider.frame);
        CGFloat value = (point.x - minX) / width;
        if (value < 0) {
            value = 0;
        } else if (value > 1.0) {
            value = 1.0;
        }
        
        [self.slider setValue:value animated:YES];
        
        NSInteger percentage = self.minPercentage + (self.maxPercentage - self.minPercentage) * value;
        
        self.percentageLabel.text = [NSString stringWithFormat:@"%@%%", @(percentage)];
        
        _percentage = percentage;
        
        if (percentage > self.minPercentage) {
            self.minImageView.highlighted = YES;
        }
        if (percentage >= self.maxPercentage) {
            self.maxImageView.highlighted = YES;
        } else {
            self.maxImageView.highlighted = NO;
        }
    }
}


@end
