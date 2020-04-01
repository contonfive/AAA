//
//  AUXSceneAddLocationViewController.m
//  AUXSmartHome
//
//  Created by AUX on 2019/4/10.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXSceneAddLocationViewController.h"
#import "UIColor+AUXCustom.h"
#import "AUXSceneMapViewController.h"
#import "AUXScenePlaceInstructionsViewController.h"


@interface AUXSceneAddLocationViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *locationTableview;
@property (weak, nonatomic) IBOutlet UIButton *detailButton;
@property (nonatomic,strong) NSArray *dataArray;
@property (weak, nonatomic) IBOutlet UIView *bottomView;

@end

@implementation AUXSceneAddLocationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dataArray = @[@"到达某地",@"离开某地"];
    [self.locationTableview registerClass:[UITableViewCell class] forCellReuseIdentifier:@"CELL"];
    self.locationTableview.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    self.locationTableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.locationTableview.scrollEnabled = NO;
    self.bottomView.layer.masksToBounds = YES;
    self.bottomView.layer.cornerRadius = 5;
    self.detailButton.layer.masksToBounds = YES;
    self.detailButton.layer.borderColor = [UIColor colorWithHexString:@"FFFFFF"].CGColor;
    self.detailButton.layer.borderWidth = 1;
    self.detailButton.layer.cornerRadius = 2;
    self.view.backgroundColor = [UIColor colorWithHexString:@"F7F7F7"];
    self.locationTableview.backgroundColor = [UIColor colorWithHexString:@"F7F7F7"];

}

#pragma mark  详情按钮的点击事件
- (IBAction)detailButtonAction:(UIButton *)sender {
    AUXScenePlaceInstructionsViewController *instructionsViewController = [AUXScenePlaceInstructionsViewController instantiateFromStoryboard:kAUXStoryboardNameScene];
    [self.navigationController pushViewController:instructionsViewController animated:YES];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CELL" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text = self.dataArray[indexPath.row];
    UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(20, 60, kScreenWidth-20, 1)];
    lineView.backgroundColor = [UIColor colorWithHexString:@"F6F6F6"];
    [cell addSubview:lineView];
    cell.backgroundColor = [UIColor whiteColor];
    cell.textLabel.textColor = [UIColor colorWithHexString:@"333333"];
    cell.textLabel.font = [UIFont systemFontOfSize:FontSize(16)];
    
    UIImageView *backImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"common_btn_go"]];
    backImage.frame = CGRectMake(kScreenWidth-36, 19, 22, 22);
    [cell addSubview:backImage];
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    AUXSceneMapViewController *sceneMapViewController = [AUXSceneMapViewController instantiateFromStoryboard:kAUXStoryboardNameScene];
    sceneMapViewController.sceneType = self.sceneType;
    sceneMapViewController.isNewAdd = self.isNewAdd;
    sceneMapViewController.titleStr = self.dataArray[indexPath.row];
     sceneMapViewController.markType =self.markType;
     sceneMapViewController.location = self.location;
    sceneMapViewController.actionType = indexPath.row;
    [self.navigationController pushViewController:sceneMapViewController animated:YES];
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

@end

