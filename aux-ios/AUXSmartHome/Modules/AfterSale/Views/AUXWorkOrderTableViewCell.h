//
//  AUXWorkOrderTableViewCell.h
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2018/9/27.
//  Copyright © 2018年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXBaseTableViewCell.h"
#import "AUXWorkOrderModel.h"
#import "AUXServiceOrderModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUXWorkOrderTableViewCell : AUXBaseTableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *serviceListBgImageView;
@property (weak, nonatomic) IBOutlet UILabel *serviceListStateLabel;
@property (weak, nonatomic) IBOutlet UILabel *progressLabel;
@property (weak, nonatomic) IBOutlet UIImageView *deviceImageView;
@property (weak, nonatomic) IBOutlet UILabel *deviceNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *contactNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *contactPhoneLabel;
@property (weak, nonatomic) IBOutlet UILabel *createOnLabel;
@property (weak, nonatomic) IBOutlet UIButton *reminderButton;
@property (weak, nonatomic) IBOutlet UIButton *leaveMessageButton;
@property (weak, nonatomic) IBOutlet UIButton *evaluationButton;

@property (nonatomic,strong) AUXWorkOrderModel *workOrderModel;

@property (nonatomic, copy) void (^leaveMessageBlock)(void);
@property (nonatomic, copy) void (^reminderBlock)(void);
@property (nonatomic, copy) void (^evaluationBlock)(void);

@end

NS_ASSUME_NONNULL_END
