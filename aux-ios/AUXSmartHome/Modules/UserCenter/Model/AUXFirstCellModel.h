//
//  AUXFirstCellModel.h
//  AUXSmartHome
//
//  Created by AUX on 2019/4/23.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AUXFirstCellModel : NSObject
@property (nonatomic,copy)NSString *content;
@property (nonatomic,assign)NSInteger createdAt;
@property (nonatomic,strong)NSArray *imageUrls;
@property (nonatomic,assign)BOOL userReply;
@property (nonatomic,assign)BOOL timeLabelHidden;
@property (nonatomic,assign)BOOL isTheSametime;



@end

NS_ASSUME_NONNULL_END