//
//  AUXFeedbackViewController.m
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2018/8/1.
//  Copyright © 2018年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXFeedbackViewController.h"
#import "AUXEvalluateIconCollectionViewCell.h"
#import "AUXEvaluateAddIconCollectionViewCell.h"

#import "AUXNetworkManager.h"
#import "AUXUser.h"
#import "UITableView+AUXCustom.h"
#import "UIColor+AUXCustom.h"
#import "NSDate+AUXCustom.h"
#import "NSString+AUXCustom.h"

#import <AVFoundation/AVCaptureDevice.h>
#import <AVFoundation/AVMediaFormat.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "AUXMobileInformationTool.h"
#import "AUXQuestionTypeViewController.h"

#import "UIColor+AUXCustom.h"

#import "AUXUserWebViewController.h"


@interface AUXFeedbackViewController ()< UICollectionViewDelegate , UICollectionViewDataSource , UIActionSheetDelegate , UIImagePickerControllerDelegate , UINavigationControllerDelegate , UITextViewDelegate , UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UITextField *phoneTextfiled;
@property (weak, nonatomic) IBOutlet UILabel *placholderLabel;

@property (nonatomic,strong) UICollectionViewFlowLayout *layout;
@property (nonatomic,strong) NSMutableArray <UIImage *>*images;
@property (nonatomic,strong) NSMutableArray <NSData *>*imageDatas;
@property (nonatomic,strong) NSMutableArray <NSString *>*imagePaths;
@property (nonatomic, assign) NSInteger textLocation;//这里声明一个全局属性，
@property (nonatomic,assign) AUXFeedBackQuestionType currentQuestionType;
@property (nonatomic,assign) BOOL textViewActive;
@property (weak, nonatomic) IBOutlet UILabel *questionTypeLabel;
@property (weak, nonatomic) IBOutlet UIButton *sbumitButton;
@property (weak, nonatomic) IBOutlet UILabel *numberLabel;
@property (nonatomic,copy)NSString *phoneNumber;

@end

@implementation AUXFeedbackViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShowOrHide:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShowOrHide:) name:UIKeyboardWillHideNotification object:nil];
    if ([AUXUser isBindAccount]) {
        self.phoneTextfiled.text = [AUXUser defaultUser].phone;
        self.phoneNumber = [AUXUser defaultUser].phone;
    }
    self.view.backgroundColor = [UIColor colorWithHexString:@"F7F7F7"];
    self.sbumitButton.layer.masksToBounds = YES;
    self.sbumitButton.layer.cornerRadius = 22;
    self.sbumitButton.layer.borderWidth = 2;
    self.sbumitButton.layer.borderColor = [UIColor colorWithHexString:@"256BBD"].CGColor;
    self.sbumitButton.alpha = 0.3;
    self.sbumitButton.userInteractionEnabled = NO;
    self.currentQuestionType = self.feedBackType;
    if (self.currentQuestionType==AUXFeedBackQuestionTypeOfAccount) {
        self.questionTypeLabel.text = @"账号问题";
    }else if (self.currentQuestionType==AUXFeedBackQuestionTypeOfAddDevice){
        self.questionTypeLabel.text = @"设备添加";
    }else if (self.currentQuestionType==AUXFeedBackQuestionTypeOfDeviceManager){
        self.questionTypeLabel.text = @"设备管理";
    }else if (self.currentQuestionType==AUXFeedBackQuestionTypeOfFunctionAbnormal){
        self.questionTypeLabel.text = @"功能异常";
    }else if (self.currentQuestionType==AUXFeedBackQuestionTypeOfSceneMode){
        self.questionTypeLabel.text = @"场景模式";
    }else if (self.currentQuestionType==AUXFeedBackQuestionTypeOfOtherQuestion){
        self.questionTypeLabel.text = @"其他问题";
    }else{
        self.questionTypeLabel.text = self.typeLabel;
    }
    self.textView.delegate = self;
    self.phoneTextfiled.delegate = self;
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(phoneChanged:)
                                                name:@"UITextFieldTextDidChangeNotification" object:self.phoneTextfiled];
   
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear: YES];
  
}


- (void)dealloc{
     [[NSNotificationCenter defaultCenter]removeObserver:self];
    NSLog(@"控制器被销毁");
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.textView.text.length != 0 && self.currentQuestionType !=0) {
        self.sbumitButton.alpha = 1;
        self.sbumitButton.userInteractionEnabled = YES;
    }else{
        self.sbumitButton.alpha = 0.3;
        self.sbumitButton.userInteractionEnabled = NO;
    }
}

