//
//  AUXQuestionTypeTableViewCell.h
//  AUXSmartHome
//
//  Created by AUX on 2019/4/19.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXBaseTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUXQuestionTypeTableViewCell : AUXBaseTableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *selectImageView;
@property (weak, nonatomic) IBOutlet UILabel *questionLabel;

@end

NS_ASSUME_NONNULL_END
