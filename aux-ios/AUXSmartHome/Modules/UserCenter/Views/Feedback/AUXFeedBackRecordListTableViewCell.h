//
//  AUXFeedBackRecordListTableViewCell.h
//  AUXSmartHome
//
//  Created by AUX on 2019/4/19.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXBaseTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUXFeedBackRecordListTableViewCell : AUXBaseTableViewCell
@property (weak, nonatomic) IBOutlet UILabel *questionNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *questionDetailLabel;
@property (weak, nonatomic) IBOutlet UILabel *numberLabel;

@end

NS_ASSUME_NONNULL_END
