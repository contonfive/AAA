//
//  AUXNoDeviceCollectionViewCell.h
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2019/4/15.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AUXNoDeviceCollectionViewCell : UICollectionViewCell

@property (nonatomic, copy) void (^addDeviceBlock)(void);

@end

NS_ASSUME_NONNULL_END
