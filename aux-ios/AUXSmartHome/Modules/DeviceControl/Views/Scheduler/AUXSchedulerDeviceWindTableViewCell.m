//
//  AUXSchedulerDeviceWindTableViewCell.m
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2019/4/11.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXSchedulerDeviceWindTableViewCell.h"
#import "AUXSchedulerSubTitleCollectionCell.h"
#import "UIColor+AUXCustom.h"

@interface AUXSchedulerDeviceWindTableViewCell ()<UICollectionViewDataSource , UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;


@end

@implementation AUXSchedulerDeviceWindTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"AUXSchedulerSubTitleCollectionCell" bundle:nil] forCellWithReuseIdentifier:@"AUXSchedulerSubTitleCollectionCell"];
}

- (void)setDataArray:(NSMutableArray *)dataArray {
    _dataArray = dataArray;
    
    if (_dataArray) {
        
        CGFloat padding = 10;
        CGFloat itemWidth = (kAUXScreenWidth - (_dataArray.count - 1) * padding - 40) / _dataArray.count;
        
        UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
        flowLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
        flowLayout.itemSize = CGSizeMake(itemWidth, 30);
        flowLayout.minimumLineSpacing = 10;
        
        [self.collectionView reloadData];
    }
    
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dict = self.dataArray[indexPath.row];
    
    NSString *title = dict[@"title"];
    BOOL selected = [dict[@"selected"] boolValue];
    
    
    AUXSchedulerSubTitleCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AUXSchedulerSubTitleCollectionCell" forIndexPath:indexPath];

    cell.titleBtn.selected = selected;
    cell.titleLabel.text = title;
    
    if (selected) {
        cell.titleLabel.textColor = [UIColor whiteColor];
        cell.titleLabel.backgroundColor = [UIColor colorWithHexString:@"256BBD"];
    } else {
        cell.titleLabel.textColor = [UIColor colorWithHexString:@"666666"];
        cell.titleLabel.backgroundColor = [UIColor whiteColor];
    }
    
    @weakify(self);
    cell.btnSlectedBlock = ^(BOOL selected) {
      @strongify(self);
        if (selected) {
            if (self.selectedBtnBlock) {
                self.selectedBtnBlock(title);
            }
        } else {
            if (self.deSelectedBtnBlock) {
                self.deSelectedBtnBlock(title);
            }
        }
        
    };
    
    return cell;
}


@end
