//
//  AUXSceneMapViewController.m
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2018/8/14.
//  Copyright © 2018年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXSceneMapViewController.h"
#import "AUXSceneMapSearchViewController.h"
#import "AUXPOITableViewCell.h"
#import "AUXButton.h"
#import "AMapTipAnnotation.h"
#import "MJRefresh.h"
#import <MAMapKit/MAMapKit.h>
#import <AMapFoundationKit/AMapFoundationKit.h>
#import <AMapSearchKit/AMapSearchKit.h>
#import <AMapLocationKit/AMapLocationKit.h>
#import "AUXSceneSelectDeviceListViewController.h"
#import "AUXSceneCommonModel.h"
#import "AUXSceneAddNewDetailViewController.h"
#import "UIColor+AUXCustom.h"


@interface AUXSceneMapViewController ()<MAMapViewDelegate, AMapSearchDelegate , UITableViewDataSource, UITableViewDelegate,AMapLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet UIView *mapBackView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *localButton;
@property (nonatomic, assign) CLLocationCoordinate2D currentLocationCoordinate;
@property (nonatomic, strong) MAMapView * mapView;
@property (nonatomic,strong)  AMapSearchAPI *mapSearch;
@property (nonatomic,strong)  NSMutableArray *dataArray;
@property (nonatomic ,strong) NSIndexPath *selectedIndexPath;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UIView *circleView;
@property (nonatomic ,assign)NSInteger distance;
@property(nonatomic,strong) AMapLocationManager *locationManager;
@property(nonatomic,strong)AMapReGeocodeSearchRequest *regeo;
@property (nonatomic,strong) AMapPOI *poiModel;
@property (weak, nonatomic) IBOutlet UIView *searchBackView;
@end

@implementation AUXSceneMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = self.titleStr;
    [self setAMapView];
    [self.circleView layoutIfNeeded];
    self.circleView.layer.masksToBounds = YES;
    self.circleView.layer.cornerRadius = self.circleView.frame.size.height/2;
    self.circleView.userInteractionEnabled = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self.location.length ==0) {
            if ([self.isNewAdd isEqualToString:@"新增场景"]) {
                [self startSerialLocation];
            }
        }
    });
    self.searchBackView.layer.masksToBounds = YES;
    self.searchBackView.layer.cornerRadius = 2;
    self.searchBackView.layer.borderWidth = 1;
    self.searchBackView.layer.borderColor = [[UIColor colorWithHexString:@"EEEEEE"] CGColor];
    self.tableView.separatorColor = [UIColor colorWithHexString:@"F6F6F6"];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
        if (self.location.length !=0) {
            NSArray *localArray = [self.location componentsSeparatedByString:@","];
            CLLocationDegrees latitude = [localArray.firstObject doubleValue];
            CLLocationDegrees longitude = [localArray.lastObject doubleValue];
            CLLocationCoordinate2D locationCoordinate = CLLocationCoordinate2DMake(latitude, longitude);
            [self.mapView setCenterCoordinate:locationCoordinate animated:YES];
        }
    
}


#pragma mark  设置地图
- (void)setAMapView {
    self.mapView = [[MAMapView alloc] initWithFrame:self.mapBackView.bounds];
    self.mapView.delegate = self;
    self.mapView.mapType = MAMapTypeStandard;
    self.mapView.minZoomLevel = 11.5;
    self.mapView.zoomLevel = 15.5;
    self.mapView.showsScale = NO;
    self.mapView.showsCompass = NO;
    self.mapView.showsUserLocation = YES;
    self.mapView.userTrackingMode = MAUserTrackingModeNone;
    [self.mapBackView insertSubview:self.mapView atIndex:0];
    self.mapSearch = [[AMapSearchAPI alloc] init];
    self.mapSearch.delegate = self;
    self.mapView.delegate = self;
   
    
}
- (void)tableReload {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

#pragma mark atcions
- (void)presentMapSearchViewController {
    AUXSceneMapSearchViewController *mapSearchViewController = [AUXSceneMapSearchViewController instantiateFromStoryboard:kAUXStoryboardNameScene];
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:mapSearchViewController];
    mapSearchViewController.cellSelcetedBlock = ^(AMapTip *tip) {
        AMapTip *tipModel = tip;
        CLLocationCoordinate2D locationCoordinate = CLLocationCoordinate2DMake(tipModel.location.latitude, tipModel.location.longitude);
        [self searchLocationWithCoordinate2D:locationCoordinate];
        [self->_mapView setCenterCoordinate:locationCoordinate animated:YES];
        self.selectedIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    };
    [self presentViewController:nav animated:YES completion:nil];
}


#pragma mark  回到中心点
- (IBAction)localAtcion:(id)sender {
    [self startSerialLocation];
}


- (void)mapView:(MAMapView *)mapView mapDidMoveByUser:(BOOL)wasUserAction {
    [self setPlaceWithMapView:mapView];
}

- (void)setPlaceWithMapView:(MAMapView *)mapView {
    
    if (self.location.length ==0) {
        
    }
    CLLocationCoordinate2D centerCoordinate = self.mapView.region.center;
    self.currentLocationCoordinate = centerCoordinate;
    [self searchLocationWithCoordinate2D:centerCoordinate];
    [self.mapView setCenterCoordinate:centerCoordinate animated:YES];
    [self.tableView setContentOffset:CGPointMake(0,0) animated:NO];
    self.selectedIndexPath=[NSIndexPath indexPathForRow:0 inSection:0];
}



