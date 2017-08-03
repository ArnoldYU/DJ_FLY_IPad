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


@interface CameraFPVViewController () <DJICameraDelegate>


@property(nonatomic, weak) IBOutlet UIView* fpvView;//视频显示位置
@property (weak, nonatomic) IBOutlet UIView *fpvTemView;
@property(nonatomic, weak) IBOutlet UIView* catchView;//抓取框
@property (weak, nonatomic) IBOutlet UIView *buttonView;//按钮位置约束
- (IBAction)confirmButton:(UIButton *)sender;
- (IBAction)cancelButton:(UIButton *)sender;





@property (weak, nonatomic) IBOutlet UISwitch *fpvTemEnableSwitch;
@property (weak, nonatomic) IBOutlet UILabel *fpvTemperatureData;

@property(nonatomic, assign) BOOL needToSetMode;

@property(nonatomic) VideoPreviewerSDKAdapter *previewerAdapter;

@end

@implementation CameraFPVViewController{
    NSArray *fpvViewLandConstraints;//视频显示位置的横向约束
    NSArray *buttonViewLandConstraints;//按钮显示位置的横向约束
    NSArray *rootViewLandscapeConstraints;
    
    __weak IBOutlet UIView *fpv_View;
    __weak IBOutlet UIView *button_View;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _touchFlag = TRUE;
    
    DJICamera* camera = [DemoComponentHelper fetchCamera];
    if (camera) {
        camera.delegate = self;
    }

    self.needToSetMode = YES;

    [[VideoPreviewer instance] start];
    self.previewerAdapter = [VideoPreviewerSDKAdapter adapterWithDefaultSettings];
    [self.previewerAdapter start];
}

-(void) viewWillAppear:(BOOL)animated//当场景进入的时候，自动显示视频
{
    [super viewWillAppear:animated];
    
    [[VideoPreviewer instance] setView:self.fpvView];
    
    _catchView.layer.borderWidth = 1;
    _catchView.layer.borderColor = [[UIColor whiteColor]CGColor];
    NSLog(@"catchView frame: %@", NSStringFromCGRect(_catchView.frame));
    [self updateThermalCameraUI]; 
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
//    NSLog(@"touch location: %@", NSStringFromCGPoint(pt));
//    _x_end = pt.x - 8;
//    _y_end = pt.y - 335.5;
    _x_end = pt.x;
    _y_end = pt.y;
//    NSLog(@"end:\tx:%lf\ty:%lf",_x_end,_y_end);
//    _height = _y_begin - _y_end;
    _height = _y_end - _y_begin;
    _width = _x_end - _x_begin;
    NSLog(@"height:%lf\twidth:%lf",_height,_width);
    if (_touchFlag){
        self.catchView.frame=CGRectMake(_x_begin, _y_begin, _width, _height);
        
        [self updateThermalCameraUI];

    }
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint pt = [touch locationInView:self.view];
//    NSLog(@"touch location: %@", NSStringFromCGPoint(pt));
//    _x_begin = pt.x - 8;
//    _y_begin = pt.y - 335.5;
    _x_begin = pt.x;
    _y_begin = pt.y;
//    NSLog(@"begin:\tx:%lf\ty:%lf",_x_begin,_y_begin);
//    self.catchView.frame=CGRectMake(x, y, 100, 100);
//
//    [self updateThermalCameraUI];

}
-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint pt = [touch locationInView:self.view];
    
    _x_moved = pt.x;
    _y_moved = pt.y;
    _height = _y_moved - _y_begin;
    _width = _x_moved - _x_begin;
    if (_touchFlag){
        self.catchView.frame=CGRectMake(_x_begin, _y_begin, _width, _height);
        NSLog(@"height:%lf\twidth:%lf",_height,_width);
        [self updateThermalCameraUI];
    }
}


