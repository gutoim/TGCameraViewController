//
//  TGPhotoViewController.m
//  TGCameraViewController
//
//  Created by Bruno Tortato Furtado on 15/09/14.
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

@import AssetsLibrary;
#import "TGPhotoViewController.h"
#import "TGAssetsLibrary.h"
#import "TGCameraColor.h"
#import "TGCameraFilterView.h"
#import "UIImage+CameraFilters.h"
#import "TGTintedButton.h"
#import "UIColor+WFDColors.h"
#import "UIFont+WFDFonts.h"

static NSString* const kTGCacheSatureKey = @"TGCacheSatureKey";
static NSString* const kTGCacheCurveKey = @"TGCacheCurveKey";
static NSString* const kTGCacheVignetteKey = @"TGCacheVignetteKey";

@interface TGPhotoViewController ()

@property (strong, nonatomic) IBOutlet UIImageView *photoView;
@property (strong, nonatomic) IBOutlet UIView *bottomView;

@property (strong, nonatomic) IBOutlet TGCameraFilterView *filterView;
@property (strong, nonatomic) IBOutlet UIButton *defaultFilterButton;

@property (weak, nonatomic) IBOutlet UIButton *cancelFilterButton;
@property (weak, nonatomic) IBOutlet UIButton *filterButton;

@property (weak, nonatomic) IBOutlet TGTintedButton *confirmButton;

@property (weak) id<TGCameraDelegate> delegate;
@property (strong, nonatomic) UIView *detailFilterView;
@property (strong, nonatomic) UIImage *photo;
@property (strong, nonatomic) NSCache *cachePhoto;
@property (nonatomic) BOOL albumPhoto;

- (IBAction)backTapped;
- (IBAction)confirmTapped;
- (IBAction)filtersTapped;

- (IBAction)defaultFilterTapped:(UIButton *)button;
- (IBAction)satureFilterTapped:(UIButton *)button;
- (IBAction)curveFilterTapped:(UIButton *)button;
- (IBAction)vignetteFilterTapped:(UIButton *)button;

- (void)addDetailViewToButton:(UIButton *)button;
+ (instancetype)newController;

@end

@implementation TGPhotoViewController

