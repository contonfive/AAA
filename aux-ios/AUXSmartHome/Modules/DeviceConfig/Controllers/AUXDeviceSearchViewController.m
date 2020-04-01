//
//  AUXDeviceSearchViewController.m
//  AUXSmartHome
//
//  Created by AUX on 2019/3/29.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXDeviceSearchViewController.h"
#import "AUXDeviceSearchTableViewCell.h"
#import "AUXDeviceModel.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "UIColor+AUXCustom.h"
#import "AUXWifiPasswordViewController.h"



@interface AUXDeviceSearchViewController ()<QMUINavigationControllerDelegate,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *searchTextField;
@property (weak, nonatomic) IBOutlet UIView *searchView;
@property (weak, nonatomic) IBOutlet UITableView *deviceTableView;
@property (nonatomic, assign) BOOL searchingModel;  // 是否正在搜索型号 (搜索框内有内容)
@property(nonatomic,strong)NSMutableArray<AUXDeviceModel *> *dataArray;
@end

@implementation AUXDeviceSearchViewController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    self.navigationController.navigationBarHidden = YES;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.searchView.layer.masksToBounds = YES;
    self.searchView.layer.cornerRadius = self.searchView.bounds.size.height/2;
    [self.deviceTableView registerNib:[UINib nibWithNibName:@"AUXDeviceSearchTableViewCell" bundle:nil] forCellReuseIdentifier:@"AUXDeviceSearchTableViewCell"];
    self.searchTextField.delegate = self;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldTextDidChangeNotification:) name:UITextFieldTextDidChangeNotification object:nil];
    self.deviceTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.deviceTableView.backgroundColor = [UIColor colorWithHexString:@"F7F7F7"];
    
    [self.searchTextField becomeFirstResponder];

}

-(NSMutableArray<AUXDeviceModel *> *)dataArray{
    if (!_dataArray) {
        self.dataArray = [[NSMutableArray alloc]init];
    }
    return _dataArray;
}

#pragma mark  取消按钮的点击事件
- (IBAction)cancleButtonAction:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark  tableview 每个cell显示什么内容
- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    AUXDeviceModel *dbModel = (AUXDeviceModel*)self.dataArray[indexPath.row];
    static NSString * CellIdentifier = @"AUXDeviceSearchTableViewCell";
    AUXDeviceSearchTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell.backgroundColor = [UIColor whiteColor];
    NSURL *imageURL = [NSURL URLWithString:dbModel.entityUri];
    [cell.picturesImageView sd_setImageWithURL:imageURL placeholderImage:nil];
    cell.conditionNameLabel.text = dbModel.model;
    return cell;
}

#pragma mark  tableview 每个分区返回多少行
- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}


#pragma mark  tableview 每行的高度
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80*SCALEW;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    AUXDeviceModel *deviceModel = (AUXDeviceModel*)self.dataArray[indexPath.row];
    AUXDeviceConfigType configType = (deviceModel.deviceType == 0 ? AUXDeviceConfigTypeBLDevice : AUXDeviceConfigTypeGizDeviceAirLink);
    if (deviceModel.hardwareType == AUXDeviceHardwareTypeMX) {
        configType = AUXDeviceConfigTypeMXDevice;
    }
    AUXWifiPasswordViewController *wifiPasswordViewController = [AUXWifiPasswordViewController instantiateFromStoryboard:kAUXStoryboardNameDeviceConfig];
    wifiPasswordViewController.configType = configType;
    wifiPasswordViewController.deviceModel = deviceModel;
    [self.navigationController pushViewController:wifiPasswordViewController animated:YES];
    
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldTextDidChangeNotification:(NSNotification *)notification {
    
    if (self.searchTextField.isFirstResponder) {
        NSString *text = self.searchTextField.text;
        if (self.searchTextField.markedTextRange) {
            return;
        }
        NSPredicate *predicate = nil;
        if (text.length > 0) {
           [self.dataArray removeAllObjects];
            self.searchingModel = YES;
            predicate = [NSPredicate predicateWithFormat:@"model contains[c] %@", text];
            self.dataArray = [[self.deviceModelList filteredArrayUsingPredicate:predicate] mutableCopy];
        } else {
            self.searchingModel = NO;
            [self.dataArray removeAllObjects];
        }
    }
    [self.deviceTableView reloadData];
}



#pragma mark - tableview滑动的时候收回键盘
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
}


//-(void)viewDidDisappear:(BOOL)animated{
//    self.navigationController.navigationBarHidden = NO;
//
//}
@end
