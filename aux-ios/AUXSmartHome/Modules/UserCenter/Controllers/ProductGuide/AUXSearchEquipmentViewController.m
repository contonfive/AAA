//
//  AUXSearchEquipmentViewController.m
//  AUXSmartHome
//
//  Created by AUX on 2019/7/9.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXSearchEquipmentViewController.h"
#import "UIColor+AUXCustom.h"
#import "AUXHistoryListTableViewCell.h"
#import "AUXUserWebViewController.h"
#import "AUXElectronicSpecificationHistoryListModel+CoreDataClass.h"
#import "NSDate+AUXCustom.h"
#import "MBProgressHUD.h"

@interface AUXSearchEquipmentViewController ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property (weak, nonatomic) IBOutlet UITextField *searchTF;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (nonatomic,strong)NSMutableArray *dataArray;
@property (nonatomic,strong)NSString *searchStr;
@property (weak, nonatomic) IBOutlet UIView *headBackgroundView;

@end

@implementation AUXSearchEquipmentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableview registerNib:[UINib nibWithNibName:@"AUXHistoryListTableViewCell" bundle:nil] forCellReuseIdentifier:@"AUXHistoryListTableViewCell"];
    self.tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableview.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    self.headBackgroundView.layer.masksToBounds = YES;
    self.headBackgroundView.layer.cornerRadius = self.headBackgroundView.bounds.size.height/2;
    self.searchTF.delegate = self;
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(searchTFtextChanged:) name:@"UITextFieldTextDidChangeNotification" object:self.searchTF];
    
}

#pragma mark  :UITextField输入长度
- (void)searchTFtextChanged:(NSNotification *)obj{
    UITextField *textField = (UITextField *)obj.object;
        NSArray *modelArray = [AUXElectronicSpecificationModel MR_findAllSortedBy:@"deviceType" ascending:YES];
        NSPredicate *predicate = nil;
        [self.dataArray removeAllObjects];
        predicate = [NSPredicate predicateWithFormat:@"deviceType contains[c] %@", textField.text];
        self.dataArray = [[modelArray filteredArrayUsingPredicate:predicate] mutableCopy];
        [self.tableview reloadData];
}

- (NSMutableArray *)dataArray{
    if (!_dataArray) {
        self.dataArray = [[NSMutableArray alloc]init];
    }
    return _dataArray;
}

- (IBAction)cancelButtonAction:(UIButton *)sender {
    [self.searchTF resignFirstResponder];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    [self.searchTF becomeFirstResponder];
}

#pragma mark  tableview 的代理方法
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    AUXHistoryListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AUXHistoryListTableViewCell" forIndexPath:indexPath];
    
    AUXElectronicSpecificationModel *model = self.dataArray[indexPath.row];
    cell.textTitleLabel.text = model.deviceType;
    if (indexPath.row==self.dataArray.count-1) {
        cell.underLine.hidden = YES;
    }
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    AUXElectronicSpecificationModel *model = self.dataArray[indexPath.row];
    [self pushViewControllerWithUrlStr:model.instruction];
    NSArray *modelArray = [AUXElectronicSpecificationHistoryListModel MR_findAll];
    AUXElectronicSpecificationHistoryListModel *mode1 = [AUXElectronicSpecificationHistoryListModel MR_findFirstByAttribute:@"deviceType" withValue:model.deviceType];
    if (![modelArray containsObject:mode1]) {
        AUXElectronicSpecificationHistoryListModel *electronicSpecificationHistoryListModel = [AUXElectronicSpecificationHistoryListModel MR_createEntity];
        electronicSpecificationHistoryListModel.deviceType = model.deviceType;
        electronicSpecificationHistoryListModel.date = [NSDate cNowTimestamp];
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    }else{
        // 获取一个上下文对象
        NSManagedObjectContext *defaultContext = [NSManagedObjectContext MR_defaultContext];
        // 在当前上下文环境中创建一个新的Employee对象
        mode1.date  =  [NSDate cNowTimestamp];
        // 保存修改到当前上下文中
        [defaultContext MR_saveToPersistentStoreAndWait];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView*)scrollView{
    @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self);
        [self.searchTF resignFirstResponder];

    });
}

- (void)pushViewControllerWithUrlStr:(NSString*)urlstr{
    AUXUserWebViewController *userWebViewController = [AUXUserWebViewController instantiateFromStoryboard:kAUXStoryboardNameUserCenter];
    userWebViewController.isformElectronicSpecification = YES;
    NSString *newStr = [urlstr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    userWebViewController.loadUrl = newStr;
    [self.navigationController pushViewController:userWebViewController animated:YES];
}




@end





