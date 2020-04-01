//
//  AUXACDeviceListCollectionViewCell.h
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2018/7/30.
//  Copyright © 2018年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXDeviceCollectionViewCell.h"

@interface AUXACDeviceListCollectionViewCell : AUXDeviceCollectionViewCell

@property (weak, nonatomic) IBOutlet UIButton *powerBtn;
@property (weak, nonatomic) IBOutlet UIButton *heatBtn;
@property (weak, nonatomic) IBOutlet UIButton *coolBtn;
@property (weak, nonatomic) IBOutlet UIView *modeView;
@property (weak, nonatomic) IBOutlet UILabel *modeLabel;


@end
