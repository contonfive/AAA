//
//  AUXDeviceSetTableViewCell.h
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2019/4/13.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXBaseTableViewCell.h"
#import "AUXChooseButton.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUXDeviceSetTableViewCell : AUXBaseTableViewCell

@property (weak, nonatomic) IBOutlet UILabel *windLabel;
@property (weak, nonatomic) IBOutlet AUXChooseButton *windBtn;
@property (weak, nonatomic) IBOutlet UIButton *smartBtn;
@property (weak, nonatomic) IBOutlet UIButton *sleepDiyHelpBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *smartTitleLabelCenterY;
@property (weak, nonatomic) IBOutlet UILabel *smartTitleLabel;


@property (nonatomic, copy) void (^windBlock)(void);
@property (nonatomic, copy) void (^helpBlock)(void);
@property (nonatomic, copy) void (^smartBlock)(BOOL on);
@end

NS_ASSUME_NONNULL_END
