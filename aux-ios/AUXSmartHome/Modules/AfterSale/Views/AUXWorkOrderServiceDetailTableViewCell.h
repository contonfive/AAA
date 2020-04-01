//
//  AUXWorkOrderServiceDetailTableViewCell.h
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2018/10/11.
//  Copyright © 2018年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXBaseTableViewCell.h"
#import "AUXProgressListModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUXWorkOrderServiceDetailTableViewCell : AUXBaseTableViewCell
@property (weak, nonatomic) IBOutlet UIView *topSegmentationView;
@property (weak, nonatomic) IBOutlet UIView *bottomSegmentationView;
@property (weak, nonatomic) IBOutlet UIButton *currentButton;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UILabel *createOnLabel;

@property (nonatomic,strong) NSIndexPath *indexPath;
@property (nonatomic,strong) AUXProgressListModel *ProgressListModel;
@property (nonatomic,strong) NSArray <AUXProgressListModel *> *ProgressList;

@end

NS_ASSUME_NONNULL_END
