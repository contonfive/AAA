//
//  AUXModeAndSpeedView.h
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2019/4/8.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AUXDeviceFunctionItem.h"


typedef void (^AUXConfirmBlock)(NSInteger index);
typedef void (^AUXCloseBlock)(void);

NS_ASSUME_NONNULL_BEGIN
@interface AUXModeAndSpeedView : UIView

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableBackViewHeight;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *tableBackView;


+ (AUXModeAndSpeedView *)alertViewWithNameData:(NSArray<AUXDeviceFunctionItem *> *)dataArray confirm:(AUXConfirmBlock)confirmBlock close:(AUXCloseBlock)closeBlock;

+ (AUXModeAndSpeedView *)alertViewWithNormalData:(NSArray <NSDictionary *>*)dataArray selectTitle:(NSString*)selectTitle confirm:(AUXConfirmBlock)confirmBlock close:(AUXCloseBlock)closeBlock;

- (void)hideModeAndSpeedViewAtcion;
@end

NS_ASSUME_NONNULL_END
