//
//  UIFont+WFDFonts.h
//  Fooder
//
//  Created by Petroianu Daniel on 08/10/16.
//  Copyright © 2016 Marius. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, WFDFontTextStyle) {
    WFDFontTextStyleHeadline,
    WFDFontTextStyleSubheadline,
    WFDFontTextStyleBody,
    WFDFontTextStyleButton,
    WFDFontTextStyleFootnote
};

@interface UIFont (WFDFonts)

+ (UIFont *)wfd_preferredFontForTextStyle:(WFDFontTextStyle)style;

+ (UIFont *)wfd_fontOfSize:(CGFloat)fontSize;
+ (UIFont *)wfd_boldFontOfSize:(CGFloat)fontSize;
+ (UIFont *)wfd_italicFontOfSize:(CGFloat)fontSize;

@end
