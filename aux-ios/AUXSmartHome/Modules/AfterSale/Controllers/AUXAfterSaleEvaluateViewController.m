//
//  AUXAfterSaleEvaluateViewController.m
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2018/10/9.
//  Copyright © 2018年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXAfterSaleEvaluateViewController.h"
#import "AUXEvalluateIconCollectionViewCell.h"
#import "AUXEvaluateAddIconCollectionViewCell.h"

#import "QMUIKit.h"
#import <AVFoundation/AVCaptureDevice.h>
#import <AVFoundation/AVMediaFormat.h>
#import <AssetsLibrary/AssetsLibrary.h>

#import "UIColor+AUXCustom.h"
#import "UITableView+AUXCustom.h"
#import "AUXSoapManager.h"
#import "AUXUser.h"
#import "AUXButton.h"

@interface AUXAfterSaleEvaluateViewController ()<UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout , UIActionSheetDelegate , UIImagePickerControllerDelegate , UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet QMUITextView *evaluateTextView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *gradesButtons;
@property (weak, nonatomic) IBOutlet AUXButton *confirmBtn;


@property (nonatomic,strong) NSMutableArray *images;
@property (nonatomic,strong) NSMutableArray *imagesParams;
@property (nonatomic,copy) NSString *grade;

@property (nonatomic,strong) UICollectionViewFlowLayout *layout;

@end

@implementation AUXAfterSaleEvaluateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)initSubviews {
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"AUXEvalluateIconCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"AUXEvalluateIconCollectionViewCell"];
    [self.collectionView registerNib:[UINib nibWithNibName:@"AUXEvaluateAddIconCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"AUXEvaluateAddIconCollectionViewCell"];
    [self.collectionView setCollectionViewLayout:self.layout animated:YES];
    
    for (UIButton *button in self.gradesButtons) {
        [button addTarget:self action:@selector(gradeAtcion:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    self.confirmBtn.layer.borderColor = [UIColor colorWithHexString:@"256BBD"].CGColor;
    self.confirmBtn.enabled = NO;
}

- (void)reloadCollectionView {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.collectionView reloadData];
    });
}

#pragma mark getter
- (NSMutableArray *)images {
    if (!_images) {
        _images = [NSMutableArray array];
    }
    return _images;
}

- (NSMutableArray *)imagesParams {
    if (!_imagesParams) {
        _imagesParams = [NSMutableArray array];
    }
    return _imagesParams;
}

- (UICollectionViewFlowLayout *)layout {
    if (!_layout) {
        _layout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
        
        _layout.headerReferenceSize = CGSizeMake(0, 0);
        
        CGFloat cellWidth = (kAUXScreenWidth - 40 - 30) / 4;
        
        _layout.itemSize = CGSizeMake(cellWidth, cellWidth);
        _layout.sectionInset = UIEdgeInsetsMake(0, 20, 0, 20);
        _layout.minimumInteritemSpacing = 5;
    }
    return _layout;
}

#pragma mark setter
- (void)setWorkOrderModel:(AUXWorkOrderModel *)workOrderModel {
    _workOrderModel = workOrderModel;
}

#pragma mark - UICollectionViewDelegate & UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return self.images.count <= 3 ? self.images.count + 1 : 4;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.item < self.images.count) {
        AUXEvalluateIconCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AUXEvalluateIconCollectionViewCell" forIndexPath:indexPath];
        
        UIImage *image = self.images[indexPath.item];
        cell.imageView.image = image;
        cell.deleteBlock = ^(UIImage *image) {
            NSInteger index = [self.images indexOfObject:image];
            [self.imagesParams removeObjectAtIndex:index];
            if ([self.images containsObject:image]) {
                [self.images removeObject:image];
                [self reloadCollectionView];
            }
         
        };
        
        return cell;
    } else {
        AUXEvaluateAddIconCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AUXEvaluateAddIconCollectionViewCell" forIndexPath:indexPath];
        cell.imagesArray = self.images;
        return cell;
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return self.layout.itemSize;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    
    if ([cell isKindOfClass:[AUXEvaluateAddIconCollectionViewCell class]]) {
        [self alertSheet];
    }
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    @weakify(self)
    [picker dismissViewControllerAnimated:YES completion:^{
        @strongify(self)
        @weakify(self)
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            @strongify(self)
            UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
            NSData *data = UIImageJPEGRepresentation(image, 1.0);
            NSLog(@"原始图片大小: %lu", (unsigned long)data.length);
            int i = 0;
            while (data.length > (1 << 19) && i < 9) {
                NSLog(@"图片尺寸不合要求，开始压缩");
                i += 1;
                data = UIImageJPEGRepresentation(image, 1.0 - 0.1 * i);
                NSLog(@"第%d次压缩后图片大小: %lu", i, (unsigned long)data.length);
            }
            if (data.length > (1 << 20)) {
                [self showErrorViewWithMessage:@"选择图片尺寸过大"];
            } else {
                @weakify(self)
                dispatch_async(dispatch_get_main_queue(), ^{
                    @strongify(self)
                    UIImage *image = [UIImage imageWithData:data];
                    NSString *encodedImgStr = [data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
                    [self.images addObject:image];
                    [self.imagesParams addObject:encodedImgStr];
                    [self.collectionView reloadData];
                });
                
            }
        });
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark atcions
- (void)gradeAtcion:(UIButton *)button {
    
    self.confirmBtn.enabled = YES;
    [self.gradesButtons enumerateObjectsUsingBlock:^(UIButton *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.selected = NO;
    }];
    
    NSInteger index = [self.gradesButtons indexOfObject:button];
    
    for (NSInteger i = 0; i <= index; i++) {
        UIButton *button = self.gradesButtons[i];
        button.selected = YES;
    }
    
    self.grade = [NSString stringWithFormat:@"%ld" , index + 1];
}

- (void)alertSheet {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"选择照片" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    @weakify(self);
    [alertController addAction:[UIAlertAction actionWithTitle:@"从相册选择" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        @strongify(self);
        [self selectPhotoFrom:UIImagePickerControllerSourceTypePhotoLibrary];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
#if TARGET_IPHONE_SIMULATOR
        // no thing to do here...
#else
        @strongify(self);
        [self selectPhotoFrom:UIImagePickerControllerSourceTypeCamera];
#endif
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:kAUXLocalizedString(@"Cancle") style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:alertController animated:YES completion:nil];
}

- (void)selectPhotoFrom:(UIImagePickerControllerSourceType)type {
    if (![self isopencameraAndphotoalbum]) {
        if (type == UIImagePickerControllerSourceTypeCamera) {
            [self alertWithMessage:@"非常抱歉，同意相机权限才能正常使用拍照" confirmTitle:@"去设置" confirmBlock:^{
                NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                [[UIApplication sharedApplication] openURL:url];
            } cancelTitle:@"取消" cancelBlock:nil];
        }else  if (type == UIImagePickerControllerSourceTypePhotoLibrary){
            UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
            imagePickerController.sourceType = type;
            imagePickerController.delegate = self;
            [self.navigationController presentViewController:imagePickerController animated:YES completion:nil];
        }
    }else{
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.sourceType = type;
        imagePickerController.delegate = self;
        [self.navigationController presentViewController:imagePickerController animated:YES completion:nil];
    }
   
    


}

- (IBAction)submitAtcion:(id)sender {
    
    if (AUXWhtherNullString(self.grade)) {
        [self showFailure:@"请选择服务满意度等级"];
        return ;
    }
    
    [self showLoadingHUD];
    
    [[AUXSoapManager sharedInstance] createEvaluationWithMemo:self.evaluateTextView.text Grade:self.grade Oid:self.workOrderModel.guid EntityName:self.workOrderModel.EntityName ImgIds:self.imagesParams completion:^(BOOL result, NSError * _Nonnull error) {
        
        [self hideLoadingHUD];
        if (result) {
            [self showSuccess:@"评价成功" completion:^{
                NSMutableArray *viewControllers = [self.navigationController.viewControllers mutableCopy];
                    [viewControllers removeObjectsInRange:NSMakeRange(2, viewControllers.count - 2)];
                    [self.navigationController setViewControllers:viewControllers animated:YES];              
            }];
        } else {
            [self showFailure:[error.userInfo objectForKey:NSLocalizedDescriptionKey]];
        }
    }];
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}


@end
