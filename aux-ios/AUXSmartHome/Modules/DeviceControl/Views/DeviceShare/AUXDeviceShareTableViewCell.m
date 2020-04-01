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

#import "AUXDeviceShareTableViewCell.h"
#import "AUXTimerObject.h"

@interface AUXDeviceShareTableViewCell ()

@property (retain, nonatomic) NSTimer *timer;
@property (assign, nonatomic) int expiredHour;
@property (assign, nonatomic) int expiredMinute;
@property (assign, nonatomic) int expiredSecond;
@end

@implementation AUXDeviceShareTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
//    self.iconImageView.layer.cornerRadius = 22;
//    self.iconImageView.layer.masksToBounds = YES;
    
    self.indicatorImageView.hidden = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)setType:(AUXDeviceShareType)type {
    _type = type;
    
    if (_type == AUXDeviceShareTypeFamily) {
        self.subtitleLabel.hidden = YES;
        self.relieveBtnCenterY.constant = 0;
        [self layoutIfNeeded];
    }else{
        self.subtitleLabel.hidden = NO;
        self.relieveBtnCenterY.constant = -17;
        [self layoutIfNeeded];
    }
}

- (void)setShowIndicatorImageView:(BOOL)showIndicatorImageView {
    _showIndicatorImageView = showIndicatorImageView;
    
    if (_showIndicatorImageView) {
        self.indicatorImageView.hidden = NO;
        self.relieveButton.hidden = YES;
        self.relieveIcon.hidden = YES;
        self.subtitleLabel.hidden = NO;
        self.subtitleLabelTriling.constant = 36;
        self.subtitleLabelTop.constant = -(self.subtitleLabel.frame.size.height / 2);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self layoutIfNeeded];
        });
    }
}

- (void)setShowIconImageView:(BOOL)showIconImageView {
    _showIconImageView = showIconImageView;
    
    if (_showIconImageView) {
        self.titleLabelLeading.constant = 74;
        
        [self layoutIfNeeded];
    }
}

- (void)setExpiredTimerInterval:(NSTimeInterval)expiredTimerInterval {
    _expiredTimerInterval = expiredTimerInterval;
    
    self.subtitleLabel.hidden = NO;
    [self calculateExpiredTimer:self.expiredTimerInterval];
    self.timer = [AUXTimerObject scheduledWeakTimerWithTimeInterval:1 target:self selector:@selector(checkExpiredTimer) userInfo:nil repeats:YES];
}

- (void)checkExpiredTimer {
    if (self.expiredTimerInterval == 0 && self.timer) {
        // 无过期时间，停止计时器
        [self.timer invalidate];
        self.timer = nil;
        return;
    }
    if (!self.timer) {
        return;
    }
    
    [self calculateExpiredTimer:self.expiredTimerInterval];
}

- (void)calculateExpiredTimer:(NSTimeInterval)expiredTimerInterval {
    
    NSTimeInterval leftSeconds = expiredTimerInterval - [[NSDate date] timeIntervalSince1970];
    if (leftSeconds <= 0) {
        // 到达过期时间，停止计时器，从列表中移除
        [self.timer invalidate];
        self.timer = nil;
        [self.viewController removeCellAtIndexPath:self.indexPath];
        [self.deviceShareViewController removeCellAtIndexPath:self.indexPath];
        return;
    }
    
    NSString *leftTime;
    int currentExpiredHour = leftSeconds / 60 / 60;
    int currentExpiredMinute = ((int) (leftSeconds / 60)) % 60;
    if (currentExpiredHour == 0 && currentExpiredMinute == 0) {
        self.expiredSecond = ((int) leftSeconds) % 60;
        leftTime = [NSString stringWithFormat:@"%d秒", self.expiredSecond];
    } else {
        if (currentExpiredHour != self.expiredHour || currentExpiredMinute != self.expiredMinute) {
            if (currentExpiredMinute == 59) {
                leftTime = [NSString stringWithFormat:@"%d小时0分钟", currentExpiredHour + 1];
            } else {
                leftTime = [NSString stringWithFormat:@"%d小时%d分钟", currentExpiredHour, currentExpiredMinute + 1];
            }
        } else {
            return;
        }
    }
    NSString *leftTimeString = [NSString stringWithFormat:@"%@后失效" , leftTime];
    self.subtitleLabel.text = leftTimeString;
}

- (IBAction)actionRelieveSharing:(id)sender {
    if (self.relieveBlock) {
        self.relieveBlock();
    }
}

@end
