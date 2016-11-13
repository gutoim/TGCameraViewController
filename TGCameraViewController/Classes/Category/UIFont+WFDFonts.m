//
//  UIFont+WFDFonts.m
//  Fooder
//
//  Created by Petroianu Daniel on 08/10/16.
//  Copyright © 2016 Marius. All rights reserved.
//

#import "UIFont+WFDFonts.h"


@implementation UIFont (WFDFonts)

+ (UIFont *)wfd_preferredFontForTextStyle:(WFDFontTextStyle)style
{
    switch (style) {
        case WFDFontTextStyleHeadline: {
            return [UIFont boldSystemFontOfSize:20];
        }
        case WFDFontTextStyleSubheadline: {
            return [UIFont systemFontOfSize:14];
        }
        case WFDFontTextStyleBody: {
            return [UIFont systemFontOfSize:10]; // TODO: set corect size
        }
        case WFDFontTextStyleButton: {
            return [UIFont boldSystemFontOfSize:16];
        }
        case WFDFontTextStyleFootnote: {
            return [UIFont systemFontOfSize:12];
        }
    }
    
    NSAssert(NO, @"Unknown style %d", style);
    return [UIFont systemFontOfSize:[UIFont systemFontSize]];
}

+ (UIFont *)wfd_fontOfSize:(CGFloat)fontSize
{
    return [UIFont systemFontOfSize:fontSize];
}
+ (UIFont *)wfd_boldFontOfSize:(CGFloat)fontSize
{
    return [UIFont boldSystemFontOfSize:fontSize];
}
+ (UIFont *)wfd_italicFontOfSize:(CGFloat)fontSize
{
    return [UIFont italicSystemFontOfSize:fontSize];
}

@end
