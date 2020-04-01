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

#import "AUXAudioControlViewController.h"
#import "AUXDeviceShareQRCodeViewController.h"

#import "AUXChatTableViewCell.h"

#import "AUXChatRecord+CoreDataClass.h"

#import "AUXIFlySpeechResultHandler.h"
#import "AUXDefinitions.h"
#import "AUXNetworkManager.h"
#import "AUXUser.h"
#import "AUXDeviceControlTask.h"


#import <iflyMSC/iflyMSC.h>
#import <MagicalRecord/MagicalRecord.h>
#import <AVFoundation/AVFoundation.h>

@interface AUXAudioControlViewController () <QMUINavigationControllerDelegate, IFlySpeechRecognizerDelegate, IFlySpeechSynthesizerDelegate , UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UIView *tipView;

@property (weak, nonatomic) IBOutlet UIButton *audioButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *audioButtonBottom;
@property (weak, nonatomic) IBOutlet UIImageView *animationImageView;

@property (nonatomic, strong) IFlySpeechRecognizer *speechRecognizer;
@property (nonatomic, strong) IFlySpeechSynthesizer *iFlySpeechSynthesizer;

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@property (nonatomic, strong) NSMutableArray<NSString *> *resultArray;
@property (nonatomic,copy) NSString *result;

@property (nonatomic, strong) NSMutableDictionary<NSString *, AUXDeviceControlQueue *> *controlQueueDict;

@property (nonatomic,copy) NSString *answer;
@property (nonatomic,strong) NSMutableArray<NSNumber *> *cmdTypeList;
@property (nonatomic,strong) NSArray<AUXAnswerAudioDevice *> *deviceList;

@end

@implementation AUXAudioControlViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    [self initIFlyDictation]; //初始化科大讯飞听写功能
    
    [self initIFlySpeechSynthesis]; //初始化科大讯飞语音合成功能
    
    self.resultArray = [[NSMutableArray alloc] init];
    
    self.fetchedResultsController = [AUXChatRecord MR_fetchAllSortedBy:@"date" ascending:YES withPredicate:nil groupBy:nil delegate:self];
    
//    if (@available(iOS 11.0, *)) {
//        [NSLayoutConstraint deactivateConstraints:@[self.audioButtonBottom]];
//
//        NSLayoutConstraint *audioButtonBottom = [NSLayoutConstraint constraintWithItem:self.audioButton attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view.safeAreaLayoutGuide attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
//        [self.view addConstraint:audioButtonBottom];
//    }
    
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    
    switch (status) {
        case AVAuthorizationStatusNotDetermined: {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
                
            }];
        }
            break;
            
        case AVAuthorizationStatusDenied: {
            [self alertWithMessage:@"是否前往设置中打开麦克风使用权限?" confirmTitle:@"打开" confirmBlock:^{
                NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                [[UIApplication sharedApplication] openURL:url];
            } cancelTitle:@"不了" cancelBlock:nil];
        }
            break;
            
        default:
            break;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [self.fetchedResultsController performFetch:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.iFlySpeechSynthesizer stopSpeaking];

}

- (void)initSubviews {
    [super initSubviews];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressAudioButton:)];
    longPress.minimumPressDuration = 0.3;
    [self.audioButton addGestureRecognizer:longPress];
    
    NSMutableArray<UIImage *> *animationImages = [[NSMutableArray alloc] init];
    
    for (int i = 1; i <= 4; i++) {
        NSString *imageName = [NSString stringWithFormat:@"wave%01d", i];
        [animationImages addObject:[UIImage imageNamed:imageName]];
    }
    self.animationImageView.animationImages = animationImages;
    self.animationImageView.hidden = YES;
    self.animationImageView.animationDuration = 1;
}

- (void)dealloc {
    [AUXChatRecord MR_truncateAll];

//    [IFlySpeechSynthesizer destroy];
}

- (NSMutableDictionary<NSString *,AUXDeviceControlQueue *> *)controlQueueDict {
    if (!_controlQueueDict) {
        _controlQueueDict = [[NSMutableDictionary alloc] init];
    }
    return _controlQueueDict;
}

#pragma mark - 科大讯飞功能
- (void)initIFlyDictation {
    self.speechRecognizer = [IFlySpeechRecognizer sharedInstance];
    self.speechRecognizer.delegate = self;
    [self.speechRecognizer setParameter:@"iat" forKey:[IFlySpeechConstant IFLY_DOMAIN]];
    [self.speechRecognizer setParameter:@"iat.pcm" forKey:[IFlySpeechConstant ASR_AUDIO_PATH]];
}

