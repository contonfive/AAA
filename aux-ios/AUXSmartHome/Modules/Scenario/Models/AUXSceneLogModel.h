//
//  AUXSceneLogModel.h
//  AUXSmartHome
//
//  Created by AUX on 2019/4/16.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <YYModel/YYModel.h>

NS_ASSUME_NONNULL_BEGIN

@interface AUXSceneLogModel : NSObject
@property (nonatomic,copy) NSString *createDay;
@property (nonatomic,strong) NSArray *detailList;
@property (nonatomic,copy) NSString *result;
@property (nonatomic,copy) NSString *sceneName;
@property (nonatomic,assign) NSInteger sceneType;
@property (nonatomic,assign) BOOL isSelected;
@property (nonatomic,assign) BOOL timeLabelHidden;

@end

NS_ASSUME_NONNULL_END
