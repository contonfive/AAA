//
//  AUXControllGuidSubview.h
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2018/12/1.
//  Copyright © 2018年 AUX Group Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AUXChooseButton.h"
NS_ASSUME_NONNULL_BEGIN

@interface AUXControllGuidSubview : UIView
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subtitleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property (weak, nonatomic) IBOutlet AUXChooseButton *nextBtn;

@property (weak, nonatomic) IBOutlet AUXChooseButton *pageFirstBtn;
@property (weak, nonatomic) IBOutlet AUXChooseButton *pageSecondBtn;
@property (weak, nonatomic) IBOutlet AUXChooseButton *pageThirtBtn;


@property (nonatomic,copy) NSString *imageName;
@property (nonatomic, copy) void (^nextAtcionBlock)(void);
@property (nonatomic,assign) NSInteger index;

@end

NS_ASSUME_NONNULL_END