- (void)initIFlySpeechSynthesis {
    //获取语音合成单例
    self.iFlySpeechSynthesizer = [IFlySpeechSynthesizer sharedInstance];
    //设置协议委托对象
    self.iFlySpeechSynthesizer.delegate = self;
    //设置合成参数
    //设置在线工作方式
    [self.iFlySpeechSynthesizer setParameter:[IFlySpeechConstant TYPE_CLOUD]
                                  forKey:[IFlySpeechConstant ENGINE_TYPE]];
    //设置音量，取值范围 0~100
    [self.iFlySpeechSynthesizer setParameter:@"50"
                                  forKey: [IFlySpeechConstant VOLUME]];
    //发音人，默认为”xiaoyan”，可以设置的参数列表可参考“合成发音人列表”
    [self.iFlySpeechSynthesizer setParameter:@" xiaoyan "
                                  forKey: [IFlySpeechConstant VOICE_NAME]];
    //保存合成文件名，如不再需要，设置为nil或者为空表示取消，默认目录位于library/cache下
    [self.iFlySpeechSynthesizer setParameter:@" tts.pcm"
                                  forKey: [IFlySpeechConstant TTS_AUDIO_PATH]];
    //启动合成会话
//    [self.iFlySpeechSynthesizer startSpeaking: @"你好，我是科大讯飞的小燕"];
}

#pragma mark - Actions

- (void)longPressAudioButton:(UILongPressGestureRecognizer *)longPressGesture {
    
    switch (longPressGesture.state) {
        case UIGestureRecognizerStateBegan: {
            AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
            
            if (status == AVAuthorizationStatusDenied) {
                [self alertWithMessage:@"是否前往设置中打开麦克风使用权限?" confirmTitle:@"打开" confirmBlock:^{
                    NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                    [[UIApplication sharedApplication] openURL:url];
                } cancelTitle:@"不了" cancelBlock:nil];
                return;
            }
            
            self.audioButton.selected = YES;
            [self.resultArray removeAllObjects];
            [self.speechRecognizer startListening];
            [self.iFlySpeechSynthesizer stopSpeaking];
        }
            break;
            
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
            self.audioButton.selected = NO;
            [self.speechRecognizer stopListening];
            
            break;
            
        default:
            break;
    }
}

- (void)hideTipView {
    [UIView animateWithDuration:0.25 animations:^{
        self.tipView.alpha = 0.0;
    } completion:^(BOOL finished) {
        self.tipView.hidden = YES;
        self.tipView.alpha = 1.0;
    }];
}

- (void)handleSpeechResults:(NSString *)result {
    
    [self speechAnalyseByServer:result];
    
    [self appendRequest:result];
    
    if (!self.tipView.hidden) {
        [self hideTipView];
    }
}

- (void)appendRequest:(NSString *)request {
    AUXChatRecord *chatRecord = [AUXChatRecord MR_createEntity];
    chatRecord.message = request;
    chatRecord.role = kAUXChatRoleUser;
    chatRecord.date = [NSDate date];
}

- (void)appendAnswer:(NSString *)answer {
    AUXChatRecord *chatRecord = [AUXChatRecord MR_createEntity];
    chatRecord.message = answer;
    chatRecord.role = kAUXChatRoleAI;
    chatRecord.date = [NSDate date];
}

- (void)speechAnalyseByServer:(NSString *)speech {
    AUXUser *user = [AUXUser defaultUser];
    
    [[AUXNetworkManager manager] speechAnalyseWithUid:user.uid speech:speech deviceList:[user convertToAudioDeviceList] completion:^(NSString * _Nullable answer, NSMutableArray<NSNumber *> * _Nonnull cmdTypeList, NSArray<AUXAnswerAudioDevice *> * _Nullable deviceList, NSError * _Nullable error) {
        if (!error) {
            
            [self.iFlySpeechSynthesizer startSpeaking:answer];
            [self appendAnswer:answer];
            
            self.answer = answer;
            self.cmdTypeList = cmdTypeList;
            self.deviceList = deviceList;
        }
    }];
    
}

- (void)responseFromAIWithAnswer:(NSString *)answer cmdType:(AUXSpeechCmdCode)cmdType audioDeviceList:(NSArray<AUXAnswerAudioDevice *> *)audioDeviceList {
    
    // 控制设备
    if (cmdType == AUXSpeechCmdOthers) {
        [self controlDevice:audioDeviceList];
    } else {    // 分享设备
        if (audioDeviceList.count == 0) {
            return;
        }
        [self shareDeviceWithAnswer:answer audioDeviceList:audioDeviceList];
    }
}

