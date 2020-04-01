//
//  AUXWorkOrderTableViewCell.m
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2018/9/27.
//  Copyright © 2018年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXWorkOrderTableViewCell.h"
#import "UIColor+AUXCustom.h"

@interface AUXWorkOrderTableViewCell()

@end

@implementation AUXWorkOrderTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.reminderButton.layer.borderColor = [UIColor colorWithHexString:@"256BBD"].CGColor;
    self.leaveMessageButton.layer.borderColor = [UIColor colorWithHexString:@"256BBD"].CGColor;
    self.evaluationButton.layer.borderColor = [UIColor colorWithHexString:@"256BBD"].CGColor;
    
    self.reminderButton.hidden = YES;
    self.leaveMessageButton.hidden = YES;
    
}

- (void)setWorkOrderModel:(AUXWorkOrderModel *)workOrderModel {
    _workOrderModel = workOrderModel;
    
    if (_workOrderModel) {
        self.serviceListBgImageView.image = _workOrderModel.workOrderType == AUXAfterSaleTypeOfMaintenance ? [UIImage imageNamed:@"mine_service_list_icon_repair"] : [UIImage imageNamed:@"mine_service_list_icon_install"];
        self.serviceListStateLabel.text = _workOrderModel.workOrderType == AUXAfterSaleTypeOfMaintenance ? @"预约维修" : @"预约安装";
        self.deviceNameLabel.text = _workOrderModel.ProductGroup;
        self.progressLabel.text = _workOrderModel.State;
        self.deviceImageView.image = [_workOrderModel.ProductGroup isEqualToString:@"家用空调"] ? [UIImage imageNamed:@"mine_service_list_img_jiayong"] : [UIImage imageNamed:@"mine_service_list_img_center"];
        self.contactNameLabel.text = _workOrderModel.Contact;
        self.contactPhoneLabel.text = _workOrderModel.Phone;
        self.createOnLabel.text = _workOrderModel.Createdon;
        
        self.evaluationButton.hidden = _workOrderModel.IsFinsh ? NO : YES;
        
    }
    
}

- (IBAction)leaveMessageAtcion:(id)sender {
    if (self.leaveMessageBlock) {
        self.leaveMessageBlock();
    }
}

- (IBAction)evaluationAtcion:(id)sender {
    if (self.evaluationBlock) {
        self.evaluationBlock();
    }
}

- (IBAction)reminderAtcion:(id)sender {
    if (self.reminderBlock) {
        self.reminderBlock();
    }
}

@end
