//
//  AUXWorkOrderServiceStatusTableViewCell.m
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2018/10/10.
//  Copyright © 2018年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXWorkOrderServiceStatusTableViewCell.h"

@interface AUXWorkOrderServiceStatusTableViewCell()

@property (nonatomic,strong) NSArray *statusArray;

@end

@implementation AUXWorkOrderServiceStatusTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.statusArray = @[@"受理" , @"派单" , @"预约" , @"完工" , @"评价"];
}

- (void)setWorkOrderModel:(AUXWorkOrderModel *)workOrderModel {
    _workOrderModel = workOrderModel;
    if (_productModel.ProgressList.count == 0) {
        self.createDateLabel.text = _workOrderModel.Createdon;
    }
}

- (void)setProductModel:(AUXProduct *)productModel {
    _productModel = productModel;
    
    if (_productModel.ProgressList.count != 0) {
        for (AUXProgressListModel *progressModel in _productModel.ProgressList) {
            progressModel.DealDate = [NSString stringWithFormat:@"%@ %@" , progressModel.DealDate , progressModel.DealTime];
        }
        
        NSArray *dataArray = [NSArray arrayWithArray:_productModel.ProgressList];
        
        NSSortDescriptor *sorter = [[NSSortDescriptor alloc] initWithKey:@"DealDate" ascending:NO];
        NSMutableArray *sortDescriptors = [[NSMutableArray alloc] initWithObjects:&sorter count:1];
        _productModel.ProgressList = [dataArray sortedArrayUsingDescriptors:sortDescriptors];
        
        for (AUXProgressListModel *progressModel in _productModel.ProgressList) {
            progressModel.DealDate = [progressModel.DealDate substringToIndex:10];
        }
        
        AUXProgressListModel *progressModel = _productModel.ProgressList.firstObject;
        
        self.statusLabel.text = [NSString stringWithFormat:@"【%@】" , progressModel.Status];
        self.statusContentlabel.text = progressModel.Memo;
        self.createDateLabel.text = [NSString stringWithFormat:@"%@  %@" , progressModel.DealDate , progressModel.DealTime];
    } else {
        
        self.statusLabel.text = [NSString stringWithFormat:@"【%@】" , @"已受理"];
        self.statusContentlabel.text = @"报装（报修）服务工单已提交，正在等待派单";
    }
    
    if (_productModel.ProgressList.count == 0) {
        self.rightImageView.hidden = YES;
        self.userInteractionEnabled = NO;
    } else {
        self.rightImageView.hidden = NO;
        self.userInteractionEnabled = YES;
    }
}

@end
