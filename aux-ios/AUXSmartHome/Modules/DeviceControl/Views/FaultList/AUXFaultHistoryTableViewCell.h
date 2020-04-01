//
//  AUXFaultHistoryTableViewCell.h
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2019/4/28.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXBaseTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUXFaultHistoryTableViewCell : AUXBaseTableViewCell

@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailTimeLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentLabelBottom;


@end

NS_ASSUME_NONNULL_END
