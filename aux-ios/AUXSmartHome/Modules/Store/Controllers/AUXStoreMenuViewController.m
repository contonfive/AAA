//
//  AUXStoreMenuViewController.m
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2018/10/15.
//  Copyright © 2018年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXStoreMenuViewController.h"

@interface AUXStoreMenuViewController ()
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *buttonCollection;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *detailButtonCollection;
@property (weak, nonatomic) IBOutlet UIView *buttonMenuView;
@property (weak, nonatomic) IBOutlet UIView *detailButtonView;


@end

@implementation AUXStoreMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.buttonMenuView.layer.masksToBounds = YES;
    self.buttonMenuView.layer.cornerRadius = 5;
    self.detailButtonView.layer.masksToBounds = YES;
    self.detailButtonView.layer.cornerRadius = 5;
    
    for (UIButton *button in self.buttonCollection) {
        [button addTarget:self action:@selector(buttonAtcion:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    for (UIButton *button in self.detailButtonCollection) {
        [button addTarget:self action:@selector(detailButtonAtcion:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    if (self.storeMenuType == AUXStoreMenuTypeOfButtonMenu) {
        self.detailButtonView.hidden = YES;
        self.buttonMenuView.hidden = NO;
    } else {
        self.detailButtonView.hidden = NO;
        self.buttonMenuView.hidden = YES;
    }
}

- (void)setStoreMenuType:(AUXStoreMenuType)storeMenuType {
    _storeMenuType = storeMenuType;
}

- (void)buttonAtcion:(UIButton *)button {
    NSInteger index = button.tag - 100;
    [self dismissViewControllerAnimated:YES completion:^{
        
        switch (index) {
            case 0:
                if (self.classificationBlock) {
                    self.classificationBlock();
                }
                break;
            case 1:
                if (self.myOrderBlock) {
                    self.myOrderBlock();
                }
                break;
            case 2:
                if (self.userCenterBlock) {
                    self.userCenterBlock();
                }
                break;
                
            default:
                break;
        }
    }];
}

- (void)detailButtonAtcion:(UIButton *)button {
    NSInteger index = button.tag - 100;
    [self dismissViewControllerAnimated:YES completion:^{
        
        switch (index) {
            case 0:
                if (self.classificationBlock) {
                    self.classificationBlock();
                }
                break;
            case 1:
                if (self.myOrderBlock) {
                    self.myOrderBlock();
                }
                break;
            case 2:
                if (self.userCenterBlock) {
                    self.userCenterBlock();
                }
                break;
            case 3:
                if (self.cartBlock) {
                    self.cartBlock();
                }
                break;
                
            default:
                break;
        }
    }];
}

@end
