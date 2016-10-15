//
//  TGTintedButton.m
//  TGCameraViewController
//
//  Created by Mike Sprague on 3/30/15.
//  Copyright (c) 2015 Tudo Gostoso Internet. All rights reserved.
//

#import "TGTintedButton.h"
#import "TGCameraColor.h"

@interface TGTintedButton ()

- (void)updateTintIfNeeded;

@end

@implementation TGTintedButton

- (void)setShowTintColorWhenHighlighted:(BOOL)showTintColorWhenHighlighted {
    if (showTintColorWhenHighlighted) {
        [self setCustomTintColorOverride:[TGCameraColor tintGrayColor]];
    }
    _showTintColorWhenHighlighted = showTintColorWhenHighlighted;
}

- (void)setShowTintColorWhenSelected:(BOOL)showTintColorWhenSelected {
    if (showTintColorWhenSelected) {
        [self setCustomTintColorOverride:[TGCameraColor tintGrayColor]];
    }
    _showTintColorWhenSelected = showTintColorWhenSelected;
}

- (void)setNeedsLayout {
    [super setNeedsLayout];
    [self updateTintIfNeeded];
}

- (void)setBackgroundImage:(UIImage *)image forState:(UIControlState)state {
    if (state != UIControlStateNormal) {
        return;
    }
    
    UIImageRenderingMode renderingMode = self.disableTint ? UIImageRenderingModeAlwaysOriginal : UIImageRenderingModeAlwaysTemplate;
    [super setBackgroundImage:[image imageWithRenderingMode:renderingMode] forState:state];
}

- (void)setImage:(UIImage *)image forState:(UIControlState)state {
    if (state != UIControlStateNormal) {
        return;
    }
    
    UIImageRenderingMode renderingMode = self.disableTint ? UIImageRenderingModeAlwaysOriginal : UIImageRenderingModeAlwaysTemplate;
    [super setImage:[image imageWithRenderingMode:renderingMode] forState:state];
}

- (void)setHighlighted:(BOOL)highlighted {
    
    if (_showTintColorWhenHighlighted) {
        if (highlighted) {
            [self setCustomTintColorOverride:[TGCameraColor tintColor]];
        } else {
            [self setCustomTintColorOverride:[TGCameraColor tintGrayColor]];
        }
    }
    
    [super setHighlighted:highlighted];
}

- (void)setSelected:(BOOL)selected {
    
    if (_showTintColorWhenSelected) {
        if (selected) {
            [self setCustomTintColorOverride:[TGCameraColor tintColor]];
        } else {
            [self setCustomTintColorOverride:[TGCameraColor tintGrayColor]];
        }
    }
    
    [super setSelected:selected];
}

- (void)updateTintIfNeeded {
    UIColor *color = self.customTintColorOverride != nil ? self.customTintColorOverride : [TGCameraColor tintColor];
    
    UIImageRenderingMode renderingMode = self.disableTint ? UIImageRenderingModeAlwaysOriginal : UIImageRenderingModeAlwaysTemplate;
    
    if(self.tintColor != color) {
        [self setTintColor:color];
        
        UIImage * __weak backgroundImage = [[self backgroundImageForState:UIControlStateNormal] imageWithRenderingMode:renderingMode];
        [self setBackgroundImage:backgroundImage forState:UIControlStateNormal];
        
        UIImage * __weak image = [[self imageForState:UIControlStateNormal] imageWithRenderingMode:renderingMode];
        [self setImage:image forState:UIControlStateNormal];
        
    }
}

@end
