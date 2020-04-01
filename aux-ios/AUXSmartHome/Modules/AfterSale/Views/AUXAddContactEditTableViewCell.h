//
//  AUXAddContactEditTableViewCell.h
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2018/9/25.
//  Copyright © 2018年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXBaseTableViewCell.h"
#import "AUXTopContactModel.h"
#import "QMUIKit.h"


NS_ASSUME_NONNULL_BEGIN

@interface AUXAddContactEditTableViewCell : AUXBaseTableViewCell

@property (weak, nonatomic) IBOutlet QMUITextField *editTextfiled;
@property (weak, nonatomic) IBOutlet UIImageView *rightImageView;


@property (nonatomic, copy) void (^textfiledBlock)(NSString *text);

@property (nonatomic,strong) NSIndexPath *indexPath;
@property (nonatomic,strong) AUXTopContactModel *model;

@end

NS_ASSUME_NONNULL_END