#pragma mark - UITableViewDelegate && UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellID = @"AUXPOITableViewCell";
    AUXPOITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:cellID owner:nil options:nil] firstObject];
    }
    AMapPOI *POIModel = self.dataArray[indexPath.row];
    cell.nameLabel.text = POIModel.name;
    cell.addressLable.text = POIModel.address;
    if (indexPath.row==self.selectedIndexPath.row){
        cell.arrowImageview.hidden = NO;
    }else{
         cell.arrowImageview.hidden = YES;
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
        AMapPOI *POIModel = self.dataArray[indexPath.row];
        self.poiModel = POIModel;
        self.selectedIndexPath = indexPath;
        [self.tableView reloadData];
}

#pragma mark  地图放缩结束后就会调用的方法
- (void)mapView:(MAMapView *)mapView mapDidZoomByUser:(BOOL)wasUserAction{
    CGFloat dd = (kScreenWidth-120)*mapView.metersPerPointForCurrentZoomLevel/2;
    self.distanceLabel.text = [NSString stringWithFormat:@"%d米内",(int)dd];
    self.distance = (int)dd;
}

#pragma mark  搜索按钮的点击事件
- (IBAction)seachButtonAction:(UIButton *)sender {
    [self presentMapSearchViewController];
}

#pragma mark  确定按钮的点击事件
- (IBAction)ensureButtonAction:(id)sender {
        if (self.poiModel == nil) {
            self.poiModel = self.dataArray.firstObject;
        }
        if ([self.markType isEqualToString:@"changeplace"]) {
            [MyDefaults setObject:@"1" forKey:kIsSceneEdit];
            AUXSceneCommonModel *commonModel = [AUXSceneCommonModel shareAUXSceneCommonModel];
            commonModel.address = self.poiModel.address;
            commonModel.distance = self.distance;
            commonModel.actionType = [self.titleStr isEqualToString:@"离开某地"]?1:2;
            commonModel.location = [NSString stringWithFormat:@"%f,%f",self.poiModel.location.latitude,self.poiModel.location.longitude];
            AUXSceneAddNewDetailViewController *sceneAddNewDetailViewController = nil;
            for (AUXBaseViewController *tempVc in self.navigationController.viewControllers) {
                if ([tempVc isKindOfClass:[AUXSceneAddNewDetailViewController class]]) {
                    sceneAddNewDetailViewController = (AUXSceneAddNewDetailViewController*)tempVc;
                    [self.navigationController popToViewController:sceneAddNewDetailViewController animated:YES];
                }
            }
        }else{
            AUXSceneSelectDeviceListViewController *selectDeviceListViewController = [AUXSceneSelectDeviceListViewController instantiateFromStoryboard:kAUXStoryboardNameScene];
            selectDeviceListViewController.isNewAdd = self.isNewAdd;
            selectDeviceListViewController.sceneType = AUXSceneTypeOfPlace;
            AUXSceneCommonModel *commonModel = [AUXSceneCommonModel shareAUXSceneCommonModel];
            commonModel.address = self.poiModel.name;
            commonModel.distance = self.distance;
            commonModel.location = [NSString stringWithFormat:@"%f,%f",self.poiModel.location.latitude,self.poiModel.location.longitude];
            commonModel.actionType = [self.titleStr isEqualToString:@"离开某地"]?1:2;
            [self.navigationController pushViewController:selectDeviceListViewController animated:YES];
        }
}


#pragma mark  懒加载创建定位的类
- (AMapLocationManager *)locationManager {
    if (!_locationManager) {
        self.locationManager = [[AMapLocationManager alloc] init];
        self.locationManager.delegate = self;
    }
    return _locationManager;
}

#pragma mark  开始定位
- (void)startSerialLocation {
    [self.locationManager startUpdatingLocation];
}

#pragma mark  结束定位
- (void)stopSerialLocation{
    [self.locationManager stopUpdatingLocation];
}

#pragma mark  定位回调
- (void)amapLocationManager:(AMapLocationManager *)manager didUpdateLocation:(CLLocation *)location reGeocode:(AMapLocationReGeocode *)reGeocode{
    [self.mapView setCenterCoordinate:location.coordinate animated:YES];
    [self searchLocationWithCoordinate2D:location.coordinate];
    [self stopSerialLocation];
}


#pragma mark  搜索事件

- (void)searchLocationWithCoordinate2D:(CLLocationCoordinate2D )coordinate {
    if (!self.regeo) {
        self.regeo = [[AMapReGeocodeSearchRequest alloc] init];
    }
    self.regeo.location = [AMapGeoPoint locationWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    self.regeo.radius = 20000;
    self.regeo.requireExtension = YES;
    [self.mapSearch AMapReGoecodeSearch: self.regeo];
}

- (void)onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response {
    if(response.regeocode != nil){
        [self.dataArray removeAllObjects];
        self.dataArray = response.regeocode.pois.mutableCopy;
         AMapPOI *POIModel = self.dataArray.firstObject;
        NSLog(@"%@====%@====%@",POIModel.address,POIModel.name,POIModel.uid);
        if ([POIModel.address isEqualToString:@"缎库胡同15号"]||[POIModel.address isEqualToString:@"缎库胡同15号院"]||[POIModel.address isEqualToString:@"B0FFGBD3P0"]) {

            if (self.location.length ==0) {
                [self startSerialLocation];
            }
        }else{
             [self.tableView reloadData];
        }
      
    }
}

@end
