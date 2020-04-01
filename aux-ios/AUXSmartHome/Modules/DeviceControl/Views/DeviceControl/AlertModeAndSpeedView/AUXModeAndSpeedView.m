//
//  AUXModeAndSpeedView.m
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2019/4/8.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXModeAndSpeedView.h"
#import "AUXModeAndSpeedTableViewCell.h"
#import "AUXModeAndSpeedNormalTableViewCell.h"
#import "UITableView+AUXCustom.h"
#import "UIView+AUXCornerRadius.h"

@interface AUXModeAndSpeedView ()<UITableViewDelegate , UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UIView *backView;
@property (nonatomic,strong) NSArray<AUXDeviceFunctionItem *> *dataArray;
@property (nonatomic,strong) NSArray <NSDictionary *>*normalDataArray;

@property (nonatomic,copy) AUXConfirmBlock confirmBlock;
@property (nonatomic,copy) AUXCloseBlock closeBlock;
@property (nonatomic,strong)NSString *titleText;

@end

@implementation AUXModeAndSpeedView

- (void)awakeFromNib {
    [super awakeFromNib];
    [self config];
}

+ (AUXModeAndSpeedView *)alertViewWithNameData:(NSArray<AUXDeviceFunctionItem *> *)dataArray confirm:(AUXConfirmBlock)confirmBlock close:(AUXCloseBlock)closeBlock {
    AUXModeAndSpeedView *alertView = [[[NSBundle mainBundle] loadNibNamed:@"AUXModeAndSpeedView" owner:nil options:nil] firstObject];
    alertView.dataArray = dataArray;
    alertView.confirmBlock = confirmBlock;
    alertView.closeBlock = closeBlock;
    
    alertView.frame = [UIScreen mainScreen].bounds;
    [kAUXWindowView addSubview:alertView];
    
    alertView.alpha = 0;
    [UIView animateWithDuration:kAlertAnimationTime animations:^{
        alertView.alpha = 1;
    }];
    
    return alertView;
}

+ (AUXModeAndSpeedView *)alertViewWithNormalData:(NSArray <NSDictionary *>*)dataArray selectTitle:(NSString*)selectTitle confirm:(AUXConfirmBlock)confirmBlock close:(AUXCloseBlock)closeBlock {
    AUXModeAndSpeedView *alertView = [[[NSBundle mainBundle] loadNibNamed:@"AUXModeAndSpeedView" owner:nil options:nil] firstObject];
    alertView.titleText = selectTitle;
    NSLog(@"%@",dataArray);
    alertView.normalDataArray = dataArray;
    alertView.confirmBlock = confirmBlock;
    alertView.closeBlock = closeBlock;
    
    alertView.frame = [UIScreen mainScreen].bounds;
    [kAUXWindowView addSubview:alertView];
    
    alertView.alpha = 0;
    [UIView animateWithDuration:kAlertAnimationTime animations:^{
        alertView.alpha = 1;
    }];
    
    return alertView;
}

- (void)config {
    [self.tableView registerCellWithNibName:@"AUXModeAndSpeedTableViewCell"];
    [self.tableView registerCellWithNibName:@"AUXModeAndSpeedNormalTableViewCell"];
    self.tableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kAUXScreenWidth, 1)];
    
    self.tableBackView.layer.cornerRadius = 10;
    self.tableBackView.layer.masksToBounds = YES;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideModeAndSpeedViewAtcion)];
    [self.backView addGestureRecognizer:tap];
    self.backView.userInteractionEnabled = YES;
}

- (void)hideModeAndSpeedViewAtcion {
    
    [UIView animateWithDuration:kAlertAnimationTime animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)setDataArray:(NSArray *)dataArray {
    _dataArray = dataArray;
    if (_dataArray) {
        
        CGFloat maxHeight = kAUXScreenHeight * 0.6;
        CGFloat height = _dataArray.count * 50;
        if (height >= maxHeight) {
            height = maxHeight;
        }
        self.tableBackViewHeight.constant = height;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            [self layoutIfNeeded];
        });
        
    }
    
}

- (void)setNormalDataArray:(NSArray<NSDictionary *> *)normalDataArray {
    _normalDataArray = normalDataArray;
    if (_normalDataArray) {
        
        CGFloat maxHeight = kAUXScreenHeight * 0.6;
        CGFloat height = _normalDataArray.count * 50;
        if (height >= maxHeight) {
            height = maxHeight;
        }
        self.tableBackViewHeight.constant = height;

        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            [self layoutIfNeeded];
        });
    }
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (self.dataArray) {
        return self.dataArray.count;
    } else {
        return self.normalDataArray.count;
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.dataArray) {
        AUXModeAndSpeedTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AUXModeAndSpeedTableViewCell" forIndexPath:indexPath];
        AUXDeviceFunctionItem *item = self.dataArray[indexPath.row];
        
        cell.statusLabel.text = item.title;
        if (!AUXWhtherNullString(item.imageNor)) {
            cell.statusImageView.image = [UIImage imageNamed:item.imageNor];
        } else {
            cell.statusLabelTriling.constant = -15;
            cell.statusImageView.hidden = YES;
            dispatch_async(dispatch_get_main_queue(), ^{
                [cell layoutIfNeeded];
            });
        }
        
        if (item.selected) {
            cell.selectedBtn.hidden = NO;
        } else {
            cell.selectedBtn.hidden = YES;
        }
        return cell;
    } else {
        AUXModeAndSpeedNormalTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AUXModeAndSpeedNormalTableViewCell" forIndexPath:indexPath];
        NSDictionary *dict = self.normalDataArray[indexPath.row];

        cell.contentLabel.text = dict[@"title"];
        if ([cell.contentLabel.text isEqualToString:self.titleText]) {
            cell.iconImageView.hidden = NO;
        }else{
             cell.iconImageView.hidden = YES;
        }
        if (indexPath.row == self.normalDataArray.count - 1) {
            cell.bottomView.hidden = YES;
        }
        
        return cell;
    }
    
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.confirmBlock) {
        self.confirmBlock(indexPath.row);
    }
    
    [tableView reloadData];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self hideModeAndSpeedViewAtcion];
    });
}

@end
