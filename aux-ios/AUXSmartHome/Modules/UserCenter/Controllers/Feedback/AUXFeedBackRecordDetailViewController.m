//
//  AUXFeedBackRecordDetailViewController.m
//  AUXSmartHome
//
//  Created by AUX on 2019/4/22.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//
//UITextField *tt;
//tt.placeholder
#import "AUXFeedBackRecordDetailViewController.h"
#import "CSBigView.h"
#import "AUXNetworkManager.h"
#import "AUXFeedBackDetailfirstTableViewCell.h"
#import "AUXFirstCellModel.h"
#import "UIColor+AUXCustom.h"
#import "NSDate+AUXCustom.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "AUXSecondTableViewCell.h"
#import "AUXThirdTableViewCell.h"
#import "MJRefresh.h"
#import "NSString+AUXCustom.h"
#import "AUXMobileInformationTool.h"



@interface AUXFeedBackRecordDetailViewController ()<UITableViewDataSource,UITableViewDelegate,UITextViewDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate>
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableviewBottomConstraint;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, assign) CGFloat nowHeight;
@property (nonatomic, strong) UIImageView *photoImageView;
@property (nonatomic, strong) CSBigView *bigImageView;
@property (nonatomic, strong) UIImage *photoImage;
@property (nonatomic, strong) NSIndexPath *selectIndex;
@property (weak, nonatomic) IBOutlet UIView *BottomView;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UILabel *placeholderLabel;
@property (nonatomic,copy) NSString *tmpStr;
@property (nonatomic,assign)CGFloat cellHeight;
@property (nonatomic,strong) NSMutableArray <UIImage *>*images;
@property (nonatomic,strong) NSMutableArray <NSData *>*imageDatas;
@property (nonatomic,strong) NSMutableArray <NSString *>*imagePaths;
@property (nonatomic,strong) AUXThirdTableViewCell *lastcell;
@property (nonatomic,copy) NSString *refershType;
@property (nonatomic, assign) NSInteger textLocation;//这里声明一个全局属性，
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottoviewlayoutConstraint;


@end

@implementation AUXFeedBackRecordDetailViewController
{
    NSInteger  _currentpage;
    NSInteger  _totalPages;
    NSInteger  _totalcount;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController.navigationBar setTranslucent:NO];
    _currentpage =0;
    self.refershType = @"sender";
    self.title = self.feedbackListModel.typeLabel;
    _dataArray = [NSMutableArray arrayWithCapacity:0];
    _tableView.backgroundColor =  [UIColor colorWithHexString:@"F7F7F7"];
    [self.tableView registerNib:[UINib nibWithNibName:@"AUXFeedBackDetailfirstTableViewCell" bundle:nil] forCellReuseIdentifier:@"AUXFeedBackDetailfirstTableViewCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"AUXSecondTableViewCell" bundle:nil] forCellReuseIdentifier:@"AUXSecondTableViewCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"AUXThirdTableViewCell" bundle:nil] forCellReuseIdentifier:@"AUXThirdTableViewCell"];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self refreshData];
    }];
    self.tableView.showsVerticalScrollIndicator = NO;
    _bigImageView = [[CSBigView alloc] init];
    _bigImageView.frame = [UIScreen mainScreen].bounds;
    self.textView.delegate = self;
    _tableView.separatorColor = [UIColor clearColor];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [self getData];
    
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
    [self.navigationController.navigationBar setTranslucent:NO];
    
}


#pragma mark 下拉加载更多
- (void)refreshData {
    _currentpage ++;
    if (_currentpage*20 > _totalcount) {
        [self showToastshortWithmessageinCenter:@"数据已经加载完啦"];
        [self.tableView.mj_header endRefreshing];
        return;
    }
    if (self.dataArray.count!=0) {
        [self.dataArray removeObjectAtIndex:0];
    }
    [self getData];
}

