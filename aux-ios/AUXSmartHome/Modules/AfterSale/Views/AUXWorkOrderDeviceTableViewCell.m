//
//  AUXWorkOrderDeviceTableViewCell.m
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2018/10/10.
//  Copyright © 2018年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXWorkOrderDeviceTableViewCell.h"
#import "AUXNetworkManager.h"
#import "NSDate+AUXCustom.h"

@interface AUXWorkOrderDeviceTableViewCell ()


@end

@implementation AUXWorkOrderDeviceTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setWorkOrderDetailModel:(AUXSubmitWorkOrderModel *)workOrderDetailModel {
    _workOrderDetailModel = workOrderDetailModel;
    
    if (_workOrderDetailModel) {
        self.deviceImageView.image = [_workOrderDetailModel.Product.ProductGroupType.Name isEqualToString:@"家用空调"] ? [UIImage imageNamed:@"service_img_jiayong"] : [UIImage imageNamed:@"service_img_center"];
        self.deviceNameLabel.text = _workOrderDetailModel.Product.ProductGroupType.Name;
        self.buyFromLabel.text = _workOrderDetailModel.channeltype;
        
        if (!AUXWhtherNullString(_workOrderDetailModel.purchase_date)) {
            
            NSString *buyDate = _workOrderDetailModel.purchase_date;
            NSString *timeDate = [buyDate componentsSeparatedByString:@" "].firstObject;
            NSArray *timeArray = [timeDate componentsSeparatedByString:@"/"];
            
            NSMutableArray *array = [NSMutableArray array];
            for (NSInteger i = 0; i < timeArray.count ; i++) {
                NSString *time = timeArray[i];
                if (time.length > 2) {
                    [array addObject:time];
                    continue;
                }
                time = [NSString stringWithFormat:@"%.2ld" , time.integerValue];
                [array addObject:time];
            }
            timeArray = [NSArray arrayWithArray:array];
            
            NSString *purchase = [NSString string];
            for (NSString *time in timeArray) {
                purchase = [purchase stringByAppendingString:time];
                purchase = [purchase stringByAppendingString:@"/"];
            }
            purchase = [purchase substringToIndex:purchase.length - 1];
            
            self.buyDateLabel.text = purchase;
        }
    }
}

@end
