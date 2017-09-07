//
//  CameraFPVViewController.m
//  DJISdkDemo
//
//  Copyright © 2015 DJI. All rights reserved.
//
/**
 *  This file demonstrates how to receive the video data from DJICamera and display the video using VideoPreviewer.
 */
#import "CameraFPVViewController.h"
#import "DemoUtility.h"
#import "VideoPreviewerSDKAdapter.h"
#import <VideoPreviewer/VideoPreviewer.h>
#import <DJISDK/DJISDK.h>
#import <DJISDK/DJIFlightController.h>
#import <ReplayKit/ReplayKit.h>


#define catchViewWidth 262.4
#define catchViewHeight 147.6
#define topoffset 137.5

@interface CameraFPVViewController () <DJICameraDelegate>

@property (weak, nonatomic) IBOutlet UISwitch *controlbyhand;
@property (weak, nonatomic) IBOutlet UILabel *controlbyhandLabel;


@property int controlmode;
@property (nonatomic) BOOL isInRecordVideoMode;
@property (nonatomic) BOOL isRecordingVideo;
@property (nonatomic) NSUInteger recordingTime;


@property(nonatomic, weak) IBOutlet UIView* fpvView;//视频显示位置
@property (weak, nonatomic) IBOutlet UIView *fpvTemView;
@property (weak, nonatomic) IBOutlet UIImageView *PhotoView;
@property(nonatomic, weak) IBOutlet UIView* catchView;//抓取框
@property (weak, nonatomic) IBOutlet UIView *catchPhotoView1;
@property (weak, nonatomic) IBOutlet UIView *catchPhotoView2;
@property (weak, nonatomic) IBOutlet UIView *catchPhotoView3;

//- (IBAction)confirmButton:(UIButton *)sender;
//- (IBAction)cancelButton:(UIButton *)sender;
- (IBAction)sendDataButton:(id)sender;
- (IBAction)deleteDataButton:(id)sender;
- (IBAction)sendDataButton1:(id)sender;
- (IBAction)deleteDataButton1:(id)sender;
- (IBAction)sendDataButton2:(id)sender;
- (IBAction)deleteDataButton2:(id)sender;
- (IBAction)changecontrol:(id)sender;


@property (weak, nonatomic) IBOutlet UIButton *sendDataButtonView2;
@property (weak, nonatomic) IBOutlet UIButton *deleteDataButtonView2;
@property (weak, nonatomic) IBOutlet UIButton *sendDataButtonView;
@property (weak, nonatomic) IBOutlet UIButton *deleteDataButtonView;
@property (weak, nonatomic) IBOutlet UIButton *sendDataButtonView1;
@property (weak, nonatomic) IBOutlet UIButton *deleteDataButtonView1;


@property (weak, nonatomic) IBOutlet UIImageView *Photo1View;
@property (weak, nonatomic) IBOutlet UIImageView *Photo2View;
@property (weak, nonatomic) IBOutlet UIImageView *Photo3View;


@property (weak, nonatomic) IBOutlet UISwitch *fpvTemEnableSwitch;
@property (weak, nonatomic) IBOutlet UILabel *fpvTemperatureData;

@property(nonatomic, assign) BOOL needToSetMode;

@property(nonatomic) VideoPreviewerSDKAdapter *previewerAdapter;

@end