- (NSMutableArray *)dataArray{
    if (!_dataArray) {
        self.dataArray = [[NSMutableArray alloc]init];
    }
    return _dataArray;
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

- (void)getData{
    NSLog(@"%ld",_currentpage);
    [[AUXNetworkManager manager]getFeedbackDetailByfeedbackId:self.feedbackListModel.feedbackId page:_currentpage size:20 compltion:^(NSDictionary * _Nonnull dic, NSError * _Nonnull error) {
        if (error ==nil) {
            if ([dic[@"code"] integerValue]==200) {
                AUXFirstCellModel *firstCellModel = [[AUXFirstCellModel alloc]init];
                NSDictionary *fistCellDic = dic[@"data"][@"feedbackNewCreateVo"];
                [firstCellModel yy_modelSetWithDictionary:fistCellDic];
                NSDictionary *seccondDic = dic[@"data"][@"pageContent"];
                NSArray *tmpArray = seccondDic[@"content"];
                self->_totalPages = [seccondDic[@"page"] integerValue];
                self->_totalcount = [seccondDic[@"total"] integerValue];
                if (self->_currentpage >0) {
                    self.dataArray  = [[self.dataArray reverseObjectEnumerator] allObjects].mutableCopy;
                }
                if (tmpArray.count >0) {
                    for (NSDictionary *tmp in tmpArray) {
                        AUXFirstCellModel *firstCellModel = [[AUXFirstCellModel alloc]init];
                        [firstCellModel yy_modelSetWithDictionary:tmp];
                        [self.dataArray addObject:firstCellModel];
                    }
                }
                
                self.dataArray  = [[self.dataArray reverseObjectEnumerator] allObjects].mutableCopy;
                if (firstCellModel !=nil) {
                    [self.dataArray insertObject:firstCellModel atIndex:0];
                }
                [self.tableView reloadData];
                [self.tableView.mj_header endRefreshing];
                [self.tableView.mj_footer endRefreshing];
                
                if ([self.refershType isEqualToString:@"sender"]) {
                    [self.tableView reloadData];
                    [self scrollToBottom];
                    self.refershType = @"";
                }
                
                
            }else{
                [self showToastshortWithmessageinCenter:@"获取列表失败"];
            }
        }else{
            [self showToastshortWitherror:error];
        }
    }];
}


-(void)keyboardWillShow:(NSNotification *)aNotification{

    //获取键盘的高度
    NSDictionary *userInfo = [aNotification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    int height = keyboardRect.size.height;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.000003 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
       NSString *phoneType = [AUXMobileInformationTool deviceType];
        if ([phoneType isEqualToString:@"iPhone X"]||[phoneType isEqualToString:@"iPhone XR"]||[phoneType isEqualToString:@"iPhone XS"]||[phoneType isEqualToString:@"iPhone XS Max"]) {
            self.bottoviewlayoutConstraint.constant = height-34;
        }else{
            self.bottoviewlayoutConstraint.constant = height;
        }
        [self.view layoutIfNeeded];
    });
}

- (void)keyboardWillHide:(NSNotification *)aNotification {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.000001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.bottoviewlayoutConstraint.constant = 0;
        [self.view layoutIfNeeded];
    });
   
    
}