- (void)controlDevice:(NSArray<AUXAnswerAudioDevice *> *)audioDeviceList {
    
    AUXUser *user = [AUXUser defaultUser];
    
    for (AUXAnswerAudioDevice *audioDevice in audioDeviceList) {
        
        AUXDeviceInfo *deviceInfo = [user getDeviceInfoWithMac:audioDevice.mac];
        AUXACDevice *device = [user getSDKDeviceWithMac:audioDevice.mac];
        
        if (!device) {
            continue;
        }
        
        NSString *address = [NSString stringWithFormat:@"%02X", (int)audioDevice.address];
        
        // 单元机，直接控制
        if (deviceInfo.source == AUXDeviceSuitTypeAC) {
            AUXACControl *control = device.controlDic[address];
            [audioDevice updateDeviceControl:control];
            
            WindSpeed windSpeed = [control getWindSpeedWithType:deviceInfo.windGearType];
            
            NSDictionary *statusDict = @{@"onOff": @(control.onOff),
                                         @"airConFunc": @(control.airConFunc),
                                         @"windSpeed": @(windSpeed),
                                         @"turbo": @(control.turbo),
                                         @"silence": @(control.silence)
                                         };
            NSLog(@"语音控制界面 控制设备 mac: %@, address: %@ %@", audioDevice.mac, address, statusDict);
            
            [[AUXACNetwork sharedInstance] sendCommand2Device:device controlInfo:control atAddress:address withType:device.deviceType];
        } else {
            // 现在多联机不查询全部子设备的状态，所以只能拿一个控制对象来用。
            AUXACControl *control = device.controlDic.allValues.firstObject;
            [audioDevice updateDeviceControl:control];
            
            AUXDeviceControlQueue *controlQueue = self.controlQueueDict[deviceInfo.deviceId];
            
            if (!controlQueue) {
                controlQueue = [AUXDeviceControlQueue controlQueueWithDeviceInfo:deviceInfo device:deviceInfo.device];
                [self.controlQueueDict setObject:controlQueue forKey:deviceInfo.deviceId];
            }
            
            AUXDeviceControlTask *task = [AUXDeviceControlTask controlTaskWithAddress:address control:control];
            [controlQueue appendTask:task];
        }
    }
    
    // 启动控制任务
    for (AUXDeviceControlQueue *controlQueue in self.controlQueueDict.allValues) {
        [controlQueue start];
    }
}

- (void)shareDeviceWithAnswer:(NSString *)answer audioDeviceList:(NSArray<AUXAnswerAudioDevice *> *)audioDeviceList {
    
    AUXUser *user = [AUXUser defaultUser];
    
    AUXAnswerAudioDevice *someAudioDevice = audioDeviceList.firstObject;
    
    AUXDeviceShareType deviceShareType;
    
    // 分享给家人
    if (someAudioDevice.cmd_code == AUXSpeechCmdShareDevicesToFamilies) {
        deviceShareType = AUXDeviceShareTypeFamily;
    } else {    // 分享给朋友
        deviceShareType = AUXDeviceShareTypeFriend;
    }
    
    NSMutableArray<NSString *> *deviceIdArray = [[NSMutableArray alloc] init];
    
    for (AUXAnswerAudioDevice *audioDevice in audioDeviceList) {
        AUXDeviceInfo *deviceInfo = [user getDeviceInfoWithMac:audioDevice.mac];
        [deviceIdArray addObject:deviceInfo.deviceId];
    }
    
    [self showLoadingHUD];
    [[AUXNetworkManager manager] getDeviceShareQRContentWithDeviceIdArray:deviceIdArray type:deviceShareType completion:^(NSString * _Nullable qrContent, NSError * _Nonnull error) {
        
        [self hideLoadingHUD];
        
        switch (error.code) {
            case AUXNetworkErrorNone: {
                [self appendAnswer:answer];
                
                AUXDeviceShareQRCodeViewController *qrcodeViewController = [AUXDeviceShareQRCodeViewController instantiateFromStoryboard:kAUXStoryboardNameDeviceControl];
                qrcodeViewController.type = deviceShareType;
                qrcodeViewController.qrContent = qrContent;
                qrcodeViewController.deviceNames = [NSMutableArray array];
                qrcodeViewController.qrCodeStatus = AUXQRCodeStatusOfShareDevice;
                for (AUXAnswerAudioDevice *audioDevice in audioDeviceList) {
                    AUXDeviceInfo *deviceInfo = [user getDeviceInfoWithMac:audioDevice.mac];
                    [qrcodeViewController.deviceNames addObject:deviceInfo.alias];
                }
                
                [self.navigationController pushViewController:qrcodeViewController animated:YES];
            }
                break;
                
            default: {
                NSString *errorMessage = [AUXNetworkManager getErrorMessageWithCode:error.code];
                if (errorMessage) {
                    [self appendAnswer:errorMessage];
                } else {
                    [self appendAnswer:@"生成二维码失败"];
                }
            }
                break;
        }
    }];
}

