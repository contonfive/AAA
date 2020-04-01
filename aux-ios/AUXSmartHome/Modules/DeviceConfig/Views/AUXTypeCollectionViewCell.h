//
//  AUXTypeCollectionViewCell.h
//  AUXSmartHome
//
//  Created by AUX on 2019/3/29.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AUXTypeCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *picturesImageView;
@property (weak, nonatomic) IBOutlet UILabel *textLabel;

@end

NS_ASSUME_NONNULL_END