@implementation CameraFPVViewController{
    NSArray *fpvViewLandConstraints;//视频显示位置的横向约束
    NSArray *buttonViewLandConstraints;//按钮显示位置的横向约束
    NSArray *rootViewLandscapeConstraints;
    NSArray *photoViewLandscapeConstraints;
    BOOL isShowingPortrait;
    BOOL selectPhoto;
    __weak IBOutlet UIView *fpv_View;
    __weak IBOutlet UIView *button_View;
    __weak IBOutlet UIImageView *photo_View;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _touchFlag = TRUE;
    selectPhoto = TRUE;
    _controlmode = 1;
    
    //初始化删除按钮不可按
    self.deleteDataButtonView.enabled=FALSE;
    self.deleteDataButtonView1.enabled=FALSE;
    self.deleteDataButtonView2.enabled=FALSE;
    
    //初始化发送按钮不可按
    self.sendDataButtonView.enabled=FALSE;
    self.sendDataButtonView1.enabled=FALSE;
    self.sendDataButtonView2.enabled=FALSE;
    
    DJICamera* camera = [DemoComponentHelper fetchCamera];
    if (camera) {
        camera.delegate = self;
    }
    //    DJIFlightController *controller = [DemoComponentHelper fetchFlightController];
    //    if (controller){
    //        controller.delegate = self;
    //    }
    //
    //    _fc = [DemoComponentHelper fetchFlightController];
    //    [self flightController:_fc didReceiveDataFromOnboardSDKDevice:_data];
    
    self.needToSetMode = YES;
    
    [[VideoPreviewer instance] start];
    
    //    [self setupLandscapeConstraints];
    UIInterfaceOrientation currOrientation = [[UIApplication sharedApplication]statusBarOrientation];
    isShowingPortrait = UIInterfaceOrientationIsPortrait(currOrientation);
    
    self.previewerAdapter = [VideoPreviewerSDKAdapter adapterWithDefaultSettings];
    [self willAnimateRotationToInterfaceOrientation:currOrientation duration:0.0f];
    [self.previewerAdapter start];
    
}

-(void) viewWillAppear:(BOOL)animated//当场景进入的时候，自动显示视频
{
    [super viewWillAppear:animated];
    UIInterfaceOrientation currOrientation = [[UIApplication sharedApplication]statusBarOrientation];//找到当前设备的方向
    BOOL currIsPortrait = UIInterfaceOrientationIsPortrait(currOrientation);//当前设备方向是否为纵向
    if((isShowingPortrait && !currIsPortrait) || (!isShowingPortrait && currIsPortrait)){//控制器的上一个方向是否与当前方向不同
        [self willAnimateRotationToInterfaceOrientation:currOrientation duration:0.0f];
    }
    
    [[VideoPreviewer instance] setView:self.fpvView];
    
    //初始化手动模式
    _controlbyhand.selected = false;
    _controlbyhandLabel.text = @"手动模式";
    
    _catchView.layer.borderWidth = 1;
    _catchPhotoView1.layer.borderWidth = 1;
    _catchPhotoView2.layer.borderWidth = 1;
    _catchPhotoView3.layer.borderWidth = 1;

    _catchView.layer.borderColor = [[UIColor whiteColor]CGColor];
    _catchPhotoView1.layer.borderColor=[[UIColor whiteColor]CGColor];
    _catchPhotoView2.layer.borderColor=[[UIColor whiteColor]CGColor];
    _catchPhotoView3.layer.borderColor=[[UIColor whiteColor]CGColor];
    
    _Photo1View.layer.borderWidth=1;
    _Photo2View.layer.borderWidth=1;
    _Photo3View.layer.borderWidth=1;
    
    _Photo1View.layer.borderColor=[[UIColor blueColor]CGColor];
    _Photo2View.layer.borderColor=[[UIColor blueColor]CGColor];
    _Photo3View.layer.borderColor=[[UIColor blueColor]CGColor];
    
    NSLog(@"catchView frame: %@", NSStringFromCGRect(_catchView.frame));
    [self updateThermalCameraUI];
    
    
    
    //    [sendData sendDataToOnboardSDKDevice:testData withCompletion:nil];
    [self setVideoPreview];
    
    // set delegate to render camera's video feed into the view
    __weak DJICamera* camera = [DemoComponentHelper fetchCamera];
    if (camera) {
        [camera setDelegate:self];
    }
    
    self.isInRecordVideoMode = NO;
    self.isRecordingVideo = NO;
    // disable the shoot photo button by default
    [self.startRecordButton setEnabled:NO];
    [self.stopRecordButton setEnabled:NO];
    
    // start to check the pre-condition
    [self getCameraMode];

}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // Call unSetView during exiting to release the memory.
    // 在退出时调用unSetView释放内存。
    [[VideoPreviewer instance] unSetView];
    
    if (self.previewerAdapter) {
        [self.previewerAdapter stop];
        self.previewerAdapter = nil;
    }
}


