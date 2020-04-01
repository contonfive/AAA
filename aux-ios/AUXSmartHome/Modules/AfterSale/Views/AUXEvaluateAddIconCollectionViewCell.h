//
//  AUXEvaluateAddIconCollectionViewCell.h
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2018/10/9.
//  Copyright © 2018年 AUX Group Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AUXEvaluateAddIconCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIView *backView;

@property (weak, nonatomic) IBOutlet UILabel *numberLabel;

@property (nonatomic,strong) NSMutableArray *imagesArray;

@end

NS_ASSUME_NONNULL_END
