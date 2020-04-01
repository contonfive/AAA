//
//  AUXAddressAlert.h
//  AUXSmartHome
//
//  Created by AUX on 2019/4/28.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^didSelectBlcok)(NSString *provinceStr,NSString *cityStr);

NS_ASSUME_NONNULL_BEGIN

@interface AUXAddressAlert : UIView
@property (weak, nonatomic) IBOutlet UIView *backView;
@property (weak, nonatomic) IBOutlet UIView *alertView;
@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property (weak, nonatomic) IBOutlet UIButton *provinceButton;
@property (weak, nonatomic) IBOutlet UIButton *cityButton;
@property (weak, nonatomic) IBOutlet UIView *uiderLine;
@property (weak, nonatomic) IBOutlet UIView *topView;

+ (void)alertViewWithregionArray:(NSMutableArray*)regionArray regionDictionary:(NSMutableDictionary*)regionDictionary addressBlock:(didSelectBlcok)addressBlock;
@end

NS_ASSUME_NONNULL_END
