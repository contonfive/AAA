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

#import "AUXSNCodeSearchViewController.h"
#import "AUXWifiPasswordViewController.h"
#import "AUXDeviceModel.h"
#import "AUXDBDeviceModel+CoreDataClass.h"
#import "AUXNetworkManager.h"
#import "UITableView+AUXCustom.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "UIColor+AUXCustom.h"
#import "AUXTypeCollectionViewCell.h"
#import "AUXDeviceSearchViewController.h"
@interface AUXSNCodeSearchViewController ()<UITableViewDataSource,UITableViewDelegate,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,NSFetchedResultsControllerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *typeTableView;
@property (weak, nonatomic) IBOutlet UICollectionView *typeCollectView;
@property (weak, nonatomic) IBOutlet UIView *searchView;
@property (nonatomic, strong) NSFetchedResultsController *categoryFetchedResultsController;
@property (nonatomic, assign) BOOL searchingModel;  // 是否正在搜索型号 (搜索框内有内容)
@property (nonatomic, assign) NSInteger typeCollectViewNember;
@property (nonatomic, assign) NSInteger itemNumber;
@property (nonatomic, strong)NSArray<AUXDeviceModel *> * _Nullable deviceModelList;
@property (nonatomic, strong)NSMutableArray * deviceModelList1;
@property (nonatomic, strong)NSMutableArray<AUXDeviceModel *> * _Nullable deviceModelList3;


@end

@implementation AUXSNCodeSearchViewController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    self.navigationController.navigationBarHidden = NO;
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor blackColor],NSForegroundColorAttributeName,nil]];
    [[UINavigationBar appearance] setTintColor:[UIColor blackColor]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.typeTableView.scrollEnabled = NO;
    [self.typeCollectView registerNib:[UINib nibWithNibName:@"AUXTypeCollectionViewCell" bundle:nil]  forCellWithReuseIdentifier:@"AUXTypeCollectionViewCell"];
    self.typeTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.itemNumber = 0;
    [self getModelList];
    [self setSearchView];
}

- (NSMutableArray*)deviceModelList1{
    if (!_deviceModelList1) {
        self.deviceModelList1 = [[NSMutableArray alloc]init];
    }
    return _deviceModelList1;
}

- (NSMutableArray<AUXDeviceModel *> *)deviceModelList3{
    if (!_deviceModelList3) {
        self.deviceModelList3 = [[NSMutableArray alloc]init];
    }
    return _deviceModelList3;
}

- (void)reSetData{
    for (AUXDeviceModel *model in self.deviceModelList) {
        BOOL istheTester = [[MyDefaults objectForKey:kIsTheTester] integerValue];
        BOOL isListed = [[MyDefaults objectForKey:kIslisted] integerValue];
        if (istheTester && isListed) {
             [self.deviceModelList3 addObject:model];
        }else{
            if (model.deviceDisplay == 1) {
                 [self.deviceModelList3 addObject:model];
            }
        }
    }
    NSLog(@"%@",self.deviceModelList);
    NSMutableArray *hangupArray = [[NSMutableArray alloc]init];
    NSMutableArray *arkArray = [[NSMutableArray alloc]init];
    NSMutableArray *unitArray = [[NSMutableArray alloc]init];
    NSMutableArray *multigang = [[NSMutableArray alloc]init];
    for (AUXDeviceModel *model in self.deviceModelList3) {
        switch (model.category) {
            case 0:{
                [hangupArray addObject:model];
            }
                break;
            case 1:{
                [arkArray addObject:model];
            }
                break;
            case 2:{
                [unitArray addObject:model];
            }
                break;
            case 3:
            {
                [multigang addObject:model];
            }
                break;
            default:
                break;
        }
    }
//    if (hangupArray.count !=0) {
        NSDictionary *dic1 = @{@"title":@"挂机",@"content":hangupArray};
        [self.deviceModelList1 addObject:dic1];
//    }
//    if (arkArray.count !=0) {
        NSDictionary *dic2 = @{@"title":@"柜机",@"content":arkArray};
        [self.deviceModelList1 addObject:dic2];
//    }
//    if (unitArray.count !=0) {
        NSDictionary *dic3 = @{@"title":@"单元机",@"content":unitArray};
        [self.deviceModelList1 addObject:dic3];
//    }
//    if (multigang.count !=0) {
        NSDictionary *dic4 = @{@"title":@"多联机",@"content":multigang};
        [self.deviceModelList1 addObject:dic4];
//    }
    
    NSLog(@"%@",self.deviceModelList1);
    
    [self.typeTableView reloadData];
    if (self.deviceModelList1.count!=0) {
        NSIndexPath *ip=[NSIndexPath indexPathForRow:0 inSection:0];
        [self.typeTableView selectRowAtIndexPath:ip animated:YES scrollPosition:UITableViewScrollPositionBottom];
        [self tableView:self.typeTableView didSelectRowAtIndexPath:ip];
    }
}