- (void)initSubviews {
    [super initSubviews];
    [self.collectionView registerNib:[UINib nibWithNibName:@"AUXEvalluateIconCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"AUXEvalluateIconCollectionViewCell"];
    [self.collectionView registerNib:[UINib nibWithNibName:@"AUXEvaluateAddIconCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"AUXEvaluateAddIconCollectionViewCell"];
    [self.collectionView setCollectionViewLayout:self.layout animated:YES];
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

- (NSMutableArray<NSData *> *)imageDatas {
    if (!_imageDatas) {
        _imageDatas = [NSMutableArray array];
    }
    return _imageDatas;
}

- (NSMutableArray<NSString *> *)imagePaths {
    if (!_imagePaths) {
        _imagePaths = [NSMutableArray array];
    }
    return _imagePaths;
}

- (UICollectionViewFlowLayout *)layout {
    if (!_layout) {
        _layout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
        
        _layout.headerReferenceSize = CGSizeMake(0, 0);
        
        CGFloat cellWidth = (kAUXScreenWidth - 76) / 4;
        
        _layout.itemSize = CGSizeMake(cellWidth, cellWidth);
        _layout.sectionInset = UIEdgeInsetsMake(0, 0, 12, 0);
        _layout.minimumInteritemSpacing = 3;
    }
    return _layout;
}

#pragma mark UITextViewDelegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    
    self.textViewActive = YES;
    
    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    self.textViewActive = NO;
    if (self.currentQuestionType !=0 && textView.text.length !=0) {
        self.sbumitButton.alpha = 1;
        self.sbumitButton.userInteractionEnabled = YES;
    }else{
        self.sbumitButton.alpha = 0.3;
        self.sbumitButton.userInteractionEnabled = NO;
    }
    if (textView.text.length==0) {
        self.placholderLabel.hidden = NO;
    }else{
        self.placholderLabel.hidden = YES;
    }
}



- (void)textViewDidChange:(UITextView *)textView {
    if (textView.text.length==0) {
        self.placholderLabel.hidden = NO;
    }else{
        self.placholderLabel.hidden = YES;
    }
    if (self.textLocation == -1) {
        NSLog(@"输入不含emoji表情");
        if (textView.text.length > 200) {
            textView.text = [textView.text substringToIndex:200];
        }
    }else {
        NSLog(@"输入含emoji表情");
        //截取emoji表情前
        textView.text = [textView.text substringToIndex:self.textLocation];
    }
    self.numberLabel.text = [NSString stringWithFormat:@"%ld/200",textView.text.length];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        [self.view endEditing:YES];
        return NO;//这里返回NO，就代表return键值失效，即页面上按下return，不会出现换行，如果为yes，则输入页面会换行
    }
    //禁止输入emoji表情
    if ([text isStringWithEmoji]) {
        self.textLocation = range.location;
    }else {
        self.textLocation = -1;
    }
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView{
    self.placholderLabel.hidden = YES;
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
            [self.imageDatas removeObjectAtIndex:index];
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
        [self selectHeaderImage];
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
                    [self.images addObject:image];
                    [self.imageDatas addObject:data];
                    [self.collectionView reloadData];
                });
                
            }
        });
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)selectHeaderImage{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"选择照片" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    @weakify(self);
    [alertController addAction:[UIAlertAction actionWithTitle:@"从相册选择" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        @strongify(self);
        [self selectPhotoFrom:UIImagePickerControllerSourceTypePhotoLibrary];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
#if TARGET_IPHONE_SIMULATOR
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
            [self presentViewController:imagePickerController animated:YES completion:nil];
        }
    }else{
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.sourceType = type;
        imagePickerController.delegate = self;
        [self presentViewController:imagePickerController animated:YES completion:nil];
    }
    

}


- (IBAction)submitAtcion:(id)sender {
    [self.view endEditing:YES];
    if (self.currentQuestionType == 0) {
        [self showErrorViewWithMessage:@"请选择问题分类"];
        return ;
    }
    if (AUXWhtherNullString(self.textView.text)) {
        [self showErrorViewWithMessage:@"请描述您要反馈的问题"];
        return ;
    }
    
    if (self.phoneTextfiled.text.length != 0) {
        if (!AUXCheckNumber(self.phoneTextfiled.text)) {
            [self showErrorViewWithMessage:@"请填写正确的手机号"];
            return ;
        }
    }
    
    [self showLoadingHUD];
    if (self.imageDatas.count != 0) {
        dispatch_group_t group = dispatch_group_create();
        for (NSData *imageData in self.imageDatas) {
            dispatch_group_enter(group);
            [[AUXNetworkManager manager] updatePortrait:imageData progress:^(NSProgress * _Nonnull uploadProgress) {
              
            } completion:^(NSString * _Nullable path, NSError * _Nullable error) {
                dispatch_group_leave(group);
                if (error) {
                    if (error.code == AUXNetworkErrorAccountCacheExpired) {
                        [self alertAccountCacheExpiredMessage];
                        return;
                    }
                    [self showToastshortWithmessageinCenter:@"上传图片失败"];
                } else {
                    [self.imagePaths addObject:path];
                }
            }];
            
        }
        dispatch_group_notify(group, dispatch_get_main_queue(), ^{
            [self requestSaveFeedBackInfo];
        });
    } else {
        [self requestSaveFeedBackInfo];
    }
}

