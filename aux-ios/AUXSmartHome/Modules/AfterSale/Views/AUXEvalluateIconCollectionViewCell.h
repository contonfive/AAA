//
//  AUXEvalluateIconCollectionViewCell.h
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2018/10/9.
//  Copyright © 2018年 AUX Group Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AUXEvalluateIconCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property (weak, nonatomic) IBOutlet UIButton *deleteButton;

@property (nonatomic, copy) void (^deleteBlock)(UIImage *image);

@end

NS_ASSUME_NONNULL_END
