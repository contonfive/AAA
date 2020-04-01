//
//  AUXSearchEquipmentViewController.h
//  AUXSmartHome
//
//  Created by AUX on 2019/7/9.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AUXBaseViewController.h"
#import "AUXElectronicSpecificationModel+CoreDataClass.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUXSearchEquipmentViewController : AUXBaseViewController
@property (nonatomic,copy)void(^informBlock)(AUXElectronicSpecificationModel*model);
@end

NS_ASSUME_NONNULL_END
