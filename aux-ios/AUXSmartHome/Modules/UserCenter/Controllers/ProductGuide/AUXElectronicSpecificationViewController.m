//
//  AUXElectronicSpecificationViewController.m
//  AUXSmartHome
//
//  Created by AUX on 2019/7/9.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXElectronicSpecificationViewController.h"
#import "AUXHistoryListTableViewCell.h"
#import "AUXSearchEquipmentViewController.h"
#import "AUXScanCodeViewController.h"
#import "AUXUserWebViewController.h"
#import "AUXAlertCustomView.h"
#import "AUXElectronicSpecificationHistoryListModel+CoreDataClass.h"
#import "NSDate+AUXCustom.h"
#import "AUXNetworkManager.h"


@interface AUXElectronicSpecificationViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property (nonatomic,strong)NSMutableArray *dataArray;
@end

@implementation AUXElectronicSpecificationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableview registerNib:[UINib nibWithNibName:@"AUXHistoryListTableViewCell" bundle:nil] forCellReuseIdentifier:@"AUXHistoryListTableViewCell"];
    self.textField.userInteractionEnabled = NO;
    self.textField.layer.cornerRadius = 2;
    self.textField.layer.masksToBounds = YES;
    self.tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableview.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
     [self requestData];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    [self geteData];
}

- (NSMutableArray *)dataArray{
    if (!_dataArray) {
        self.dataArray = [[NSMutableArray alloc] init];
    }
    return _dataArray;
}

#pragma mark  获取历史查看数据
- (void)geteData{
    [self.dataArray removeAllObjects];
    NSArray *modelArray2 = [AUXElectronicSpecificationHistoryListModel MR_findAllSortedBy:@"date" ascending:NO];
    self.dataArray = modelArray2.mutableCopy;
    if (modelArray2.count>10) {
        AUXElectronicSpecificationHistoryListModel *model = self.dataArray[9];
        for (AUXElectronicSpecificationHistoryListModel *tmpmodel in modelArray2) {
            if ([tmpmodel.date doubleValue] < [model.date doubleValue]) {
                [tmpmodel MR_deleteEntity];
                [self.dataArray removeObject:tmpmodel];
            }
        }
    }
    if (self.dataArray.count==0) {
        self.headerView.hidden = YES;
    }else{
        self.headerView.hidden = NO;
    }
    [self.tableview reloadData];
}

#pragma mark  扫描按钮的点击事件
- (IBAction)scanButtonAction:(UIButton *)sender {
    AUXScanCodeViewController *scanCodeViewController = [AUXScanCodeViewController instantiateFromStoryboard:kAUXStoryboardNameDeviceConfig];
    scanCodeViewController.scanPurpose = AUXScanPurposeCompletingElectronicSpecificationScan;
    [self.navigationController pushViewController:scanCodeViewController animated:YES];
}

#pragma mark  删除历史缓存
- (IBAction)deleteButtonAction:(UIButton *)sender {
    @weakify(self);
    [AUXAlertCustomView alertViewWithMessage:@"是否确认删除历史查看？" confirmAtcion:^{
        @strongify(self);
        [AUXElectronicSpecificationHistoryListModel MR_truncateAll];
        [self geteData];
    } cancleAtcion:^{
        
    }];
}

#pragma mark  搜索按钮的点击事件
- (IBAction)searchButtonAction:(UIButton *)sender {
    AUXSearchEquipmentViewController *searchEquipmentViewController = [AUXSearchEquipmentViewController instantiateFromStoryboard:kAUXStoryboardNameUserCenter];
     @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^(void){
        @strongify(self);
        UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:searchEquipmentViewController];
        [self presentViewController:nav animated:YES completion:nil];
    });
}

#pragma mark  tableview 的代理方法
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    AUXHistoryListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AUXHistoryListTableViewCell" forIndexPath:indexPath];
    AUXElectronicSpecificationHistoryListModel *model = self.dataArray[indexPath.row];
    cell.textTitleLabel.text = model.deviceType;
    if (indexPath.row== self.dataArray.count-1) {
        cell.underLine.hidden = YES;
    }
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    AUXElectronicSpecificationHistoryListModel *model = self.dataArray[indexPath.row];
    AUXElectronicSpecificationModel *electronicSpecificationModel = [AUXElectronicSpecificationModel MR_findFirstByAttribute:@"deviceType" withValue:model.deviceType];
    [self pushViewControllerWithUrlStr:electronicSpecificationModel.instruction];
    // 获取一个上下文对象
    NSManagedObjectContext *defaultContext = [NSManagedObjectContext MR_defaultContext];
    // 在当前上下文环境中创建一个新的Employee对象
    model.date  =  [NSDate cNowTimestamp];
    // 保存修改到当前上下文中
    [defaultContext MR_saveToPersistentStoreAndWait];
}

- (void)pushViewControllerWithUrlStr:(NSString*)urlstr{
    AUXUserWebViewController *userWebViewController = [AUXUserWebViewController instantiateFromStoryboard:kAUXStoryboardNameUserCenter];
    userWebViewController.isformElectronicSpecification = YES;
    NSString *newStr = [urlstr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    userWebViewController.loadUrl = newStr;
    [self.navigationController pushViewController:userWebViewController animated:YES];
}


#pragma mark  获取数据
- (void)requestData{
    NSString *locaVersion = [MyDefaults objectForKey:kAUXElectronicSpecificationVersion];
    locaVersion = AUXWhtherNullString(locaVersion)?@"v0":locaVersion;
    [self show];
    @weakify(self);
    [[AUXNetworkManager manager] getAllelectronicUrlsByVersion:locaVersion completion:^(NSArray * _Nonnull array, NSError * _Nonnull error, NSString * _Nonnull resultversion, NSInteger code) {
        @strongify(self);
        [self hidden];
        
        if (error != nil) {
            [self showToastshortWithmessageinCenter:error.localizedDescription];
            return ;
        }
        if (![locaVersion isEqualToString:resultversion]) {
            if (code == AUXNetworkErrorNone && array.count>0) {
                [AUXElectronicSpecificationModel MR_truncateAll];
                [AUXElectronicSpecificationModel convertToDBModelList:array];
                [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
                [MyDefaults setObject:resultversion forKey:kAUXElectronicSpecificationVersion];
            }
        }
    }];
}

- (void)show{
    MBProgressHUD * progressHUD = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    progressHUD.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
    progressHUD.bezelView.color = [UIColor blackColor];
    progressHUD.contentColor = [UIColor whiteColor];
    progressHUD.userInteractionEnabled = NO;
    [progressHUD showAnimated:YES];
}

- (void)hidden{
    [MBProgressHUD hideHUDForView:[UIApplication sharedApplication].keyWindow animated:YES];
}
@end

