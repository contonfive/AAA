//
//  AUXNotificationComponentPromptTableViewCell.h
//  AUXSmartHome
//
//  Created by 奥克斯家研--张海昌 on 2018/5/30.
//  Copyright © 2018年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXBaseTableViewCell.h"

@interface AUXNotificationComponentPromptTableViewCell : AUXBaseTableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titlabel;
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *iconImageViewHeight;

@property (nonatomic,strong) NSIndexPath *indexPath;
@property (nonatomic,strong) NSDictionary *dataDict;

@end