/**
 *  VideoPreviewer is used to decode the video data and display the decoded frame on the view. VideoPreviewer provides both software
 *  decoding and hardware decoding. When using hardware decoding, for different products, the decoding protocols are different and the hardware decoding is only supported by some products.
 *  VideoPreviewer用于解码视频数据并在视图上显示解码的帧。 VideoPreviewer提供软件解码和硬件解码。 当使用硬件解码时，对于不同的产品，解码协议是不同的，硬件解码只有部分产品支持。
 */
-(IBAction) onSegmentControlValueChanged:(UISegmentedControl*)sender
{
    [VideoPreviewer instance].enableHardwareDecode = sender.selectedSegmentIndex == 1;
}

- (IBAction)onThermalTemperatureDataSwitchValueChanged:(id)sender {
    DJICamera* camera = [DemoComponentHelper fetchCamera];
    if (camera) {
        DJICameraThermalMeasurementMode mode = ((UISwitch*)sender).on ? DJICameraThermalMeasurementModeSpotMetering : DJICameraThermalMeasurementModeDisabled;
        [camera setThermalMeasurementMode:mode withCompletion:^(NSError * _Nullable error) {
            if (error) {
                ShowResult(@"Failed to set the measurement mode: %@", error.description);
            }
            //ShowResult(@"lalala");
        }];
    }
}

- (void)updateThermalCameraUI {
    DJICamera* camera = [DemoComponentHelper fetchCamera];
    if (camera && [camera isThermalCamera]) {
        [self.fpvTemView setHidden:NO];
        WeakRef(target);
        [camera getThermalMeasurementModeWithCompletion:^(DJICameraThermalMeasurementMode mode, NSError * _Nullable error) {
            WeakReturn(target);
            if (error) {
                ShowResult(@"Failed to get the measurement mode status: %@", error.description);
            }
            else {
                // ShowResult(@"Success to get the measurement mode status: %@", error.description);
                BOOL enabled = mode != DJICameraThermalMeasurementModeDisabled ? YES : NO;
                [target.fpvTemEnableSwitch setOn:enabled];
            }
        }];
    }
    else {
        [self.fpvTemView setHidden:YES];
    }
}

#pragma mark - DJICameraDelegate
/**
 *  DJICamera will send the live stream only when the mode is in DJICameraModeShootPhoto or DJICameraModeRecordVideo. Therefore, in order
 *  to demonstrate the FPV (first person view), we need to switch to mode to one of them.
 */
-(void)camera:(DJICamera *)camera didUpdateSystemState:(DJICameraSystemState *)systemState
{
    if (systemState.mode == DJICameraModePlayback ||
        systemState.mode == DJICameraModeMediaDownload) {
        if (self.needToSetMode) {
            self.needToSetMode = NO;
            WeakRef(obj);
            [camera setMode:DJICameraModeShootPhoto withCompletion:^(NSError * _Nullable error) {
                if (error) {
                    WeakReturn(obj);
                    obj.needToSetMode = YES;
                }
            }];
        }
    }
}

-(void)camera:(DJICamera *)camera didUpdateTemperatureData:(float)temperature {
    self.fpvTemperatureData.text = [NSString stringWithFormat:@"%f", temperature];
}

//手指触碰函数
-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint pt = [touch locationInView:self.view];
    
    _x_end = pt.x;
    _y_end = pt.y;
    
    if(_x_end < 20){//如果在视频的左侧
        _x_end = 20;
    } else if (_x_end > 807.2) {//在视频的右侧
        _x_end = 807.2;
    }
    if (_y_end <305){//在视频的上方
        _y_end = 306;
    }else if (_y_end > 747.8) {//在视频的下方
        _y_end = 747.8;
    }
    NSLog(@"end:\tx:%lf\ty:%lf",_x_end,_y_end);
    
    _height = _y_end - _y_begin;
    _width = _x_end - _x_begin;
    
    if (_touchFlag){
        self.catchView.frame=CGRectMake(_x_begin, _y_begin, _width, _height);
        
        [self updateThermalCameraUI];
        
    }
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint pt = [touch locationInView:self.view];
    _x_begin = pt.x;
    _y_begin = pt.y;
    if(_x_begin < 20){//如果在视频的左侧
        _x_begin = 20;
    } else if (_x_begin > 807.2) {//在视频的右侧
        _x_begin = 807.2;
    }
    if (_y_begin <305){//在视频的上方
        _y_begin = 306;
    }else if (_y_begin > 747.8) {//在视频的下方
        _y_begin = 747.8;
    }
    NSLog(@"begin:\tx:%lf\ty:%lf",_x_begin,_y_begin);
}

