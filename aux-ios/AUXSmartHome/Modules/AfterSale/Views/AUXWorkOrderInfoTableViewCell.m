//
//  AUXWorkOrderInfoTableViewCell.m
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2018/10/10.
//  Copyright © 2018年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXWorkOrderInfoTableViewCell.h"

@implementation AUXWorkOrderInfoTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setWorkOrderDetailModel:(AUXSubmitWorkOrderModel *)workOrderDetailModel {
    _workOrderDetailModel = workOrderDetailModel;
    
    if (_workOrderDetailModel) {
        if (_workOrderDetailModel.Product.workOrderType == AUXAfterSaleTypeOfInstallation) {
            self.logisticsLabel.hidden = NO;
            self.logisticsStatusLabel.hidden = NO;
            self.logisticsStatusLabel.text = _workOrderDetailModel.Logistics;
            self.serviceNumberTitleLabelCenterY.constant = 10;
        } else {
            self.logisticsLabel.hidden = YES;
            self.logisticsStatusLabel.hidden = YES;
            self.serviceNumberTitleLabelCenterY.constant = 0;
        }
        
        self.memoLabel.text = _workOrderDetailModel.Memo;
        self.serviceNumberLabel.text = _workOrderDetailModel.name;
        self.createDateLabel.text = _workOrderDetailModel.createdon;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self layoutIfNeeded];
        });
    }
}

@end
