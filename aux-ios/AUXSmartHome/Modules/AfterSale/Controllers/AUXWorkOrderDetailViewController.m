//
//  AUXWorkOrderDetailViewController.m
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2018/9/27.
//  Copyright © 2018年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXWorkOrderDetailViewController.h"
#import "AUXServiceRecordViewController.h"
#import "AUXAfterSaleEvaluateViewController.h"
#import "AUXWorkOrderDetailProgressTableViewCell.h"
#import "AUXWorkOrderServiceStatusTableViewCell.h"
#import "AUXWorkOrderLocalTableViewCell.h"
#import "AUXWorkOrderContactTableViewCell.h"
#import "AUXWorkOrderDeviceTableViewCell.h"
#import "AUXWorkOrderInfoTableViewCell.h"
#import "AUXAfterSaleFooterView.h"

#import "UITableView+AUXCustom.h"
#import "NSDate+AUXCustom.h"
#import "AUXSoapManager.h"
#import "AUXNetworkManager.h"
#import "AUXUser.h"
#import "AUXButton.h"
#import "UIColor+AUXCustom.h"

@interface AUXWorkOrderDetailViewController ()<UITableViewDelegate , UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *evaluateBackView;
@property (weak, nonatomic) IBOutlet AUXButton *evaluateButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewbottom;

@property (nonatomic,strong) AUXProduct *productModel;
@property (nonatomic,strong) AUXSubmitWorkOrderModel *workOrderDetailModel;
@property (nonatomic,strong) NSMutableDictionary *channelDict;

@property (nonatomic,assign) CGFloat memoStringHeight;
@end

@implementation AUXWorkOrderDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self requestWorkDetail];
    
    [self requestWorkProgress];
    
    [self requestChannelType];
}

- (void)initSubviews {
    [self.tableView registerCellWithNibName:@"AUXWorkOrderDetailProgressTableViewCell"];
    [self.tableView registerCellWithNibName:@"AUXWorkOrderServiceStatusTableViewCell"];
    [self.tableView registerCellWithNibName:@"AUXWorkOrderLocalTableViewCell"];
    [self.tableView registerCellWithNibName:@"AUXWorkOrderContactTableViewCell"];
    [self.tableView registerCellWithNibName:@"AUXWorkOrderDeviceTableViewCell"];
    [self.tableView registerCellWithNibName:@"AUXWorkOrderInfoTableViewCell"];
    
    self.evaluateButton.layer.borderColor = [[UIColor colorWithHexString:@"256BBD"] CGColor];
    
//    self.tableView.estimatedRowHeight = 200;
//    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    if (self.workOrderModel.IsFinsh) {
        self.evaluateBackView.hidden = NO;
        self.tableViewbottom.constant = 0;
    } else {
        self.evaluateBackView.hidden = YES;
        self.tableViewbottom.constant = 0;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.view layoutIfNeeded];
    });
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    
}

- (void)tableViewReloadData {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

#pragma mark 网络请求
//获取工单安装/维修详细信息
- (void)requestWorkDetail {
    
    [[AUXSoapManager sharedInstance] getWorkOrderDetailWithGuid:self.workOrderModel.guid entityName:self.workOrderModel.EntityName completion:^(AUXSubmitWorkOrderModel *workOrderDetailModel, NSError * _Nonnull error) {
        self.workOrderDetailModel = workOrderDetailModel;
        self.workOrderDetailModel.Product.workOrderType = self.workOrderModel.workOrderType;
        
        self.memoStringHeight = [self getMemoStringHeightWithLabelWidth:kAUXScreenWidth * 0.8 font:13 string:self.workOrderDetailModel.Memo].height;
        [self tableViewReloadData];
    }];
}
//进度查询
- (void)requestWorkProgress {

    [[AUXSoapManager sharedInstance] getProgressWithOid:self.workOrderModel.guid entityName:self.workOrderModel.EntityName completion:^(AUXProduct *productModel, NSError * _Nonnull error) {
        self.productModel = productModel;
        self.productModel.workOrderType = self.workOrderModel.workOrderType;
        [self tableViewReloadData];
    }];
}

- (void)requestChannelType {
    [self.channelDict removeAllObjects];
    [[AUXNetworkManager manager] getAfterSaleChanneltypeCompletion:^(NSArray<AUXChannelTypeModel *> * _Nonnull channelTypeList) {
        
        for (AUXChannelTypeModel *channelTypeModel in channelTypeList) {
            [self.channelDict setObject:channelTypeModel.Name forKey:channelTypeModel.Value];
        }
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:2];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }];
}

