//
//  AUXSchedulerDeviceWindTableViewCell.h
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2019/4/11.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXBaseTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUXSchedulerDeviceWindTableViewCell : AUXBaseTableViewCell

@property (nonatomic,strong) NSMutableArray *dataArray;

@property (nonatomic, copy) void (^selectedBtnBlock)(NSString *title);
@property (nonatomic, copy) void (^deSelectedBtnBlock)(NSString *title);

@end

NS_ASSUME_NONNULL_END
