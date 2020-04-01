//
//  AUXWorkOrderLocalTableViewCell.m
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2018/10/10.
//  Copyright © 2018年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXWorkOrderLocalTableViewCell.h"
#import <MAMapKit/MAMapKit.h>
#import <AMapFoundationKit/AMapFoundationKit.h>
#import <AMapLocationKit/AMapLocationKit.h>

#import "AUXLocateTool.h"

@interface AUXWorkOrderLocalTableViewCell ()<MAMapViewDelegate>

@property (nonatomic, strong) MAMapView * mapView;

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

@end

@implementation AUXWorkOrderLocalTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (UIView *)mapView {
    if (!_mapView) {
        
        _mapView = [[MAMapView alloc] initWithFrame:self.mapBackView.bounds];
        _mapView.delegate = self;
        _mapView.mapType = MAMapTypeStandard;
        
        _mapView.zoomLevel = 18;
        _mapView.showsScale = NO;
        _mapView.showsCompass = NO;
//        _mapView.rotateEnabled = NO;
        _mapView.scrollEnabled = YES;
        
        [self.mapBackView addSubview:_mapView];
        
    }
    return _mapView;
}

- (void)setPlaceWithMapView:(CLLocationCoordinate2D)local {
    
    [self.mapView removeAnnotations:self.mapView.annotations];
    
    MAPointAnnotation * centerAnnotation = [[MAPointAnnotation alloc] init];
    centerAnnotation.coordinate = local;
    centerAnnotation.title = @"";
    centerAnnotation.subtitle = @"";
    [self.mapView addAnnotation:centerAnnotation];
    [self.mapView setCenterCoordinate:local];
}

- (void)setWorkOrderDetailModel:(AUXSubmitWorkOrderModel *)workOrderDetailModel {
    _workOrderDetailModel = workOrderDetailModel;
    
    if (_workOrderDetailModel.TopContact) {
        NSString *localString = [NSString string];
        
        if (_workOrderDetailModel.TopContact.Province) {
            localString = _workOrderDetailModel.TopContact.Province;
        }
        if (_workOrderDetailModel.TopContact.City) {
            localString = [NSString stringWithFormat:@"%@ %@" , localString , _workOrderDetailModel.TopContact.City];
        }
        if (_workOrderDetailModel.TopContact.County) {
            localString = [NSString stringWithFormat:@"%@ %@" , localString , _workOrderDetailModel.TopContact.County];
        }
        if (_workOrderDetailModel.TopContact.Town) {
            localString = [NSString stringWithFormat:@"%@ %@" , localString , _workOrderDetailModel.TopContact.Town];
        }
        if (_workOrderDetailModel.TopContact.Address) {
            localString = [NSString stringWithFormat:@"%@ %@" , localString , _workOrderDetailModel.TopContact.Address];
        }
        
        [[AUXLocateTool defaultTool] geoCodeAddress:localString completion:^(CLPlacemark *pl , NSError *error) {
            
            if (!error) {
                [self setPlaceWithMapView:pl.location.coordinate];
                self.coordinate = pl.location.coordinate;
            } else {
                
                NSString *currentLocalString = [localString substringToIndex:[localString rangeOfString:_workOrderDetailModel.TopContact.Address].location - 1];
                [[AUXLocateTool defaultTool] geoCodeAddress:currentLocalString completion:^(CLPlacemark *pl, NSError *error) {
                    [self setPlaceWithMapView:pl.location.coordinate];
                    self.coordinate = pl.location.coordinate;
                }];
               
            }
        }];
    }
}

- (void)setProductModel:(AUXProduct *)productModel {
    _productModel = productModel;
    
    if (_productModel) {
        CLLocationDegrees latitude = _productModel.Latitude.doubleValue;
        CLLocationDegrees longitude = _productModel.Longitude.doubleValue;
        
        if (latitude != 0 && longitude != 0) {
            CLLocationCoordinate2D locationCoordinate = CLLocationCoordinate2DMake(latitude, longitude);
            [self setPlaceWithMapView:locationCoordinate];
            
        } else {
            [self setPlaceWithMapView:self.coordinate];
        }
    }
}

#pragma mark MAMapViewDelegate
- (MAAnnotationView *)mapView:(MAMapView *)mapView
            viewForAnnotation:(id<MAAnnotation>)annotation {
    
    if ([annotation isKindOfClass:[MAPointAnnotation class]]) {
        static NSString *pointReuseIndentifier = @"pointReuseIndentifier";
        MAPinAnnotationView*annotationView = (MAPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:pointReuseIndentifier];
        if (annotationView == nil)
        {
            annotationView = [[MAPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pointReuseIndentifier];
        }
        annotationView.animatesDrop = NO;
        
        CLLocationDegrees latitude = self.productModel.Latitude.doubleValue;
        CLLocationDegrees longitude = self.productModel.Longitude.doubleValue;
        
        if (self.productModel.Status.integerValue >= 4) {
            annotationView.image = [UIImage imageNamed:@"scene_place_dot2"];
        } else if (latitude != 0 && longitude != 0 && self.productModel.Status.integerValue >= 2 && self.productModel.Status.integerValue < 4) {
            annotationView.image = [UIImage imageNamed:@"service_img_ontheway"];
        } else {
            annotationView.image = [UIImage imageNamed:@"service_img_waittostart"];
        }
        
        return annotationView;
    }
    return nil;
}

@end