+ (instancetype)newWithDelegate:(id<TGCameraDelegate>)delegate photo:(UIImage *)photo
{
    TGPhotoViewController *viewController = [TGPhotoViewController newController];
    
    if (viewController) {
        viewController.delegate = delegate;
        viewController.photo = photo;
        viewController.cachePhoto = [[NSCache alloc] init];
    }
    
    return viewController;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIFont *buttonFont = [UIFont wfd_fontOfSize:13.5];
        
    self.cancelFilterButton.titleLabel.font = buttonFont;
    [self.cancelFilterButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [self.cancelFilterButton setTitleColor:[TGCameraColor tintGrayColor] forState:UIControlStateNormal];
    [self.cancelFilterButton setTitleColor:[TGCameraColor tintColor] forState:UIControlStateHighlighted];
    
    self.filterButton.titleLabel.font = buttonFont;
    [self.filterButton setTitle:@"Filter" forState:UIControlStateNormal];
    [self.filterButton setTitleColor:[TGCameraColor tintGrayColor] forState:UIControlStateNormal];
    [self.filterButton setTitleColor:[TGCameraColor tintColor] forState:UIControlStateHighlighted];
    
    _photoView.clipsToBounds = YES;
    _photoView.image = _photo;
    
    NSBundle *bundle = [NSBundle bundleForClass:self.class];
   
    [_confirmButton setImage:[UIImage imageNamed:@"camera_shot" inBundle:bundle compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    _confirmButton.showTintColorWhenHighlighted = YES;
    
    [self addDetailViewToButton:_defaultFilterButton];
    
    // set empty back navigation item
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
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
#pragma mark - Controller actions

- (IBAction)backTapped
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)confirmTapped
{
    if ( [_delegate respondsToSelector:@selector(cameraWillTakePhoto)]) {
        [_delegate cameraWillTakePhoto];
    }
    
    if ([_delegate respondsToSelector:@selector(cameraDidTakePhoto:)]) {
        _photo = _photoView.image;
        
        if (_albumPhoto) {
            [_delegate cameraDidSelectAlbumPhoto:_photo];
        } else {
            [_delegate cameraDidTakePhoto:_photo];
        }
        
        ALAuthorizationStatus status = [ALAssetsLibrary authorizationStatus];
        TGAssetsLibrary *library = [TGAssetsLibrary defaultAssetsLibrary];
        
        void (^saveJPGImageAtDocumentDirectory)(UIImage *) = ^(UIImage *photo) {
            [library saveJPGImageAtDocumentDirectory:_photo resultBlock:^(NSURL *assetURL) {
                [_delegate cameraDidSavePhotoAtPath:assetURL];
            } failureBlock:^(NSError *error) {
                if ([_delegate respondsToSelector:@selector(cameraDidSavePhotoWithError:)]) {
                    [_delegate cameraDidSavePhotoWithError:error];
                }
            }];
        };
        
        if ([[TGCamera getOption:kTGCameraOptionSaveImageToAlbum] boolValue] && status != ALAuthorizationStatusDenied) {
            [library saveImage:_photo resultBlock:^(NSURL *assetURL) {
                if ([_delegate respondsToSelector:@selector(cameraDidSavePhotoAtPath:)]) {
                    [_delegate cameraDidSavePhotoAtPath:assetURL];
                }
            } failureBlock:^(NSError *error) {
                saveJPGImageAtDocumentDirectory(_photo);
            }];
        } else {
            if ([_delegate respondsToSelector:@selector(cameraDidSavePhotoAtPath:)]) {
                saveJPGImageAtDocumentDirectory(_photo);
            }
        }
    }
}

- (IBAction)filtersTapped:(id)sender
{
    if ([_filterView isDescendantOfView:self.view]) {
        [_filterView removeFromSuperviewAnimated];
    } else {
        [_filterView addToView:self.view aboveView:_bottomView];
        [self.view sendSubviewToBack:_filterView];
        [self.view sendSubviewToBack:_photoView];
    }
}

- (IBAction)cancelFilterTapped:(id)sender
{
    // dismiss flter view
    if ([_filterView isDescendantOfView:self.view]) {
        [_filterView removeFromSuperviewAnimated];
    }

    // set default filter
    [self addDetailViewToButton:self.defaultFilterButton];
    _photoView.image = _photo;
}

#pragma mark -
#pragma mark - Filter view actions

- (IBAction)defaultFilterTapped:(UIButton *)button
{
    [self addDetailViewToButton:button];
    _photoView.image = _photo;
}

- (IBAction)satureFilterTapped:(UIButton *)button
{
    [self addDetailViewToButton:button];
    
    if ([_cachePhoto objectForKey:kTGCacheSatureKey]) {
        _photoView.image = [_cachePhoto objectForKey:kTGCacheSatureKey];
    } else {
        [_cachePhoto setObject:[_photo saturateImage:1.8 withContrast:1] forKey:kTGCacheSatureKey];
        _photoView.image = [_cachePhoto objectForKey:kTGCacheSatureKey];
    }
    
}

- (IBAction)curveFilterTapped:(UIButton *)button
{
    [self addDetailViewToButton:button];
    
    if ([_cachePhoto objectForKey:kTGCacheCurveKey]) {
        _photoView.image = [_cachePhoto objectForKey:kTGCacheCurveKey];
    } else {
        [_cachePhoto setObject:[_photo curveFilter] forKey:kTGCacheCurveKey];
        _photoView.image = [_cachePhoto objectForKey:kTGCacheCurveKey];
    }
}

- (IBAction)vignetteFilterTapped:(UIButton *)button
{
    [self addDetailViewToButton:button];
    
    if ([_cachePhoto objectForKey:kTGCacheVignetteKey]) {
        _photoView.image = [_cachePhoto objectForKey:kTGCacheVignetteKey];
    } else {
        [_cachePhoto setObject:[_photo vignetteWithRadius:0 intensity:6] forKey:kTGCacheVignetteKey];
        _photoView.image = [_cachePhoto objectForKey:kTGCacheVignetteKey];
    }
}

#pragma mark -
#pragma mark - Private methods

- (void)addDetailViewToButton:(UIButton *)button
{
    [_detailFilterView removeFromSuperview];
    
    CGFloat height = 2.5;
    
    CGRect frame = button.frame;
    frame.size.height = height;
    frame.origin.x = 0;
    frame.origin.y = CGRectGetMaxY(button.frame) - height;
    
    _detailFilterView = [[UIView alloc] initWithFrame:frame];
    _detailFilterView.backgroundColor = [TGCameraColor tintColor];
    _detailFilterView.userInteractionEnabled = NO;
    
    [button addSubview:_detailFilterView];
}

+ (instancetype)newController
{
    return [[self alloc] initWithNibName:NSStringFromClass(self.class) bundle:[NSBundle bundleForClass:self.class]];
}

@end
