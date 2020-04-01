//
//  AUXMySceneTableViewCell.m
//  AUXSmartHome
//
//  Created by AUX on 2019/4/3.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXMySceneTableViewCell.h"
#import "UIColor+AUXCustom.h"
#import "AUXAlertCustomView.h"
#import "AUXLocateTool.h"


@implementation AUXMySceneTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
  
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}



- (void)setSceneDetailModel:(AUXSceneDetailModel *)sceneDetailModel {
    _sceneDetailModel = sceneDetailModel;
    self.sceneNameLabel.text = _sceneDetailModel.sceneName;

    if ([_sceneDetailModel.actionDescription containsString:@"\r\n"]) {
        _sceneDetailModel.actionDescription = [_sceneDetailModel.actionDescription stringByReplacingOccurrencesOfString:@"\r\n" withString:@""];
        
        if ([[_sceneDetailModel.actionDescription substringFromIndex:_sceneDetailModel.actionDescription.length - 1] isEqualToString:@""]) {
            _sceneDetailModel.actionDescription = [_sceneDetailModel.actionDescription substringToIndex:_sceneDetailModel.actionDescription.length - 1];
        }
    }
    self.sceneDescribeLabel.text = _sceneDetailModel.actionDescription;
        if (_sceneDetailModel.state == AUXScenePowerOn) {
            self.switchButton.selected = YES;
            self.switchImageView.image = [UIImage imageNamed:@"common_btn_on"];
        } else {
            self.switchButton.selected = NO;
            self.switchImageView.image = [UIImage imageNamed:@"common_btn_off"];

        }
    
}
    



#pragma mark  开关
- (IBAction)switchButtonAction:(UIButton *)sender {
    
    if (self.sceneDetailModel.sceneType == AUXSceneTypeOfPlace) {
        if (![AUXLocateTool whtherOpenLocalionPermissions]) {
            [AUXAlertCustomView alertViewWithMessage:@"请先开启定位服务" confirmAtcion:^{
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
            } cancleAtcion:^{
            }];
            return ;
        }
    }
    
    
    
 
    
    
    self.switchButton.selected = !self.switchButton.selected;
    self.sceneDetailModel.state = self.switchButton.selected;
    if (self.autoPerformBlock) {
        self.autoPerformBlock(self.sceneDetailModel , self.switchButton.selected);
    }

    if ( self.switchButton.selected) {
        self.switchImageView.image = [UIImage imageNamed:@"common_btn_on"];
    }else{
        self.switchImageView.image = [UIImage imageNamed:@"common_btn_off"];

    }

}

#pragma mark  执行
- (IBAction)actionButtonAction:(UIButton *)sender {
    if (self.manualPerfomBlock) {
        self.manualPerfomBlock(self.sceneDetailModel);
    }
}




@end
