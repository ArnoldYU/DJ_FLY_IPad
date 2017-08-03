//
//  CameraFPVViewController.h
//  DJISdkDemo
//
//  Copyright © 2015 DJI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DJISDK/DJIFlightController.h>

@interface CameraFPVViewController : UIViewController

<DJIFlightControllerDelegate>

@property float x_begin;
@property float y_begin;
@property float x_end;
@property float y_end;
@property float height;
@property float width;
@property float x_moved;
@property float y_moved;
@property BOOL touchFlag;
@property (strong, nonatomic) IBOutletCollection(NSLayoutConstraint) NSArray *buttonPortraitConstraints;
@property (strong, nonatomic) IBOutletCollection(NSLayoutConstraint) NSArray *fpvViewPortraitConstraints;
@property (strong, nonatomic) IBOutletCollection(NSLayoutConstraint) NSArray *rootViewPortraitConstraints;
@property (strong, nonatomic) IBOutletCollection(NSLayoutConstraint) NSArray *photoViewPotraitConstraints;
//
//-(void)test;
@property DJIFlightController *fc;
@property NSData *data;

- (void)sendDateWithX1:(float) persent_x1
                    Y1:(float)persent_y1
                    X2:(float)persent_x2
                    Y2:(float)persent_y2;

- (UIImage *)getImageViewWithView:(UIView *)view;


@end
