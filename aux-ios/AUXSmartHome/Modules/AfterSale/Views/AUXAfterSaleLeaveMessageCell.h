//
//  AUXAfterSaleLeaveMessageCell.h
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2018/9/20.
//  Copyright © 2018年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXBaseTableViewCell.h"
#import "QMUIKit.h"
@interface AUXAfterSaleLeaveMessageCell : AUXBaseTableViewCell

@property (weak, nonatomic) IBOutlet QMUITextView *textView;
@property (weak, nonatomic) IBOutlet UIImageView *whtherMustImageView;


@property (nonatomic, copy) void (^leaveTextViewBlock)(NSString *text);

@end

