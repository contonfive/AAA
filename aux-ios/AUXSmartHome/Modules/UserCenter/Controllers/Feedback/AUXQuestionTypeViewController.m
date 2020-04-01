//
//  AUXQuestionTypeViewController.m
//  AUXSmartHome
//
//  Created by AUX on 2019/4/19.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXQuestionTypeViewController.h"
#import "AUXQuestionTypeTableViewCell.h"
#import "AUXFeedbackViewController.h"
#import "UIColor+AUXCustom.h"


@interface AUXQuestionTypeViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property (nonatomic,strong)NSArray *dataArray;
@end

@implementation AUXQuestionTypeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableview registerNib:[UINib nibWithNibName:@"AUXQuestionTypeTableViewCell" bundle:nil] forCellReuseIdentifier:@"AUXQuestionTypeTableViewCell"];
    self.tableview.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    self.tableview.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    self.dataArray = @[@"账号问题",@"设备添加",@"设备管理",@"功能异常",@"场景模式",@"其他问题"];
    self.tableview.backgroundColor = [UIColor colorWithHexString:@"F7F7F7"];
    self.tableview.scrollEnabled = NO;
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    AUXQuestionTypeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AUXQuestionTypeTableViewCell" forIndexPath:indexPath];
    if (indexPath.row+1 == self.feedBackType) {
        cell.selectImageView.hidden = NO;
    }else{
        cell.selectImageView.hidden = YES;
    }
    cell.questionLabel.text = self.dataArray[indexPath.row];
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

#pragma mark - 每个cell的高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

#pragma mark  cell的点击事件
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger number = indexPath.row+1;
    if (self.isFormfirstpage) {
        AUXFeedbackViewController *feedBackViewController = [AUXFeedbackViewController instantiateFromStoryboard:kAUXStoryboardNameUserCenter];
        feedBackViewController.typeLabel = self.dataArray[indexPath.row];
        feedBackViewController.feedBackType = number;
        [self.navigationController pushViewController:feedBackViewController animated:YES];
    }else{
        NSDictionary *dic = @{@"questtionName":self.dataArray[indexPath.row],@"questType":[NSString stringWithFormat:@"%ld",number]};
        if (self.goBlock) {
            self.goBlock(dic);
        }
        [self.navigationController popViewControllerAnimated:YES];
    }
}




@end