#pragma mark -
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row ==0) {
        AUXFirstCellModel *model = self.dataArray.firstObject;
        AUXFeedBackDetailfirstTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AUXFeedBackDetailfirstTableViewCell" forIndexPath:indexPath];
        cell.model = model;
        self.cellHeight = cell.cellHeight;
        cell.contentView.backgroundColor = [UIColor clearColor];
        cell.backgroundColor = [UIColor colorWithHexString:@"F7F7F7"];
        cell.didselect = ^(NSInteger tagValue) {
            NSInteger index = tagValue-1000;
            [self->_bigImageView.bigImageView sd_setImageWithURL:model.imageUrls[index] placeholderImage:nil];
            self->_bigImageView.show = YES;
        };
        return cell;
    }else{
        AUXFirstCellModel *model = self.dataArray[indexPath.row];
        if (model.content.length==0 && model.imageUrls.count !=0) {
            AUXThirdTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AUXThirdTableViewCell" forIndexPath:indexPath];
            if (indexPath.row < self.dataArray.count && indexPath.row > 1) {
                AUXFirstCellModel *model1 = self.dataArray[indexPath.row-1];
                AUXFirstCellModel *model2 = self.dataArray[indexPath.row ];
                
                NSLog(@"%@----%@",[NSDate cStringFromTimestampyyyMMddHH:[NSString stringWithFormat:@"%ld",(long)model1.createdAt]],[NSDate cStringFromTimestampyyyMMddHH:[NSString stringWithFormat:@"%ld",(long)model2.createdAt]]);
                
                
                
                
                if ([[NSDate cStringFromTimestampyyyMMddHH:[NSString stringWithFormat:@"%ld",(long)model1.createdAt]] isEqualToString:[NSDate cStringFromTimestampyyyMMddHH:[NSString stringWithFormat:@"%ld",(long)model2.createdAt]]]) {
                    model.timeLabelHidden = YES;
                }else{
                    model.timeLabelHidden = NO;
                }
            }else{
                model.timeLabelHidden = NO;
            }
            if (indexPath.row < self.dataArray.count && indexPath.row > 1) {
                AUXFirstCellModel *model1 = self.dataArray[indexPath.row-1];
                AUXFirstCellModel *model2 = self.dataArray[indexPath.row];
                if ([[NSDate cStringFromTimestampyyyMMdd:[NSString stringWithFormat:@"%ld",(long)model1.createdAt]] isEqualToString:[NSDate cStringFromTimestampyyyMMdd:[NSString stringWithFormat:@"%ld",(long)model2.createdAt]]]) {
                    model.isTheSametime = YES;
                }else{
                    model.isTheSametime = NO;
                }
            }else{
                model.isTheSametime = NO;
            }
            
            cell.firstCellModel = model;
            cell.backView.backgroundColor = [UIColor colorWithHexString:@"F7F7F7"];
            if ([model.imageUrls.firstObject isEqualToString:@"AAA"]) {
                self.lastcell = cell;
            }
            return cell;
        }else{
            AUXSecondTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AUXSecondTableViewCell" forIndexPath:indexPath];
            if (indexPath.row < self.dataArray.count && indexPath.row > 1) {
                AUXFirstCellModel *model1 = self.dataArray[indexPath.row-1];
                AUXFirstCellModel *model2 = self.dataArray[indexPath.row ];
      if ([[NSDate cStringFromTimestampyyyMMddHH:[NSString stringWithFormat:@"%ld",(long)model1.createdAt]] isEqualToString:[NSDate cStringFromTimestampyyyMMddHH:[NSString stringWithFormat:@"%ld",(long)model2.createdAt]]]) {
          model.timeLabelHidden = YES;
                }else{
                    model.timeLabelHidden = NO;
                }
            }else{
                model.timeLabelHidden = NO;
            }
            
            if (indexPath.row < self.dataArray.count && indexPath.row > 1) {
                AUXFirstCellModel *model1 = self.dataArray[indexPath.row-1];
                AUXFirstCellModel *model2 = self.dataArray[indexPath.row];
                if ([[NSDate cStringFromTimestampyyyMMdd:[NSString stringWithFormat:@"%ld",(long)model1.createdAt]] isEqualToString:[NSDate cStringFromTimestampyyyMMdd:[NSString stringWithFormat:@"%ld",(long)model2.createdAt]]]) {
                    model.isTheSametime = YES;
                }else{
                    model.isTheSametime = NO;
                }
            }else{
                model.isTheSametime = NO;
            }
            
            
           
            
            cell.firstCellModel = model;
            self.cellHeight = cell.cellHeight;
            cell.backgroundColor = [UIColor colorWithHexString:@"F7F7F7"];
            return cell;
        }
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    AUXFirstCellModel *model = self.dataArray[indexPath.row];
    if (model.content.length==0 && model.imageUrls.count !=0) {
        [_bigImageView.bigImageView sd_setImageWithURL:model.imageUrls.firstObject placeholderImage:nil];
        _bigImageView.show = YES;
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row==0) {
        return self.cellHeight;
    }else{
        AUXFirstCellModel *model = self.dataArray[indexPath.row];
        if (model.content.length==0 && model.imageUrls.count !=0) {
            return 134;
        }else{
            return self.cellHeight;
        }
    }
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.1;
}


#pragma mark  选择图片
- (IBAction)selectImageButton:(id)sender {
    [self alertSheet];
}




