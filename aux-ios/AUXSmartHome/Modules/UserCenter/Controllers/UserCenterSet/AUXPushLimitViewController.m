//
//  AUXPushLimitViewController.m
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2018/11/16.
//  Copyright © 2018年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXPushLimitViewController.h"
#import "NSDate+AUXCustom.h"
#import "AUXNetworkManager.h"
#import "AUXPushLimitModel.h"
#import "AUXPushLimitMessageTimePick.h"
#import "UIColor+AUXCustom.h"
#import "AUXAlertCustomView.h"

@interface AUXPushLimitViewController ()
@property (nonatomic,strong) AUXPushLimitModel *limitModel;
@property (weak, nonatomic) IBOutlet UIImageView *switchImageview;
@property (weak, nonatomic) IBOutlet UIButton *switchButton;
@property (weak, nonatomic) IBOutlet UIView *pikeViewBackView;
@property (nonatomic,strong)AUXPushLimitMessageTimePick*picekView;
@property (nonatomic,strong)UIButton *leftButton;
@property (nonatomic,assign)BOOL switchButtonSelected;
@property (nonatomic,assign)NSInteger oldpickViewStartTime;
@property (nonatomic,assign)NSInteger oldpickViewEndTime;


@end

@implementation AUXPushLimitViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setpickdate];
    [self setNavRightItem];
    self.customBackAtcion = YES;
    NSString *start = [MyDefaults objectForKey:kPushMessageStartTime];
    if (start.length ==0) {
        self.switchButton.selected = YES;
        self.switchButtonSelected = NO;
        [self switchButtonAction:self.switchButton];
    }else{
        self.switchButton.selected = NO;
        self.switchButtonSelected = YES;
        [self switchButtonAction:self.switchButton];

    }
}

-(void)backAtcion{
    NSString *oldMessageStartTime =[NSString stringWithFormat:@"%@",[MyDefaults objectForKey:kPushMessageStartTime]];
    NSString *oldMessageEndTime = [NSString stringWithFormat:@"%@",[MyDefaults objectForKey:kPushMessageEndTime]];
    NSString *newMessageStartTime =[NSString stringWithFormat:@"%ld",self.picekView.starttime];
    NSString *newMessageEndTime = [NSString stringWithFormat:@"%ld",(long)self.picekView.endtime];
    if (self.switchButtonSelected != self.switchButton.selected) {
        [AUXAlertCustomView alertViewWithMessage:@"是否放弃更改？" confirmAtcion:^{
            [self.navigationController popViewControllerAnimated:YES];
        } cancleAtcion:^{
        }];
    }else{
        if (([oldMessageStartTime isEqualToString:newMessageStartTime]&&[oldMessageEndTime isEqualToString:newMessageEndTime])||(self.picekView.endtime == self.oldpickViewEndTime &&self.picekView.starttime == self.oldpickViewStartTime)) {
            [self.navigationController popViewControllerAnimated:YES];
        }else{
            [AUXAlertCustomView alertViewWithMessage:@"是否放弃更改？" confirmAtcion:^{
                [self.navigationController popViewControllerAnimated:YES];
            } cancleAtcion:^{
            }];
        }
    }
}


- (void)setNavRightItem{
    if (!self.leftButton) {
        self.leftButton = [[UIButton alloc]init];
        self.leftButton.frame = CGRectMake(0, 0, 40, 30);
        [self.leftButton setTitle:@"保存" forState:UIControlStateNormal];
        [self.leftButton setTitleColor:[UIColor colorWithHexString:@"333333"] forState:UIControlStateNormal];
        self.leftButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [self.leftButton addTarget:self action:@selector(saveItemAction) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.rightBarButtonItem =  [[UIBarButtonItem alloc]initWithCustomView:self.leftButton];
    }
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self requestPushLimitDetail];
}


#pragma mark  保存按钮的点击事件
- (void)saveItemAction {
    self.limitModel.startHour = self.picekView.starttime;
    self.limitModel.endHour = self.picekView.endtime;
    [self requestUpdateLimit];
}


#pragma mark  设置时间选择器
- (void)setpickdate {
    self.picekView = [[AUXPushLimitMessageTimePick alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 250)];
    [self.pikeViewBackView addSubview:self.picekView];
    self.oldpickViewEndTime = self.picekView.endtime;
    self.oldpickViewStartTime =self.picekView.starttime;
}


#pragma mark  开关按钮的点击事件
- (IBAction)switchButtonAction:(UIButton *)sender {
    self.switchButton.selected = !self.switchButton.selected;
    [self setNavRightItem];
    if (self.switchButton.selected) {
        self.pikeViewBackView.hidden = NO;
        self.switchImageview.image = [UIImage imageNamed:@"common_btn_on"];
        self.limitModel.state = YES;
    }else{
        self.pikeViewBackView.hidden = YES;
        self.switchImageview.image = [UIImage imageNamed:@"common_btn_off"];
        self.limitModel.state = NO;
    }
}



#pragma mark 请求时间详情
- (void)requestPushLimitDetail {
    [self showLoadingHUD];
    [[AUXNetworkManager manager] getPushLimitDetailWithCompltion:^(AUXPushLimitModel * _Nonnull model, NSError * _Nonnull error) {
        [self hideLoadingHUD];
        if (error) {
            self.limitModel = model;
            if (AUXWhtherNullString(self.limitModel.guid)) {
                self.limitModel.startHour = 23;
                self.limitModel.startMinute = 00;
                self.limitModel.endHour = 07;
                self.limitModel.endMinute = 00;
            }
        }
    }];
}



#pragma mark  更新设置
- (void)requestUpdateLimit {
    [[AUXNetworkManager manager] updatePushLimitWithModel:self.limitModel compltion:^(AUXPushLimitModel * _Nonnull model, NSError * _Nonnull error) {
        if ((!AUXWhtherNullString(model.guid))) {
            [self showSuccess:@"设置成功" completion:^{
                if (self.limitModel.state) {
                    [MyDefaults setObject:[NSString stringWithFormat:@"%ld",(long)self.limitModel.startHour] forKey:kPushMessageStartTime];
                    [MyDefaults setObject:[NSString stringWithFormat:@"%ld",(long)self.limitModel.endHour] forKey:kPushMessageEndTime];
                }else{
                    [MyDefaults setObject:@"" forKey:kPushMessageStartTime];
                    [MyDefaults setObject:@"" forKey:kPushMessageEndTime];
                }
                
                [self.navigationController popViewControllerAnimated:YES];
            }];
        } else {
            [self showToastshortWitherror:error];
        }
    }];
}



- (AUXPushLimitModel *)limitModel {
    if (!_limitModel) {
        _limitModel = [[AUXPushLimitModel alloc]init];
    }
    return _limitModel;
}




@end




