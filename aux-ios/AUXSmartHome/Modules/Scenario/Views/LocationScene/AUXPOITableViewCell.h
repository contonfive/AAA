//
//  AUXPOITableViewCell.h
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2018/8/22.
//  Copyright © 2018年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXBaseTableViewCell.h"

@interface AUXPOITableViewCell : AUXBaseTableViewCell
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLable;
@property (weak, nonatomic) IBOutlet UIImageView *arrowImageview;

@end