- (IBAction)confirmButton:(UIButton *)sender {
    _touchFlag = FALSE;
    NSLog(@"lalalala");
    float real_x1;
    float real_y1;
    float real_x2;
    float real_y2;
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
        real_y1 = _y_begin;
        real_y2 = _y_end;
    } else {
        real_y1 = _y_end;
        real_y2 = _y_begin;
    }
    
//    NSLog(@"begin:\tx:%lf\ty:%lf",real_x1,real_y1);
//    NSLog(@"end:\tx:%lf\ty:%lf",real_x2,real_y2);
    locationData = [[NSString alloc] initWithString:[NSString stringWithFormat:@"%lf,%lf,%lf,%lf,",real_x1,real_y1,real_x2,real_y2]];
    NSLog(@"%@",locationData);
    NSData *testData = [locationData dataUsingEncoding: NSUTF8StringEncoding];
    Byte *testByte = (Byte *)[testData bytes];
    for(int i=0;i<[testData length];i++)
        printf("testByte = %d\n",testByte[i]);
    DJIFlightController* fc = [DemoComponentHelper fetchFlightController];
//    [sendData sendDataToOnboardSDKDevice:testData withCompletion:nil];
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

- (IBAction)cancelButton:(UIButton *)sender {
    _touchFlag = TRUE;
}

-(void)setupLandscapeConstraints {
    NSDictionary *views;
    id topGuide = self.topLayoutGuide;
    id bottomGuide = self.bottomLayoutGuide;
    views = NSDictionaryOfVariableBindings(
                                           topGuide,
                                           bottomGuide,
                                           fpv_View,
                                           button_View
                                           );
    NSMutableArray *tempFpvViewConstraints = [NSMutableArray new];
    NSMutableArray *tempButtonViewContraints = [NSMutableArray new];
    NSMutableArray *tempRootViewConstraints = [NSMutableArray new];
    
    NSArray *generatedConstraints;//3创建一个到所有返回的生成约束属组的可复用引用
    
//    generatedConstraints = [NSLayoutConstraint constraintsWithVisualFormat:
    //root 的约束
    generatedConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[topGuide]-[button_View]-30-[fpv_View]" options:0 metrics:nil views:views];
    [tempRootViewConstraints addObjectsFromArray:generatedConstraints];
    
    //fpvView的约束
    generatedConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[fpv_View(728)]" options:0 metrics:nil views:views];
    [tempFpvViewConstraints addObjectsFromArray:generatedConstraints];
    generatedConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[fpv_View(409.5)]" options:0 metrics:nil views:views];
    [tempFpvViewConstraints addObjectsFromArray:generatedConstraints];
    
    rootViewLandscapeConstraints = [NSArray arrayWithArray:tempRootViewConstraints];
    fpvViewLandConstraints = [NSArray arrayWithArray:tempFpvViewConstraints];
}
//判断屏幕的选装方向
-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation)){//纵向为true // 此为纵向
        
        [self.view removeConstraints:rootViewLandscapeConstraints];//2这是纵向屏幕，因此移除横向约束，从主视图开始。对还没有附属到视图的约束调用removeConstraints:也是可行的
        [fpv_View removeConstraints:fpvViewLandConstraints];
        [button_View removeConstraints:buttonViewLandConstraints];
        
        [self.view addConstraints:self.rootViewPortraitConstraints];//3添加所有的纵向约束。添加已存在的会被忽略
        [fpv_View addConstraints:self.fpvViewPortraitConstraints];
        [button_View addConstraints:self.buttonPortraitConstraints];
    } else { //此为横向
        [self.view removeConstraints:self.rootViewPortraitConstraints];//5移除所有特定于纵向屏幕的约束
        [fpv_View removeConstraints:self.fpvViewPortraitConstraints];
        [button_View removeConstraints:self.buttonPortraitConstraints];
        
        [self.view addConstraints:rootViewLandscapeConstraints];//6添加特定于横向屏幕的约束
        [fpv_View addConstraints:fpvViewLandConstraints];
        [button_View addConstraints:buttonViewLandConstraints];
    }
}




@end
