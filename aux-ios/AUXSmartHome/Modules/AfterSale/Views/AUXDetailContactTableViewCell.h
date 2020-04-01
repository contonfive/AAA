//
//  AUXDetailContactTableViewCell.h
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2018/9/26.
//  Copyright © 2018年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXBaseTableViewCell.h"
#import "AUXTopContactModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUXDetailContactTableViewCell : AUXBaseTableViewCell

@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UIButton *isDefaultButton;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (weak, nonatomic) IBOutlet UIButton *editButton;

@property (nonatomic,strong) AUXTopContactModel *topContactModel;

@property (nonatomic, copy) void (^deleteBlock)(void);
@property (nonatomic, copy) void (^editBlock)(void);
@property (nonatomic, copy) void (^isDefaultBlock)(BOOL selected);

@end

NS_ASSUME_NONNULL_END
