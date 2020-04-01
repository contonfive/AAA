//
//  AUXWorkOrderDetailProgressTableViewCell.m
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2018/9/27.
//  Copyright © 2018年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXWorkOrderDetailProgressTableViewCell.h"
#import "UIColor+AUXCustom.h"

@implementation AUXWorkOrderDetailProgressTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setWorkOrderDetailModel:(AUXSubmitWorkOrderModel *)workOrderDetailModel {
    _workOrderDetailModel = workOrderDetailModel;
    
    if (_workOrderDetailModel.RequireinstalTime2.length > 10) {
        NSArray *timeArray = [_workOrderDetailModel.RequireinstalTime2 componentsSeparatedByString:@" "];
        
        NSString *string = nil;
        if (self.productModel.workOrderType == AUXAfterSaleTypeOfMaintenance) {
            string = @"报修";
        } else {
            string = @"报装";
        }
        string = [string stringByAppendingString:[NSString stringWithFormat:@"预约日期：%@" , [timeArray firstObject]]];
        self.serviceStateTypeLabel.text = string;
    }
}

- (void)setProductModel:(AUXProduct *)productModel {
    _productModel = productModel;
    
    if (_productModel) {
        self.serviceBgImageView.image = _productModel.workOrderType == AUXAfterSaleTypeOfMaintenance ? [UIImage imageNamed:@"mine_service_list_icon_repair"] : [UIImage imageNamed:@"mine_service_list_icon_install"];
        
        [self.stateButtons enumerateObjectsUsingBlock:^(UIButton *button, NSUInteger idx, BOOL * _Nonnull stop) {
            button.selected = NO;
            button.titleLabel.font = [UIFont systemFontOfSize:14];
            if (idx == productModel.Status.integerValue - 1) {
                button.selected = YES;
                button.titleLabel.font = [UIFont systemFontOfSize:16];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [UIView animateWithDuration:0.3 animations:^{
                        self.serviceProgressImageViewCenterX.constant = button.frame.origin.x;
                        
                        [self layoutIfNeeded];
                    } completion:^(BOOL finished) {
                        
                        self.serviceGradientView.backgroundColor = [UIColor colorWithHexString:@"256BBD"];
                    }];
                });
            }
        }];
    }
}

@end
