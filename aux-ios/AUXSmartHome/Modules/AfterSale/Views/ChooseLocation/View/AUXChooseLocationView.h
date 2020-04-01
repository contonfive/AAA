//
//  AUXChooseLocationView.h
//  ChooseLocation
//
//  Created by Sekorm on 16/8/22.
//  Copyright © 2016年 HY. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AUXTopContactModel.h"

@interface AUXChooseLocationView : UIView

@property (nonatomic, copy) void(^chooseFinish)(NSMutableDictionary *localDict);

@property (nonatomic,strong) AUXTopContactModel *model;

- (void)requestProvienceInfo;
@end
