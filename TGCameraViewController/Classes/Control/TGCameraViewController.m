//
//  TGCameraViewController.m
//  TGCameraViewController
//
//  Created by Bruno Tortato Furtado on 13/09/14.
//  Copyright (c) 2014 Tudo Gostoso Internet. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#import "TGCameraViewController.h"
#import "TGPhotoViewController.h"
#import "TGCameraSlideView.h"
#import "TGTintedButton.h"
#import "UIColor+WFDColors.h"

@interface TGCameraViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (strong, nonatomic) IBOutlet UIView *captureView;
@property (strong, nonatomic) IBOutlet UIImageView *topLeftView;
@property (strong, nonatomic) IBOutlet UIImageView *topRightView;
@property (strong, nonatomic) IBOutlet UIImageView *bottomLeftView;
@property (strong, nonatomic) IBOutlet UIImageView *bottomRightView;
@property (strong, nonatomic) IBOutlet UIView *separatorView;
@property (strong, nonatomic) IBOutlet UIView *bottomView;
@property (strong, nonatomic) IBOutlet UIView *actionsView;
@property (strong, nonatomic) IBOutlet TGTintedButton *gridButton;
@property (strong, nonatomic) IBOutlet TGTintedButton *toggleButton;
@property (strong, nonatomic) IBOutlet TGTintedButton *shotButton;
@property (strong, nonatomic) IBOutlet UIButton *flashButton;
@property (strong, nonatomic) IBOutlet TGCameraSlideView *slideUpView;
@property (strong, nonatomic) IBOutlet TGCameraSlideView *slideDownView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *toggleButtonWidth;

@property (strong, nonatomic) TGCamera *camera;
@property (nonatomic) BOOL wasLoaded;

- (IBAction)closeTapped;
- (IBAction)gridTapped;
- (IBAction)flashTapped;
- (IBAction)shotTapped;
- (IBAction)albumTapped;
- (IBAction)toggleTapped;
- (IBAction)handleTapGesture:(UITapGestureRecognizer *)recognizer;

- (void)deviceOrientationDidChangeNotification;
- (AVCaptureVideoOrientation)videoOrientationForDeviceOrientation:(UIDeviceOrientation)deviceOrientation;
- (void)viewWillDisappearWithCompletion:(void (^)(void))completion;

@end

@implementation TGCameraViewController

