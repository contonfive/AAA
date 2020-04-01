//
//  AUXHomePageWallpaperViewController.m
//  AUXSmartHome
//
//  Created by AUX on 2019/5/13.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXHomePageWallpaperViewController.h"
#import "AUXHomePageWallpaperCollectionViewCell.h"
#import "AUXSelectWallpaperViewController.h"



@interface AUXHomePageWallpaperViewController ()<UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
@property (weak, nonatomic) IBOutlet UICollectionView *collectView;
@property (nonatomic,strong)NSArray *dataArray;
@property (nonatomic,assign)NSInteger selectIndex;

@end

@implementation AUXHomePageWallpaperViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.collectView registerNib:[UINib nibWithNibName:@"AUXHomePageWallpaperCollectionViewCell" bundle:nil]  forCellWithReuseIdentifier:@"AUXHomePageWallpaperCollectionViewCell"];
    self.dataArray = @[@"index_bg01",@"index_bg02",@"index_bg03",@"index_bg04",@"index_bg05",];
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear: YES];
    
    NSString *imageName = [MyDefaults objectForKey:kSelectHomepageBackImageName];
    
    for (int i = 0; i < self.dataArray.count; i++) {
        if ([self.dataArray[i] isEqualToString:imageName]) {
            self.selectIndex = i;
        }
    }
    [self.collectView reloadData];
}

#pragma mark  collectview每个分区显示对少个item
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.dataArray.count;
}

#pragma mark  collectview 定义展示的Section的个数
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

#pragma mark  collectview item展示的内容
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * CellIdentifier = @"AUXHomePageWallpaperCollectionViewCell";
    AUXHomePageWallpaperCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.backGroundImageView.image = [UIImage imageNamed:self.dataArray[indexPath.row]];
    if (indexPath.row==self.selectIndex) {
        cell.selectImageView.hidden = NO;
    }else{
        cell.selectImageView.hidden = YES;
    }
    return cell;
}


#pragma mark  collectview item的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(142, 286);
}


#pragma mark  collectview 的 margin
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, (kScreenWidth-284)/3, 0, (kScreenWidth-284)/3);//上、左、下、右
}

#pragma mark UICollectionView被选中时调用的方法
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
   
    AUXSelectWallpaperViewController *selectWallpaperViewController = [AUXSelectWallpaperViewController instantiateFromStoryboard:kAUXStoryboardNameUserCenter];
    selectWallpaperViewController.imageName = self.dataArray[indexPath.row];
    [self.navigationController pushViewController:selectWallpaperViewController animated:YES];
    
    
}


@end