#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    [self showImageWithArray:@[@"AAA",image]];
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
            @weakify(self)
            dispatch_async(dispatch_get_main_queue(), ^{
                @strongify(self)
                UIImage *image = [UIImage imageWithData:data];
                [self.images addObject:image];
                [self.imageDatas addObject:data];
                if (self.imageDatas.count != 0) {
                    for (NSData *imageData in self.imageDatas) {
                        [[AUXNetworkManager manager] updatePortrait:imageData progress:^(NSProgress * _Nonnull uploadProgress) {
                            
                            NSString *progressStr = [NSString stringWithFormat:@"%.2f %%",uploadProgress.fractionCompleted *100] ;
                            
                            [self refreshUIWith:progressStr];
                        } completion:^(NSString * _Nullable path, NSError * _Nullable error) {
                            if (error) {
                                [self showToastshortWitherror:error];
                            } else {
                                [self.imagePaths addObject:path];
                                if (self.imagePaths.count != 0) {
                                    NSString *imagePath = [self.imagePaths componentsJoinedByString:@","];
                                    NSDictionary *dic = @{ @"content":@"",
                                                           @"feedbackId":self.feedbackListModel.feedbackId,
                                                           @"imageFiles":@[],
                                                           @"imageUrls":@[imagePath]
                                                           };
                                    [self replyWithDic:dic];
                                }
                            }
                        }];
                    }
                }
            });
        });
        
    }];
    
}

- (void)refreshUIWith:(NSString*)str{
    dispatch_sync(dispatch_get_main_queue(), ^{
        self.lastcell.progressLabel.text = [NSString stringWithFormat:@"%@",str];
    });
}



- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    
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


#pragma mark  发送信息
- (IBAction)sendMassageButton:(id)sender {
    if (_textView.text.length==0) {
        [self showToastshortWithmessageinCenter:@"请输入发送内容"];
        return;
    }
    
    NSDictionary *dic = @{ @"content":_textView.text,
                           @"feedbackId":self.feedbackListModel.feedbackId,
                           @"imageFiles":@[],
                           @"imageUrls":@[]
                           };
    
    [self replyWithDic:dic];
    
    _textView.text = @"";
}


// 滑动的时候回收键盘
- (void)scrollViewWillBeginDragging:(UIScrollView*)scrollView
{
    [self.view endEditing:YES];
}


- (void)textViewDidBeginEditing:(UITextView *)textView{
        self.placeholderLabel.hidden = YES;
}



- (void)textViewDidEndEditing:(UITextView *)textView{
    if (textView.text.length==0) {
         self.placeholderLabel.hidden = NO;
    }else{
         self.placeholderLabel.hidden = YES;
    }
   
}

- (void)replyWithDic:(NSDictionary*)dic{
    [self.dataArray removeAllObjects];
    [self.imagePaths removeAllObjects];
    [self.imageDatas removeAllObjects];
    [self.images removeAllObjects];
    [[AUXNetworkManager manager] postFeedbackReplyWithDic:dic compltion:^(BOOL result, NSError * _Nonnull error) {
        if (error==nil) {
            [self.dataArray removeAllObjects];
            self->_currentpage =0;
            self.refershType = @"sender";
            [self getData];
        }else{
            [self showToastshortWitherror:error];
        }
        
    }];
}


-(void)showImageWithArray:(NSArray*)array{
    AUXFirstCellModel * model = [[AUXFirstCellModel alloc] init];
    model.content = @"";
    model.userReply = 1;
    model.imageUrls = array;
    model.createdAt = [[NSDate cNowTimestamp] intValue];
    [_dataArray addObject:model];
    if (self.dataArray.count !=0) {
        [_tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForItem:_dataArray.count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:_dataArray.count - 1 inSection:0] animated:YES scrollPosition:UITableViewScrollPositionMiddle];
    }
    
}
- (void)viewWillDisappear:(BOOL)animated{
    [self.navigationController.navigationBar setTranslucent:YES];
    
}

// 滚动到最底部
-(void)scrollToBottom {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.000001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self.dataArray.count > 0) {
            if ([self.tableView numberOfRowsInSection:0] > 0) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:([self.tableView numberOfRowsInSection:0]-1) inSection:0];
                [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
            }
        }
    });
}

- (void)textViewDidChange:(UITextView *)textView {
    if (textView.text.length==0) {
        self.placeholderLabel.hidden = NO;
    }else{
        self.placeholderLabel.hidden = YES;
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
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if (![text isEqualToString:@""]) {
    }
    if ([text isEqualToString:@""] && range.location == 0 && range.length == 1) {
        
    }
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
    NSLog(@"%@----%ld",textView.text,textView.text.length);
    return YES;
}


@end