#pragma mark 网络请求
- (void)requestSaveFeedBackInfo {
    NSString *nowTimeInterval = [NSDate cNowTimestamp];
    NSString *messageId = [NSString stringWithFormat:@"%@%@" , [AUXUser defaultUser].uid , nowTimeInterval];
    NSString *sysVersion = [AUXMobileInformationTool deviceVersion];
    NSString *mobileModel = [AUXMobileInformationTool deviceType];
    NSString *appVersion = [AUXMobileInformationTool appVersion];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:@{@"messageId" : messageId ,
                                                                                @"typeValue" : @(self.currentQuestionType) ,
                                                                                @"content" : self.textView.text,
                                                                                @"sysType":@"iOS",
                                                                                @"sysVersion":sysVersion,
                                                                                @"mobileModel":mobileModel,
                                                                                @"appVersion":appVersion,
                                                                                @"sdkVersion":@"",
                                                                                @"typeLabel":self.questionTypeLabel.text,
                                                                                }];
    if (self.imagePaths.count != 0) {
        NSString *imagePath = [self.imagePaths componentsJoinedByString:@","];
        [dict setObject:imagePath forKey:@"img"];
    }
    if (!AUXWhtherNullString(self.typeLabel)) {
        [dict setObject:self.typeLabel forKey:@"typeLabel"];
    }
    [dict setObject:self.phoneTextfiled.text forKey:@"phone"];
    [[AUXNetworkManager manager] saveFeedBackInfo:dict compltion:^(BOOL result, NSError * _Nonnull error) {
        [self hideLoadingHUD];
        if (result) {
            [self showSuccess:@"意见反馈成功" completion:^{
            }];
            
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            [self showToastshortWitherror:error];
        }
    }];
}

#pragma mark 监听键盘的弹出
- (void)keyboardWillShowOrHide:(NSNotification *)notification {
    if (self.textViewActive) {
        return ;
    }
    NSDictionary *dict = notification.userInfo;
    float duration = [[dict objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    CGRect beginRect = [[dict objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    CGRect endRect = [[dict objectForKey:UIKeyboardFrameEndUserInfoKey]CGRectValue];
    float offsety =  endRect.origin.y - beginRect.origin.y ;
    CGRect viewFrame = CGRectMake(0, 0, kAUXScreenWidth, kAUXScreenHeight);
    
    if (offsety < 0) {
        viewFrame.origin.y += offsety;
    }
    
    [UIView animateWithDuration:duration animations:^{
        self.view.frame = viewFrame;
    }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}
#pragma mark  选择问题类型
- (IBAction)questionButtonAction:(UIButton *)sender {
    AUXQuestionTypeViewController *questionTypeViewController = [AUXQuestionTypeViewController instantiateFromStoryboard:kAUXStoryboardNameUserCenter];
    questionTypeViewController.feedBackType = self.currentQuestionType;
    questionTypeViewController.goBlock = ^(NSDictionary * _Nonnull dic) {
        self.currentQuestionType = [dic[@"questType"] integerValue];
        self.questionTypeLabel.text = dic[@"questtionName"];
        self.typeLabel = dic[@"questtionName"];
    };
    [self.navigationController pushViewController:questionTypeViewController animated:YES];
}



#pragma mark  :UITextField输入长度
-(void)phoneChanged:(NSNotification *)obj
{
    
    UITextField *textField = (UITextField *)obj.object;
    NSString *text = textField.text;
    //获取高亮部分
    UITextRange *selectedRange = [textField markedTextRange];
    UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
    if (!position) {
        if (text.length > 11) {
            [self showToastshortWithmessageinCenter:@"手机号不能超过11位"];
            NSRange range = [text rangeOfComposedCharacterSequenceAtIndex:11];
            if (range.length == 1) {
                textField.text = [text substringToIndex:11];
            }else{
                NSRange range = [text rangeOfComposedCharacterSequencesForRange:NSMakeRange(0, 11)];
                textField.text = [text substringWithRange:range];
            }
        }
        self.phoneNumber = textField.text;

    }
}


- (void)textFieldDidBeginEditing:(UITextField *)textField{
    if ([AUXUser isBindAccount]) {
        self.phoneTextfiled.text = self.phoneNumber;
    }
}


- (void)viewDidDisappear:(BOOL)animated{
  
    
}



@end