//允许截屏的范围为x:20~807.2
//             y:305~747.8
-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint pt = [touch locationInView:self.view];
    
    _x_moved = pt.x;
    _y_moved = pt.y;
    
    if (_x_moved  < 20) {
        _x_moved = 20;
    } else if (_x_moved > 807.2){
        _x_moved = 807.2;
    }
    if (_y_moved < 305){
        _y_moved = 305;
    } else if (_y_moved > 747.8) {
        _y_moved = 747.8;
    }
    NSLog(@"moved:\tx:%lf\ty:%lf",_x_moved,_y_moved);
    _height = _y_moved - _y_begin;
    _width = _x_moved - _x_begin;
    if (_touchFlag){//当可以画的时候
        self.catchView.frame=CGRectMake(_x_begin, _y_begin, _width, _height);
        [self updateThermalCameraUI];
    }
}
//截图函数
- (UIImage *)getImageViewWithView:(UIView *)view
{
    UIGraphicsBeginImageContext(view.frame.size);
    [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:NO];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

//截取图片
//允许截屏的范围为x:20~807.2
//             y:305~747.8

- (void)shotPhotoWithSelect:(int)select{
    if (select == 1){
        self.Photo1View.image = [self getImageViewWithView:fpv_View];
    } else  if (select == 2){
        self.Photo2View.image = [self getImageViewWithView:fpv_View];
    } else if (select ==3) {
        self.Photo3View.image = [self getImageViewWithView:fpv_View];
    }
}
//删除图片
- (void)deletePhotoWithSelect:(int)select {
    if (select == 1){
        self.Photo1View.image=nil;
    } else if (select == 2) {
        self.Photo2View.image=nil;
    } else if (select == 3) {
        self.Photo3View.image=nil;
    }
}

//发送数据函数
- (void)sendDateWithX1:(float) persent_x1
                    Y1:(float)persent_y1
                    X2:(float)persent_x2
                    Y2:(float)persent_y2
{
    DJIFlightController *sendData;
    NSString *locationData;
    locationData = [[NSString alloc] initWithString:[NSString stringWithFormat:@"1:%lf,%lf,%lf,%lf,",persent_x1,persent_y1,persent_x2,persent_y2]];
    NSLog(@"%@",locationData);
    NSData *testData = [locationData dataUsingEncoding: NSUTF8StringEncoding];
    Byte *testByte = (Byte *)[testData bytes];
    DJIFlightController* fc = [DemoComponentHelper fetchFlightController];
    [fc sendDataToOnboardSDKDevice:testData withCompletion:^(NSError * _Nullable error) {
        if (error) {
            ShowResult(@"sendData Error:%@", error.localizedDescription);
        }
        else
        {
            ShowResult(@"sendData Succeeded.");
        }
    }];
}

//发送函数--实现目标的跟踪与删除
//
- (void)sendDataWithX1:(float)persent_x1
                    Y1:(float)persent_y1
                    X2:(float)persent_x2
                    Y2:(float)persent_y2
                    ID:(int)searchID
                  flag:(BOOL)flag
{
    DJIFlightController *sendData;
    NSString *locationData;
    if (flag){//true的时候表示传递跟踪目标
        locationData = [[NSString alloc] initWithString:[NSString stringWithFormat:@"1:%d,%lf,%lf,%lf,%lf,",searchID,persent_x1,persent_y1,persent_x2,persent_y2]];
    } else {
        locationData = [[NSString alloc] initWithString:[NSString stringWithFormat:@"0:%d,",searchID]];
    }
    
    NSLog(@"%@",locationData);
    NSData *testData = [locationData dataUsingEncoding: NSUTF8StringEncoding];
    Byte *testByte = (Byte *)[testData bytes];
    DJIFlightController* fc = [DemoComponentHelper fetchFlightController];
    [fc sendDataToOnboardSDKDevice:testData withCompletion:^(NSError * _Nullable error) {
        if (error) {
            ShowResult(@"sendData Error:%@", error.localizedDescription);
        }
        else
        {
            ShowResult(@"sendData Succeeded.");
        }
    }];
}
//发送函数--实现手动与自动的切换
- (void)sendDatawithNum
{
    DJIFlightController *sendData;
    NSString *locationData;
    
    locationData = @"2";
    NSData *testData = [locationData dataUsingEncoding: NSUTF8StringEncoding];
    Byte *testByte = (Byte *)[testData bytes];
    DJIFlightController* fc = [DemoComponentHelper fetchFlightController];
    [fc sendDataToOnboardSDKDevice:testData withCompletion:^(NSError * _Nullable error) {
        if (error) {
            ShowResult(@"sendData Error:%@", error.localizedDescription);
        }
        else
        {
            ShowResult(@"sendData Succeeded.");
        }
    }];

}


//按钮发送1
- (IBAction)sendDataButton:(id)sender {
    NSLog(@"lalalala");
    float real_x1;float real_y1;
    float real_x2;float real_y2;
    float end_width;float end_height;
    float persent_x1;float persent_x2;
    float persent_y1;float persent_y2;
    DJIFlightController *sendData;
    NSString *locationData;
    //(real_x1,real_y1)为左上角的点
    //(real_x2,real_y2)为右下角的点
    if (_x_begin>_x_end) {
        real_x1 = _x_end;
        real_x2 = _x_begin;
    } else {
        real_x1 = _x_begin;
        real_x2 = _x_end;
    }
    if (_y_begin>_y_end) {
        real_y2 = _y_begin;
        real_y1 = _y_end;
    } else {
        real_y2 = _y_end;
        real_y1 = _y_begin;
    }
    persent_y1 = (real_y1 - 305)/442.8;
    persent_y2 = (real_y2 - 305)/442.8;
    persent_x1 = (real_x1 - 20)/787.8;
    persent_x2 = (real_x2 - 20)/787.8;
    //             x:20~400         y:  71.25~285
    //             x:427.2~807.2    y:  71.5~285
    
    
    float photox,photoy,photowidth,photoheight;
    photox = catchViewWidth*persent_x1 + 20;
    photoy =catchViewHeight*persent_y1 + topoffset;
    photowidth=(persent_x2-persent_x1)*catchViewWidth;
    photoheight=(persent_y2-persent_y1)*catchViewHeight;
    
    NSLog(@"photo:%lf,%lf/t%lf,%lf",photox, photoy, photowidth, photoheight);
    self.catchPhotoView1.frame=CGRectMake(photox, photoy, photowidth, photoheight);
    
    [self shotPhotoWithSelect:1];
    [self sendDataWithX1:persent_x1 Y1:persent_y1 X2:persent_x2 Y2:persent_y2 ID:1 flag:TRUE];
    self.sendDataButtonView.enabled=FALSE;
    self.deleteDataButtonView.enabled=TRUE;

}

- (IBAction)deleteDataButton:(id)sender {
    [self deletePhotoWithSelect:1];
    [self sendDataWithX1:0 Y1:0 X2:0 Y2:0 ID:1 flag:FALSE];
    self.sendDataButtonView.enabled=TRUE;
    self.deleteDataButtonView.enabled=FALSE;
}
//发送按钮2
- (IBAction)sendDataButton1:(id)sender {
    NSLog(@"lalalala");
    float real_x1;float real_y1;
    float real_x2;float real_y2;
    float end_width;float end_height;
    float persent_x1;float persent_x2;
    float persent_y1;float persent_y2;
    DJIFlightController *sendData;
    NSString *locationData;
    //(real_x1,real_y1)为左上角的点
    //(real_x2,real_y2)为右下角的点
    if (_x_begin>_x_end) {
        real_x1 = _x_end;
        real_x2 = _x_begin;
    } else {
        real_x1 = _x_begin;
        real_x2 = _x_end;
    }
    if (_y_begin>_y_end) {
        real_y2 = _y_begin;
        real_y1 = _y_end;
    } else {
        real_y2 = _y_end;
        real_y1 = _y_begin;
    }
    persent_y1 = (real_y1 - 305)/442.8;
    persent_y2 = (real_y2 - 305)/442.8;
    persent_x1 = (real_x1 - 20)/787.8;
    persent_x2 = (real_x2 - 20)/787.8;
    
    float photox,photoy,photowidth,photoheight;
    photox = catchViewWidth*persent_x1 + 20 + catchViewWidth;
    photoy =catchViewHeight*persent_y1 + topoffset;
    photowidth=(persent_x2-persent_x1)*catchViewWidth;
    photoheight=(persent_y2-persent_y1)*catchViewHeight;
    
    NSLog(@"photo:%lf,%lf/t%lf,%lf",photox, photoy, photowidth, photoheight);
    self.catchPhotoView2.frame=CGRectMake(photox, photoy, photowidth, photoheight);
    
    [self shotPhotoWithSelect:2];
    [self sendDataWithX1:persent_x1 Y1:persent_y1 X2:persent_x2 Y2:persent_y2 ID:2 flag:TRUE];
    self.sendDataButtonView1.enabled=FALSE;
    self.deleteDataButtonView1.enabled=TRUE;
}

- (IBAction)deleteDataButton1:(id)sender {
    [self deletePhotoWithSelect:2];
     [self sendDataWithX1:0 Y1:0 X2:0 Y2:0 ID:2 flag:FALSE];
    self.sendDataButtonView1.enabled=TRUE;
    self.deleteDataButtonView1.enabled=FALSE;
}
//发送按钮3
- (IBAction)sendDataButton2:(id)sender {
    NSLog(@"lalalala");
    float real_x1;float real_y1;
    float real_x2;float real_y2;
    float end_width;float end_height;
    float persent_x1;float persent_x2;
    float persent_y1;float persent_y2;
    DJIFlightController *sendData;
    NSString *locationData;
    //(real_x1,real_y1)为左上角的点
    //(real_x2,real_y2)为右下角的点
    if (_x_begin>_x_end) {
        real_x1 = _x_end;
        real_x2 = _x_begin;
    } else {
        real_x1 = _x_begin;
        real_x2 = _x_end;
    }
    if (_y_begin>_y_end) {
        real_y2 = _y_begin;
        real_y1 = _y_end;
    } else {
        real_y2 = _y_end;
        real_y1 = _y_begin;
    }
    persent_y1 = (real_y1 - 305)/442.8;
    persent_y2 = (real_y2 - 305)/442.8;
    persent_x1 = (real_x1 - 20)/787.8;
    persent_x2 = (real_x2 - 20)/787.8;
    
    float photox,photoy,photowidth,photoheight;
    photox = catchViewWidth*persent_x1 + 20 + catchViewWidth*2 ;
    photoy =catchViewHeight*persent_y1 + topoffset;
    photowidth=(persent_x2-persent_x1)*catchViewWidth;
    photoheight=(persent_y2-persent_y1)*catchViewHeight;
    
    NSLog(@"photo:%lf,%lf/t%lf,%lf",photox, photoy, photowidth, photoheight);
    self.catchPhotoView3.frame=CGRectMake(photox, photoy, photowidth, photoheight);
    
    [self shotPhotoWithSelect:3];
    [self sendDataWithX1:persent_x1 Y1:persent_y1 X2:persent_x2 Y2:persent_y2 ID:3 flag:TRUE];
    self.sendDataButtonView2.enabled=FALSE;
    self.deleteDataButtonView2.enabled=TRUE;
}

- (IBAction)deleteDataButton2:(id)sender {
    [self deletePhotoWithSelect:3];
    [self sendDataWithX1:0 Y1:0 X2:0 Y2:0 ID:3 flag:FALSE];
    self.sendDataButtonView2.enabled=TRUE;
    self.deleteDataButtonView2.enabled=FALSE;
}
//发送按钮切换手动自动
- (IBAction)changecontrol:(id)sender {
    [self sendDatawithNum];
    if (_controlmode == 1){
        //自动模式下发送按钮可以使用
        self.sendDataButtonView.enabled = TRUE;
        self.sendDataButtonView1.enabled = TRUE;
        self.sendDataButtonView2.enabled = TRUE;
        _controlbyhandLabel.text = @"自动模式";
        _controlbyhand.selected = TRUE;
        _controlmode = 0;
    }
    else {
        //手动模式下全部按钮不可用 且目标图片清除
        self.deleteDataButtonView.enabled=FALSE;
        self.deleteDataButtonView1.enabled=FALSE;
        self.deleteDataButtonView2.enabled=FALSE;
        self.sendDataButtonView.enabled=FALSE;
        self.sendDataButtonView1.enabled=FALSE;
        self.sendDataButtonView2.enabled=FALSE;
        //删除图片
        [self deletePhotoWithSelect:1];
        [self deletePhotoWithSelect:2];
        [self deletePhotoWithSelect:3];
        _controlbyhandLabel.text = @"手动模式";
        _controlbyhand.selected = FALSE;
        _controlmode = 1;
    }
    
}

/*********************************************************************************/
#pragma mark - DJIFlightControllerDelegate
/*********************************************************************************/
//接收函数
-(void)flightController:(DJIFlightController *)fc didReceiveDataFromOnboardSDKDevice:(NSData *)data{
    
    //    DJIFlightController* fc = [DemoComponentHelper fetchFlightController];
    
    NSString *mydata = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSString *strx1,*strx2,*stry1,*stry2;
    
    float x1,x2,y1,y2;
    float real_x1,real_x2,real_y1,real_y2;
    
    NSArray *array1 = [mydata componentsSeparatedByString:@":"];
    NSArray *array = [array1[1] componentsSeparatedByString:@","];
    
    UIInterfaceOrientation currOrientation = [[UIApplication sharedApplication]statusBarOrientation];
    
    strx1 = array[0];
    stry1 = array[1];
    strx2 = array[2];
    stry2 = array[3];
    
    x1 = [strx1 floatValue];
    y1 = [stry1 floatValue];
    x2 = [strx2 floatValue];
    y2 = [stry2 floatValue];
    
    if (UIInterfaceOrientationIsPortrait(currOrientation)) {//竖屏
        NSLog(@"进入竖屏");
        real_y1 = (y1 * 409.5) + 594.5;
        real_y2 = (y2 * 409.5) + 594.5;
        real_x1 = (x1 * 728) + 20;
        real_x2 = (x2 * 728) + 20;
    } else {
        NSLog(@"进入横屏");
        real_y1 = (y1 * 553.5) + 202;
        real_y2 = (y2 * 553.5) + 202;
        real_x1 = (x1 * 984) + 20;
        real_x2 = (x2 * 984) + 20;
    }
    //    self.catchView.frame=CGRectMake(real_x1, real_y1, real_x2, real_y2);
    self.catchView.frame=CGRectMake(100, 100, 200, 200);
    
    [self updateThermalCameraUI];
}


#pragma mark - Actions
/**
 *  When the pre-condition meets, the start record button should be enabled. Then the user can can record
 *  a video now.
 */
- (IBAction)onStartRecordButtonClicked:(id)sender {
    __weak DJICamera* camera = [DemoComponentHelper fetchCamera];
    if (camera) {
        [self.startRecordButton setEnabled:NO];
        [camera startRecordVideoWithCompletion:^(NSError * _Nullable error) {
            if (error) {
                ShowResult(@"ERROR: startRecordVideoWithCompletion:. %@", error.description);
            }
        }];
    }
}

/**
 *  When the camera is recording, the stop record button should be enabled. Then the user can stop recording
 *  the video.
 */
- (IBAction)onStopRecordButtonClicked:(id)sender {
    __weak DJICamera* camera = [DemoComponentHelper fetchCamera];
    if (camera) {
        [self.stopRecordButton setEnabled:NO];
        [camera stopRecordVideoWithCompletion:^(NSError * _Nullable error) {
            if (error) {
                ShowResult(@"ERROR: stopRecordVideoWithCompletion:. %@", error.description);
            }
        }];
    }
}
#pragma mark - Precondition
/**
 *  Check if the camera's mode is DJICameraModeRecordVideo.
 *  If the mode is not DJICameraModeRecordVideo, we need to set it to be DJICameraModeRecordVideo.
 *  If the mode is already DJICameraModeRecordVideo, we check the exposure mode.
 */
-(void) getCameraMode {
    __weak DJICamera* camera = [DemoComponentHelper fetchCamera];
    if (camera) {
        WeakRef(target);
        [camera getModeWithCompletion:^(DJICameraMode mode, NSError * _Nullable error) {
            WeakReturn(target);
            if (error) {
                ShowResult(@"ERROR: getModeWithCompletion:. %@", error.description);
            }
            else if (mode == DJICameraModeRecordVideo) {
                target.isInRecordVideoMode = YES;
            }
            else {
                [target setCameraMode];
            }
        }];
    }
}

/**
 *  Set the camera's mode to DJICameraModeRecordVideo.
 *  If it succeeds, we can enable the take photo button.
 */
-(void) setCameraMode {
    __weak DJICamera* camera = [DemoComponentHelper fetchCamera];
    if (camera) {
        WeakRef(target);
        [camera setMode:DJICameraModeRecordVideo withCompletion:^(NSError * _Nullable error) {
            WeakReturn(target);
            if (error) {
                ShowResult(@"ERROR: setMode:withCompletion:. %@", error.description);
            }
            else {
                // Normally, once an operation is finished, the camera still needs some time to finish up
                // all the work. It is safe to delay the next operation after an operation is finished.
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    WeakReturn(target);
                    target.isInRecordVideoMode = YES;
                });
            }
        }];
    }
}
#pragma mark - UI related
- (void)setVideoPreview {
    [[VideoPreviewer instance] start];
    [[VideoPreviewer instance] setView:self.fpvView];
    self.previewerAdapter = [VideoPreviewerSDKAdapter adapterWithDefaultSettings];
    [self.previewerAdapter start];
}

