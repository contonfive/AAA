//
//  AUXAfterSaleEditTableViewCell.m
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2018/9/18.
//  Copyright © 2018年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXAfterSaleEditTableViewCell.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface AUXAfterSaleEditTableViewCell ()

@end

@implementation AUXAfterSaleEditTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.whtherMustImageView.hidden = NO;
    self.deviceIconImageView.hidden = YES;
}

#pragma mark setters

- (void)setUnitNumberArray:(NSMutableArray *)unitNumberArray {
    _unitNumberArray = unitNumberArray;
}

- (void)setUnitDescribeArray:(NSMutableArray *)unitDescribeArray {
    _unitDescribeArray = _unitDescribeArray;
}

- (void)setIndexPath:(NSIndexPath *)indexPath {
    _indexPath = indexPath;
    self.whtherMustImageView.hidden = NO;
    self.detailButton.selected = NO;
    self.bottomView.hidden = NO;
    
    switch (_indexPath.row) {
        case 0:
            self.titleLabel.text = @"产品线";
            [self.detailButton setTitle:@"未选择" forState:UIControlStateNormal];
            break;
       
        case 1:
            self.titleLabel.text = @"购买单位类型";
            [self.detailButton setTitle:@"未选择" forState:UIControlStateNormal];
            break;
        case 2:
            self.titleLabel.text = @"购买日期";
            [self.detailButton setTitle:@"未选择" forState:UIControlStateNormal];
            self.bottomView.hidden = YES;
            
            break;
            
        default:
            break;
    }
    
}

- (void)setSubmitWorkOrdermodel:(AUXSubmitWorkOrderModel *)submitWorkOrdermodel {
    _submitWorkOrdermodel = submitWorkOrdermodel;
    
    if (_submitWorkOrdermodel && self.indexPath.section == 1) {
        
        if (self.indexPath.row == 0 && !AUXWhtherNullString(_submitWorkOrdermodel.Product.ProductGroupType.Name)) {
            [self.detailButton setTitle:_submitWorkOrdermodel.Product.ProductGroupType.Name forState:UIControlStateNormal];
            self.detailButton.selected = YES;
        } else if (self.indexPath.row == 1 && _submitWorkOrdermodel.Product.ActualChannelType != 0) {
            NSInteger index = [self.unitNumberArray indexOfObject:[NSString stringWithFormat:@"%ld" , _submitWorkOrdermodel.Product.ActualChannelType]];
            [self.detailButton setTitle:self.unitDescribeArray[index] forState:UIControlStateNormal];
            self.detailButton.selected = YES;
            
        } else if (self.indexPath.row == 2 && !AUXWhtherNullString(_submitWorkOrdermodel.Product.BuyDate)) {
            NSString *date = [_submitWorkOrdermodel.Product.BuyDate substringToIndex:10];
            date = [date stringByReplacingOccurrencesOfString:@"/" withString:@"-"];
            [self.detailButton setTitle:date forState:UIControlStateNormal];
            self.detailButton.selected = YES;
            
        }
    }
}

- (void)setDeviceModel:(AUXDeviceModel *)deviceModel {
    _deviceModel = deviceModel;
    
    if (_deviceModel) {
        if (self.indexPath.section == 1 && self.indexPath.row == 1) {
            [self.deviceIconImageView sd_setImageWithURL:[NSURL URLWithString:_deviceModel.deviceMainUri] placeholderImage:nil options:SDWebImageRefreshCached];
            [self.detailButton setTitle:_deviceModel.model forState:UIControlStateNormal];
            self.detailButton.selected = YES;
            self.deviceIconImageView.hidden = NO;
        }
    }
}

- (IBAction)detaiButtonAtcion:(id)sender {
    if (self.detailBlock) {
        self.detailBlock();
    }
}


@end