#pragma mark getter
- (NSMutableDictionary *)channelDict {
    if (!_channelDict) {
        _channelDict = [NSMutableDictionary dictionary];
    }
    return _channelDict;
}

#pragma mark setter
- (void)setWorkOrderModel:(AUXWorkOrderModel *)workOrderModel {
    _workOrderModel = workOrderModel;
}

- (CGSize)getMemoStringHeightWithLabelWidth:(CGFloat)width font:(CGFloat)font string:(NSString *)string {
    CGSize size = [string boundingRectWithSize:CGSizeMake(width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:font]} context:nil].size;
    return size;
}

#pragma mark action
- (IBAction)evaluateAtcion:(id)sender {
    AUXAfterSaleEvaluateViewController *evaluateViewController = [AUXAfterSaleEvaluateViewController instantiateFromStoryboard:kAUXStoryboardNameAfterSale];
    evaluateViewController.workOrderModel = self.workOrderModel;
    [self.navigationController pushViewController:evaluateViewController animated:YES];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 3;
    } else if (section == 1) {
        return 1;
    }
    return 2;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] init];
    headerView.backgroundColor = [UIColor clearColor];
    
    return headerView;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if (section == 2) {
        AUXAfterSaleFooterView *footerView = [[NSBundle mainBundle] loadNibNamed:@"AUXAfterSaleFooterView" owner:nil options:nil].firstObject;
        
        @weakify(footerView);
        footerView.phoneBlock = ^{
            @strongify(footerView);
            NSMutableString *str=[[NSMutableString alloc] initWithFormat:@"telprompt://%@",footerView.phoneButton.currentTitle];
            
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
        };
        return footerView;
    }
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            AUXWorkOrderDetailProgressTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AUXWorkOrderDetailProgressTableViewCell" forIndexPath:indexPath];
            cell.workOrderDetailModel = self.workOrderDetailModel;
            cell.productModel = self.productModel;
            cell.userInteractionEnabled = NO;
            
            return cell;
        } else if (indexPath.row == 1) {
            AUXWorkOrderServiceStatusTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AUXWorkOrderServiceStatusTableViewCell" forIndexPath:indexPath];
            
            cell.productModel = self.productModel;
            cell.workOrderModel = self.workOrderModel;
            return cell;
        }
        
        AUXWorkOrderLocalTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AUXWorkOrderLocalTableViewCell" forIndexPath:indexPath];
        cell.workOrderDetailModel = self.workOrderDetailModel;
        cell.productModel = self.productModel;
//        cell.userInteractionEnabled = NO;
        return cell;
    }  else if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            AUXWorkOrderDeviceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AUXWorkOrderDeviceTableViewCell"];
            cell.workOrderDetailModel = self.workOrderDetailModel;
            cell.userInteractionEnabled = NO;
            cell.bottomView.hidden = NO;
            return cell;
        }
        
        AUXWorkOrderInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AUXWorkOrderInfoTableViewCell" forIndexPath:indexPath];
        cell.userInteractionEnabled = NO;
        cell.workOrderDetailModel = self.workOrderDetailModel;
        
        return cell;
    } else {
        AUXWorkOrderContactTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AUXWorkOrderContactTableViewCell" forIndexPath:indexPath];
        cell.workOrderDetailModel = self.workOrderDetailModel;
        cell.userInteractionEnabled = NO;
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if (indexPath.section == 0 && indexPath.row == 1) {
        AUXWorkOrderServiceStatusTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        
        if (cell.productModel.ProgressList.count == 0) {
            return ;
        }
        
        AUXServiceRecordViewController *serviceRecordViewController = [AUXServiceRecordViewController instantiateFromStoryboard:kAUXStoryboardNameAfterSale];
        serviceRecordViewController.ProgressList = cell.productModel.ProgressList;
        [self.navigationController pushViewController:serviceRecordViewController animated:YES];
    }
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            return kAUXScreenWidth * 0.35;
        } else if (indexPath.row == 1) {
            return kAUXScreenWidth * 0.288;
        }
        return kAUXScreenWidth * 0.56;
    } else if (indexPath.section == 1) {

        return kAUXScreenWidth * 0.27 + self.workOrderDetailModel.TopContact.addressHeight - 16;
    } else {
        if (indexPath.row == 0) {
            return kAUXScreenWidth * 0.26;
        }

        return kAUXScreenWidth * 0.26 + self.memoStringHeight;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return 12;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == 2) {
        return 50;
    }
    return 0.5;
}

@end
