/*
 * =============================================================================
 *
 * AUX Group Confidential
 *
 * OCO Source Materials
 *
 * (C) Copyright AUX Group Co., Ltd. 2017 All Rights Reserved.
 *
 * The source code for this program is not published or otherwise divested
 * of its trade secrets, unauthorized application or modification of this
 * source code will incur legal liability.
 * =============================================================================
 */

#import "AUXAboutViewController.h"
#import "AUXUserWebViewController.h"
#import "UIColor+AUXCustom.h"
@interface AUXAboutViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UILabel *versionLabel;
@property (weak, nonatomic) IBOutlet UIButton *updateButton;
@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (nonatomic,strong) NSArray *dataArray;
@property (nonatomic,assign)NSInteger tapNumber;

@end

@implementation AUXAboutViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.versionLabel.text = [NSString stringWithFormat:@"版本号：%@（%@）", APP_VERSION,APP_BUILD];
    self.updateButton.layer.cornerRadius = 22;
    self.updateButton.layer.borderColor = [[UIColor colorWithHexString:@"256BBD"] CGColor];
    self.updateButton.layer.borderWidth= 2;
    self.dataArray = @[@"  数据隐私声明",@"  官网",@"  服务热线"];
    [self.tableview registerClass:[UITableViewCell class] forCellReuseIdentifier:@"CELL"];
    [self setSubViews];
    self.tableview.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    self.tableview.scrollEnabled = NO;
    self.tableview.backgroundColor = [UIColor colorWithHexString:@"F7F7F7"];
    self.iconImageView.userInteractionEnabled = YES;
    UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(iconInageAction)];
    [self.iconImageView addGestureRecognizer:tapGesture];
    
}

- (void)iconInageAction{
    self.tapNumber += 1;
    if (self.tapNumber==8) {
        [self showToastshortWithmessageinCenter:@"已开启测试模式"];
        self.tapNumber = 0;
        [MyDefaults setObject:@"1" forKey:kIsTheTester];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CELL" forIndexPath:indexPath];
    cell.textLabel.text = self.dataArray[indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.textColor = [UIColor colorWithHexString:@"333333"];
    cell.textLabel.font = [UIFont systemFontOfSize:16];
    UIImageView *backImageview = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"common_btn_go"]];
    backImageview.frame = CGRectMake(kScreenWidth-36, 19, 22, 22);
    [cell addSubview:backImageview];
    
    UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(20, 59, kScreenWidth-20, 1)];
    lineView.backgroundColor = [UIColor colorWithHexString:@"F6F6F6"];
    [cell addSubview:lineView];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.row) {
        case 0:
        {
            AUXUserWebViewController *userWebViewController = [AUXUserWebViewController instantiateFromStoryboard:kAUXStoryboardNameUserCenter];
            userWebViewController.loadUrl = kAUXPrivacyStatement;
            [self.navigationController pushViewController:userWebViewController animated:YES];
        }
            break;
        case 1:
        {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:kAUXURL]];
        }
            break;
        case 2:
        {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"tel:4008268268"]];
        }
            break;
        default:
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 12;
}




- (void)setSubViews {
    if (self.appVersionModel.whtherNeedUpdate) {
        self.updateButton.enabled = YES;
        [self.updateButton setTitle:[NSString stringWithFormat:@"更新至%@" , self.appVersionModel.version] forState:UIControlStateNormal];
        self.updateButton.alpha = 1;
    } else {
        self.updateButton.enabled = NO;
        [self.updateButton setTitle:@"已经是最新版本" forState:UIControlStateNormal];
         self.updateButton.alpha = 0.3;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 12)];
    view.backgroundColor = [UIColor colorWithHexString:@"F7F7F7"];
    return view;
    
}

#pragma mark  更新版本
- (IBAction)update:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.appVersionModel.updateVersionUrl]];
}

@end
