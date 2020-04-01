//
//  AUXFeedBackDetailfirstTableViewCell.h
//  AUXSmartHome
//
//  Created by AUX on 2019/4/22.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXBaseTableViewCell.h"
#import "AUXFirstCellModel.h"


NS_ASSUME_NONNULL_BEGIN

@interface AUXFeedBackDetailfirstTableViewCell : AUXBaseTableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *backImageView;

@property (weak, nonatomic) IBOutlet UILabel *detailLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIView *backView;

@property (weak, nonatomic) IBOutlet UIImageView *imageView1;

@property (weak, nonatomic) IBOutlet UIImageView *imageview2;
@property (weak, nonatomic) IBOutlet UIImageView *imageview3;
@property (weak, nonatomic) IBOutlet UIImageView *imageview4;


@property (nonatomic,copy)NSString *tmpStr;
@property (nonatomic,assign)CGFloat cellHeight;
@property (nonatomic,strong) AUXFirstCellModel *model;
@property (nonatomic, copy) void (^didselect)(NSInteger tagValue);
@property (weak, nonatomic) IBOutlet UIImageView *smallAngleImageView;
@property (weak, nonatomic) IBOutlet UIImageView *imageBackgroundImageView;

@end

NS_ASSUME_NONNULL_END
