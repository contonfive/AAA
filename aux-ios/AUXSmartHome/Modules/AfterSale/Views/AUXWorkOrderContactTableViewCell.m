//
//  AUXWorkOrderContactTableViewCell.m
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2018/10/10.
//  Copyright © 2018年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXWorkOrderContactTableViewCell.h"

@implementation AUXWorkOrderContactTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setWorkOrderDetailModel:(AUXSubmitWorkOrderModel *)workOrderDetailModel {
    _workOrderDetailModel = workOrderDetailModel;
    
    if (_workOrderDetailModel.TopContact) {
        self.contactNameLabel.text = _workOrderDetailModel.TopContact.Name;
        self.contactPhoneLabel.text = _workOrderDetailModel.TopContact.Phone;
        self.contactAddressLabel.text = _workOrderDetailModel.TopContact.local;
    }
}


@end
