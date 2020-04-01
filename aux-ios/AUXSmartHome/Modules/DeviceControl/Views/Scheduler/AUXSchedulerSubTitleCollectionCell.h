//
//  AUXSchedulerSubTitleCollectionCell.h
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2019/5/13.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AUXButton.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUXSchedulerSubTitleCollectionCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet AUXButton *titleBtn;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (nonatomic, copy) void (^btnSlectedBlock)(BOOL selected);

@end

NS_ASSUME_NONNULL_END