- (instancetype)init
{
    return [super initWithNibName:NSStringFromClass(self.class) bundle:[NSBundle bundleForClass:self.class]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    if (devices.count > 1) {
        
        if ([[TGCamera getOption:kTGCameraOptionHiddenToggleButton] boolValue] == YES) {
            _toggleButton.hidden = YES;
            _toggleButtonWidth.constant = 0;
        }
    }
    else {
        
        if ([[TGCamera getOption:kTGCameraOptionHiddenToggleButton] boolValue] == YES) {
            _toggleButton.hidden = YES;
            _toggleButtonWidth.constant = 0;
        }
    }
    
    NSBundle *bundle = [NSBundle bundleForClass:self.class];
    
    UIImage *cameraCloseImage = [UIImage imageNamed:@"camera_close" inBundle:bundle compatibleWithTraitCollection:nil];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:cameraCloseImage
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(closeTapped)];

    if (![[TGCamera getOption:kTGCameraOptionHiddenAlbumButton] boolValue]) {
        
        UIImage *cameraRollImage = [UIImage imageNamed:@"camera_gallery" inBundle:bundle compatibleWithTraitCollection:nil];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:cameraRollImage
                                                                                  style:UIBarButtonItemStylePlain
                                                                                 target:self
                                                                                 action:@selector(albumTapped)];
    }
    
    [_shotButton setImage:[UIImage imageNamed:@"CameraShot" inBundle:bundle compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    _shotButton.showTintColorWhenHighlighted = YES;
    
    [_gridButton setImage:[UIImage imageNamed:@"camera_grid" inBundle:bundle compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    _gridButton.showTintColorWhenSelected = YES;
    
    [_toggleButton setImage:[UIImage imageNamed:@"camera_switch" inBundle:bundle compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    _toggleButton.showTintColorWhenHighlighted = YES;
    
    _camera = [TGCamera cameraWithFlashButton:_flashButton];
    
    _captureView.backgroundColor = [UIColor clearColor];
    
    _topLeftView.transform = CGAffineTransformMakeRotation(0);
    _topRightView.transform = CGAffineTransformMakeRotation(M_PI_2);
    _bottomLeftView.transform = CGAffineTransformMakeRotation(-M_PI_2);
    _bottomRightView.transform = CGAffineTransformMakeRotation(M_PI_2*2);
    
    _bottomView.backgroundColor = [UIColor wfd_gray10];
    _actionsView.backgroundColor = [UIColor wfd_gray10];
    
    // set empty back navigation item
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(deviceOrientationDidChangeNotification)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
    
    _separatorView.hidden = NO;
    
//    _actionsView.hidden = YES;
    
    _topLeftView.hidden =
    _topRightView.hidden =
    _bottomLeftView.hidden =
    _bottomRightView.hidden = YES;
    
    _gridButton.enabled =
    _toggleButton.enabled =
    _shotButton.enabled =
    _flashButton.enabled = NO;
    
    [_camera startRunning];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self deviceOrientationDidChangeNotification];
    
    _separatorView.hidden = YES;
    
    [TGCameraSlideView hideSlideUpView:_slideUpView slideDownView:_slideDownView atView:_captureView completion:^{
        _topLeftView.hidden =
        _topRightView.hidden =
        _bottomLeftView.hidden =
        _bottomRightView.hidden = NO;
        
//        _actionsView.hidden = NO;
        
        _gridButton.enabled =
        _toggleButton.enabled =
        _shotButton.enabled =
        _flashButton.enabled = YES;
    }];
    
    if (_wasLoaded == NO) {
        _wasLoaded = YES;
        [_camera insertSublayerWithCaptureView:_captureView atRootView:self.view];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [_camera stopRunning];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark -
#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *photo = [TGAlbum imageWithMediaInfo:info];
    
    TGPhotoViewController *viewController = [TGPhotoViewController newWithDelegate:_delegate photo:photo];
    [viewController setAlbumPhoto:YES];
    [self.navigationController pushViewController:viewController animated:NO];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -
#pragma mark - Actions

- (IBAction)closeTapped
{
    if ([_delegate respondsToSelector:@selector(cameraDidCancel)]) {
        [_delegate cameraDidCancel];
    }
}

- (IBAction)gridTapped
{
    _gridButton.selected = !_gridButton.selected;
    
    [_camera disPlayGridView];
}

- (IBAction)flashTapped
{
    [_camera changeFlashModeWithButton:_flashButton];
}

- (IBAction)shotTapped
{
    _shotButton.enabled = NO;
    
    UIDeviceOrientation deviceOrientation = [[UIDevice currentDevice] orientation];
    AVCaptureVideoOrientation videoOrientation = [self videoOrientationForDeviceOrientation:deviceOrientation];
    
    dispatch_group_t group = dispatch_group_create();
    __block UIImage *photo;
    
    dispatch_group_enter(group);
    [self viewWillDisappearWithCompletion:^{
        dispatch_group_leave(group);
    }];
    
    dispatch_group_enter(group);
    [_camera takePhotoWithCaptureView:_captureView videoOrientation:videoOrientation cropSize:_captureView.frame.size completion:^(UIImage *_photo) {
        photo = _photo;
        dispatch_group_leave(group);
    }];
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        TGPhotoViewController *viewController = [TGPhotoViewController newWithDelegate:_delegate photo:photo];
        [self.navigationController pushViewController:viewController animated:YES];
    });
}

- (IBAction)albumTapped
{
    _shotButton.enabled = NO;
    
    [self viewWillDisappearWithCompletion:^{
        UIImagePickerController *pickerController = [TGAlbum imagePickerControllerWithDelegate:self];
        [self presentViewController:pickerController animated:YES completion:nil];
    }];
}

- (IBAction)toggleTapped
{
    [_camera toogleWithFlashButton:_flashButton];
}

- (IBAction)handleTapGesture:(UITapGestureRecognizer *)recognizer
{
    CGPoint touchPoint = [recognizer locationInView:_captureView];
    [_camera focusView:_captureView inTouchPoint:touchPoint];
}

#pragma mark -
#pragma mark - Private methods

- (void)deviceOrientationDidChangeNotification
{
    UIDeviceOrientation orientation = [UIDevice.currentDevice orientation];
    NSInteger degress;
    
    switch (orientation) {
        case UIDeviceOrientationFaceUp:
        case UIDeviceOrientationPortrait:
        case UIDeviceOrientationUnknown:
            degress = 0;
            break;
            
        case UIDeviceOrientationLandscapeLeft:
            degress = 90;
            break;
            
        case UIDeviceOrientationFaceDown:
        case UIDeviceOrientationPortraitUpsideDown:
            degress = 180;
            break;
            
        case UIDeviceOrientationLandscapeRight:
            degress = 270;
            break;
    }
    
    CGFloat radians = degress * M_PI / 180;
    CGAffineTransform transform = CGAffineTransformMakeRotation(radians);
    
    [UIView animateWithDuration:.5f animations:^{
        _gridButton.transform =
        _toggleButton.transform =
        _flashButton.transform = transform;
    }];
}

- (AVCaptureVideoOrientation)videoOrientationForDeviceOrientation:(UIDeviceOrientation)deviceOrientation
{
    AVCaptureVideoOrientation result = (AVCaptureVideoOrientation) deviceOrientation;
    
    switch (deviceOrientation) {
        case UIDeviceOrientationLandscapeLeft:
            result = AVCaptureVideoOrientationLandscapeRight;
            break;
            
        case UIDeviceOrientationLandscapeRight:
            result = AVCaptureVideoOrientationLandscapeLeft;
            break;
            
        default:
            break;
    }
    
    return result;
}

- (void)viewWillDisappearWithCompletion:(void (^)(void))completion
{
//    _actionsView.hidden = YES;
    
    [TGCameraSlideView showSlideUpView:_slideUpView slideDownView:_slideDownView atView:_captureView completion:^{
        completion();
    }];
}

@end