#pragma mark  设置搜索view
-(void)setSearchView{
    self.searchView.layer.masksToBounds = YES;
    self.searchView.layer.cornerRadius = self.searchView.bounds.size.height/2;
    UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureAction)];
    [self.searchView addGestureRecognizer:tapGesture];
}

#pragma mark  搜索view的点击事件
-(void)tapGestureAction{
    AUXDeviceSearchViewController *deviceSearchViewController = [AUXDeviceSearchViewController instantiateFromStoryboard:kAUXStoryboardNameDeviceConfig];
    deviceSearchViewController.deviceModelList = self.deviceModelList3;
    [self.navigationController pushViewController:deviceSearchViewController animated:YES];
}


#pragma mark  tableview每个分区返回的行数
- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.deviceModelList1.count;
}

#pragma mark  tableview每行显示什么内容
- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    UITableViewCell *cell =[tableView dequeueReusableCellWithIdentifier:@"TYPECELL"];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"TYPECELL"];
    }
    if (self.deviceModelList1.count!=0) {
        cell.textLabel.text = self.deviceModelList1[indexPath.row][@"title"];
    }
  
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    cell.textLabel.font = [UIFont systemFontOfSize:14];
//    cell.textLabel.backgroundColor = [UIColor clearColor];
//    cell.selectedBackgroundView = [UIView new];
//    cell.selectedBackgroundView.backgroundColor = [UIColor whiteColor];
    if (self.itemNumber == indexPath.row) {
        cell.textLabel.textColor = [UIColor colorWithHexString:@"256BBD"];
        cell.backgroundColor = [UIColor whiteColor];

    }else{
        cell.textLabel.textColor = [UIColor colorWithHexString:@"666666"];
        cell.backgroundColor = [UIColor clearColor];


    }
    return cell;
}



#pragma mark  tableview每行的行高
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 64*SCALEW;
}

#pragma mark  tableview的点击事件
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSMutableArray *tmpArray = self.deviceModelList1[indexPath.row][@"content"];
    self.typeCollectViewNember =  tmpArray.count;
    self.itemNumber = indexPath.row;
    [self.typeTableView reloadData];
    [self.typeCollectView reloadData];
}

#pragma mark  collectview每个分区显示对少个item
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.typeCollectViewNember;
}

#pragma mark  collectview 定义展示的Section的个数
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

#pragma mark  collectview item展示的内容
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    AUXDeviceModel *model = self.deviceModelList1[self.itemNumber][@"content"][indexPath.row];
    static NSString * CellIdentifier = @"AUXTypeCollectionViewCell";
    AUXTypeCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    NSURL *imageURL = [NSURL URLWithString:model.entityUri];
    [cell.picturesImageView sd_setImageWithURL:imageURL placeholderImage:nil];
    cell.textLabel.text = model.model;
    return cell;
}


#pragma mark  collectview item的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake((self.typeCollectView.bounds.size.width-30)/3, 120);
}


#pragma mark  collectview 的 margin
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 5, 0, 5);//上、左、下、右
}

#pragma mark UICollectionView被选中时调用的方法
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    AUXDeviceModel *deviceModel =  self.deviceModelList1[self.itemNumber][@"content"][indexPath.row];
        AUXDeviceConfigType configType = (deviceModel.deviceType == 0 ? AUXDeviceConfigTypeBLDevice : AUXDeviceConfigTypeGizDeviceAirLink);
        if (deviceModel.hardwareType == AUXDeviceHardwareTypeMX) {
            configType = AUXDeviceConfigTypeMXDevice;
        }
        AUXWifiPasswordViewController *wifiPasswordViewController = [AUXWifiPasswordViewController instantiateFromStoryboard:kAUXStoryboardNameDeviceConfig];
        wifiPasswordViewController.configType = configType;
        wifiPasswordViewController.deviceModel = deviceModel;
        [self.navigationController pushViewController:wifiPasswordViewController animated:YES];
}

#pragma mark - 网络请求
- (void)getModelList {
    [self showLoadingHUD];
    [[AUXNetworkManager manager] getDeviceModelListWithCompletion:^(NSArray<AUXDeviceModel *> * _Nullable deviceModelList, NSError * _Nonnull error) {
        [self hideLoadingHUD];
        switch (error.code) {
            case AUXNetworkErrorNone:
                self.deviceModelList = deviceModelList;
                [self reSetData];
                break;
            case AUXNetworkErrorAccountCacheExpired:
                [self alertAccountCacheExpiredMessage];
                break;
            default:
                [self showToastshortWitherror:error];
                break;
        }
    }];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.typeTableView reloadData];
    if (self.deviceModelList1.count!=0) {
        [self.typeTableView selectRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] animated:YES scrollPosition:UITableViewScrollPositionTop];//设置选中第一行
        [self tableView:self.typeTableView didSelectRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];//实现点击第一行所调用的方法
    }
 
}


#pragma mark - QMUINavigationControllerDelegate
- (UIColor *)navigationBarTintColor {
    return [UIColor blackColor];
}

@end