- (void)cleanVideoPreview {
    [[VideoPreviewer instance] unSetView];
    if (self.previewerAdapter) {
        [self.previewerAdapter stop];
        self.previewerAdapter = nil;
    }
}

-(void) setIsInRecordVideoMode:(BOOL)isInRecordVideoMode {
    _isInRecordVideoMode = isInRecordVideoMode;
    [self toggleRecordUI];
}

-(void) setIsRecordingVideo:(BOOL)isRecordingVideo {
    _isRecordingVideo = isRecordingVideo;
    [self toggleRecordUI];
}

-(void) toggleRecordUI {
    [self.startRecordButton setEnabled:(self.isInRecordVideoMode && !self.isRecordingVideo)];
    [self.stopRecordButton setEnabled:(self.isInRecordVideoMode && self.isRecordingVideo)];
    if (!self.isRecordingVideo) {
//        self.recordingTimeLabel.text = @"00:00";
    }
    else {
        int hour = (int)self.recordingTime / 3600;
        int minute = (self.recordingTime % 3600) / 60;
        int second = (self.recordingTime % 3600) % 60;
//        self.recordingTimeLabel.text = [NSString stringWithFormat:@"%02d:%02d:%02d",hour, minute, second];
    }
}

#pragma mark - DJICameraDelegate
-(void)camera:(DJICamera *)camera didReceiveVideoData:(uint8_t *)videoBuffer length:(size_t)length
{
    [[VideoPreviewer instance] push:videoBuffer length:(int)length];
}

//-(void)camera:(DJICamera *)camera didUpdateSystemState:(DJICameraSystemState *)systemState {
//    self.isRecordingVideo = systemState.isRecording;
//    
//    self.recordingTime = systemState.currentVideoRecordingTimeInSeconds;
//}



@end

