//
//  AUXServiceRecordViewController.h
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2018/10/11.
//  Copyright © 2018年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXBaseViewController.h"
#import "AUXProgressListModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUXServiceRecordViewController : AUXBaseViewController

@property (nonatomic,strong) NSArray <AUXProgressListModel *> *ProgressList;
@end

NS_ASSUME_NONNULL_END