#pragma mark - QMUINavigationControllerDelegate

- (BOOL)shouldSetStatusBarStyleLight {
    return YES;
}

- (BOOL)preferredNavigationBarHidden {
    return NO;
}

- (UIImage *)navigationBarBackgroundImage {
    return [UIImage qmui_imageWithColor:[UIColor clearColor]];
}

- (UIImage *)navigationBarShadowImage {
    return [UIImage qmui_imageWithColor:[UIColor clearColor]];
}

- (UIColor *)navigationBarTintColor {
    return [UIColor whiteColor];
}

#pragma mark - IFlySpeechRecognizerDelegate

- (void)onResults:(NSArray *)results isLast:(BOOL)isLast {
    NSLog(@"语音识别结果 isLast: %d, results: %@", isLast, results);
    
    NSMutableString *result = [[NSMutableString alloc] init];
    NSDictionary *dic = [results objectAtIndex:0];
    for (NSString *key in dic){
        [result appendFormat:@"%@", key];
    }
    
    NSLog(@"语音合并结果: %@", result);
    
    if (!isLast) {
        [self.resultArray addObject:result];
    } else {
        
        NSString *result = [AUXIFlySpeechResultHandler analyseResults:self.resultArray];
        
        NSLog(@"语音提取结果: %@", result);
        
        if (result.length == 0) {
            result = @"当前未说话";
            return;
        }
        
        self.result = result;
        [self handleSpeechResults:result];
    }
}

- (void)onError:(IFlySpeechError *)errorCode {
    NSLog(@"语音识别出错 code: %d, type: %d, discription: %@", errorCode.errorCode, errorCode.errorType, errorCode.errorDesc);
}

- (void)onVolumeChanged:(int)volume {
    //NSLog(@"当前音量: %d", volume);
}

- (void)onBeginOfSpeech {
    NSLog(@"语音识别开始");
    self.animationImageView.hidden = NO;
    [self.animationImageView startAnimating];
}

- (void)onEndOfSpeech {
    NSLog(@"语音识别结束");
    self.animationImageView.hidden = YES;
    [self.animationImageView stopAnimating];
}

- (void)onCancel {
    NSLog(@"语音识别取消");
}

#pragma mark - IFlySpeechSynthesizerDelegate协议实现
//合成结束
- (void) onCompleted:(IFlySpeechError *) error {
    NSLog(@"语音和成错误:%@" , error);
}

//合成开始
- (void) onSpeakBegin {
    NSLog(@"开始语音合成");
}

//合成缓冲进度
- (void) onBufferProgress:(int) progress message:(NSString *)msg {
    NSLog(@"合成缓冲进度%d /n 合成数据%@" , progress , msg);
}

//合成播放进度
- (void) onSpeakProgress:(int) progress beginPos:(int)beginPos endPos:(int)endPos {
    
    NSLog(@"合成播放进度 %d , 当前播放开始地址 %d ,结束地址%d" , progress , beginPos
           , endPos);
    
    if (progress == 100 ) {
        
        [self responseFromAIWithAnswer:self.answer cmdType:[self.cmdTypeList.firstObject integerValue]  audioDeviceList:self.deviceList];
    }
}

#pragma mark - UITableViewDelegate & UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.fetchedResultsController.fetchedObjects count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *rightAlignmentIdentifier = @"rightAlignmentCell";
    static NSString *leftAlignmentIdentifier = @"leftAlignmentCell";
    
    AUXChatTableViewCell *cell;
    
    AUXChatRecord *chatRecord = self.fetchedResultsController.fetchedObjects[indexPath.row];
    
    if (chatRecord.role == kAUXChatRoleUser) {
        cell = [tableView dequeueReusableCellWithIdentifier:rightAlignmentIdentifier];
        cell.titleLabel.text = [NSString stringWithFormat:@"“%@”", chatRecord.message];
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:leftAlignmentIdentifier];
        cell.titleLabel.text = chatRecord.message;
    }
    
    return cell;
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    switch (type) {
        case NSFetchedResultsChangeInsert: {
            [self.tableView reloadData];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.tableView scrollToRowAtIndexPath:newIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
            });
        }
            break;
            
        default:
            break;
    }
}

@end
