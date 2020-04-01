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

#import "AUXElectricityConsumptionCurveChildViewController.h"

#import "AUXElectricityConsumptionCurveView.h"

#import "NSDate+AUXCustom.h"

@interface AUXElectricityConsumptionCurveChildViewController ()

@property (nonatomic, strong) AUXElectricityConsumptionCurveView *curveView;

@end

@implementation AUXElectricityConsumptionCurveChildViewController

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.curveView = [[AUXElectricityConsumptionCurveView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.curveView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    self.curveView.frame = self.view.bounds;
}

- (void)initSubviews {
    [super initSubviews];
    
    self.curveView.year = self.year;
    self.curveView.month = self.month;
    self.curveView.day = self.day;
    self.curveView.dateType = self.dateType;
}

- (void)updateCurve {
    
    self.curveView.year = self.year;
    self.curveView.month = self.month;
    self.curveView.day = self.day;
    self.curveView.dateType = self.dateType;
    self.curveView.oldDevice = (self.source == AUXDeviceSourceBL);
    
    self.curveView.pointModelList = self.pointModelList;
    
    [self.curveView updateCurveView];
}

@end
