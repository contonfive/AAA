//
//  AUXWorkOrderServiceDetailTableViewCell.m
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2018/10/11.
//  Copyright © 2018年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXWorkOrderServiceDetailTableViewCell.h"

@implementation AUXWorkOrderServiceDetailTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setIndexPath:(NSIndexPath *)indexPath {
    _indexPath = indexPath;
    self.currentButton.selected = NO;
    
    if (_indexPath) {
        if (_indexPath.row == self.ProgressList.count - 1) {
            self.bottomSegmentationView.hidden = YES;
        }
        if (_indexPath.row == 0) {
            self.currentButton.selected = YES;
            self.topSegmentationView.hidden = YES;
        }
        
    }
}

- (void)setProgressList:(NSArray<AUXProgressListModel *> *)ProgressList {
    _ProgressList = ProgressList;
}

- (void)setProgressListModel:(AUXProgressListModel *)ProgressListModel {
    _ProgressListModel = ProgressListModel;
    
    if (_ProgressListModel) {
        self.statusLabel.text = _ProgressListModel.Status;
        self.contentLabel.text = _ProgressListModel.Memo;
        self.createOnLabel.text = [NSString stringWithFormat:@"%@ %@" , _ProgressListModel.DealDate , _ProgressListModel.DealTime];
    }
}

@end
