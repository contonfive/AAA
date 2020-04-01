//
//  AUXAddressAlert.m
//  AUXSmartHome
//
//  Created by AUX on 2019/4/28.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXAddressAlert.h"
#import "UIView+AUXCornerRadius.h"
#import "AUXAddressAlertTableViewCell.h"

@interface AUXAddressAlert ()<UITableViewDelegate,UITableViewDataSource>
@property (retain, nonatomic) NSMutableArray *regionArray;
@property (retain, nonatomic) NSMutableDictionary *regionDictionary;
@property (nonatomic,strong)NSString *province;
@property (nonatomic,strong)NSString *city;
@property (retain, nonatomic) NSMutableArray *cityArray;
@property (nonatomic,assign)BOOL isProvince;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *underLineConstraint;
@property (nonatomic,copy)didSelectBlcok addressBlock;
@end

@implementation AUXAddressAlert


- (void)awakeFromNib {
    [super awakeFromNib];
    self.frame = [UIScreen mainScreen].bounds;
    self.alpha = 0;
    self.isProvince = YES;
    self.alertView.layer.masksToBounds = YES;
    self.alertView.layer.cornerRadius = 10;
    self.backView.userInteractionEnabled = YES;
    [self.tableview registerNib:[UINib nibWithNibName:@"AUXAddressAlertTableViewCell" bundle:nil] forCellReuseIdentifier:@"AUXAddressAlertTableViewCell"];
    self.tableview.delegate = self;
    self.tableview.dataSource = self;
    self.tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.cityButton.hidden = YES;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideAtcion)];
    [self.topView addGestureRecognizer:tap];
}
- (void)hideAtcion {
    self.alpha = 1;
    [UIView animateWithDuration:kAlertAnimationTime animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

+ (void)alertViewWithregionArray:(NSMutableArray*)regionArray regionDictionary:(NSMutableDictionary*)regionDictionary addressBlock:(didSelectBlcok)addressBlock{
    AUXAddressAlert *alertView = [[[NSBundle mainBundle]  loadNibNamed:@"AUXCustomAlertView" owner:nil options:nil] objectAtIndex:12];
    alertView.frame = [UIScreen mainScreen].bounds;
    alertView.addressBlock = addressBlock;
    [kAUXWindowView addSubview:alertView];
    alertView.alpha = 0;
    [UIView animateWithDuration:kAlertAnimationTime animations:^{
        alertView.alpha = 1;
    }];
    alertView.regionArray = regionArray;
    alertView.regionDictionary = regionDictionary;
    [alertView.tableview reloadData];
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    AUXAddressAlertTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AUXAddressAlertTableViewCell" forIndexPath:indexPath];
    if (self.isProvince) {
        cell.addressLabel.text = self.regionArray[indexPath.row];
    }else{
        cell.addressLabel.text = self.cityArray[indexPath.row];
    }
    
    if (self.isProvince) {
        if ([self.province isEqualToString: cell.addressLabel.text]) {
            cell.selectImage.image = [UIImage imageNamed:@"common_icon_selected_tick"];
        }else{
            cell.selectImage.image = [UIImage imageNamed:@"22"];
        }
    }else{
        cell.selectImage.image = [UIImage imageNamed:@"22"];

    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (self.isProvince) {
        return self.regionArray.count;
    }else{
        return self.cityArray.count;
    }
}

#pragma mark - 每个cell的高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

#pragma mark  cell的点击事件
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.isProvince) {
        self.isProvince = NO;
        self.cityButton.hidden = NO;
        [UIView animateWithDuration:1 animations:^{
            self.underLineConstraint.constant = 80;
        } completion:^(BOOL finished) {
            
        }];
        self.province = self.regionArray[indexPath.row];
        self.cityArray = [self.regionDictionary[self.province] mutableCopy];
        [self.provinceButton setTitle:self.province forState:UIControlStateNormal];
        [self.tableview reloadData];
        
    }else{
        self.cityButton.hidden = NO;
        self.city = self.cityArray[indexPath.row];
        [self.cityButton setTitle:self.city forState:UIControlStateNormal];
        
//        NSString *address = [NSString stringWithFormat:@"%@ %@",self.province,self.city];
        if (self.addressBlock) {
            self.addressBlock(self.province, self.city);
        }
        [self hideAtcion];
    }
    
}

#pragma mark  分区头的高度
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.0001;
}





- (IBAction)provinceButtonAction:(UIButton *)sender {
    self.isProvince = YES;
    [self.tableview reloadData];
    [self layoutIfNeeded];
    
    [UIView animateWithDuration:1 animations:^{
        
        self.underLineConstraint.constant = 2;
    } completion:^(BOOL finished) {
        
    }];
    
    
    
}
- (IBAction)cityButtonAction:(UIButton *)sender {
    [self layoutIfNeeded];
    self.isProvince = NO;
    [self.tableview reloadData];
    
    [UIView animateWithDuration:1 animations:^{
        self.underLineConstraint.constant = 80;
    } completion:^(BOOL finished) {
        
    }];
}


@end

