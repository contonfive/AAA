//
//  AUXAfterSaleEditTableViewCell.h
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2018/9/18.
//  Copyright © 2018年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXBaseTableViewCell.h"
#import "AUXDeviceModel.h"
#import "AUXSubmitWorkOrderModel.h"

@interface AUXAfterSaleEditTableViewCell : AUXBaseTableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *whtherMustImageView;
@property (weak, nonatomic) IBOutlet UIImageView *rightArrowIconImage;
@property (weak, nonatomic) IBOutlet UIButton *detailButton;
@property (weak, nonatomic) IBOutlet UIImageView *deviceIconImageView;

@property (nonatomic,strong) AUXSubmitWorkOrderModel *submitWorkOrdermodel;

@property (nonatomic,strong) NSMutableArray *unitNumberArray;
@property (nonatomic,strong) NSMutableArray *unitDescribeArray;

@property (nonatomic, copy) void (^detailBlock)(void);
@property (nonatomic,strong) NSIndexPath *indexPath;
@property (nonatomic,strong) AUXDeviceModel *deviceModel;

@end
