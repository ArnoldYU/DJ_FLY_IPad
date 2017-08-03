//
//  CameraFPVViewController.h
//  DJISdkDemo
//
//  Copyright © 2015 DJI. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface CameraFPVViewController : UIViewController



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


@end
