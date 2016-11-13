//
//  UIColor+WFDColors.m
//  Fooder
//
//  Created by Petroianu Daniel on 22/09/16.
//  Copyright © 2016 Marius. All rights reserved.
//

#import "UIColor+WFDColors.h"

static inline UIColor* colorFromHex(unsigned long int hexColor, CGFloat alpha)
{
    return [UIColor colorWithRed:((float)((hexColor & 0xFF0000) >> 16))/255.0
                           green:((float)((hexColor & 0x00FF00) >>  8))/255.0
                            blue:((float)((hexColor & 0x0000FF) >>  0))/255.0
                           alpha:alpha];
}

#define UIColorFromRGBA(hexColor, alpha) ({     \
    static UIColor *color = nil;                \
    if(nil == color)                            \
    {                                           \
        color = colorFromHex(hexColor, alpha);  \
    }                                           \
    color;                                      \
})
#define UIColorFromRGB(hexColor) UIColorFromRGBA(hexColor, 1.0)


@implementation UIColor (WFDColors)

+ (UIColor *)wfd_mainColor      { return UIColorFromRGB(0xE40046); } // http://hex.colorrrs.com/E40046
+ (UIColor *)wfd_secondaryColor { return UIColorFromRGB(0x3CDBC0); } // http://hex.colorrrs.com/3CDBC0
+ (UIColor *)wfd_tertiaryColor  { return UIColorFromRGB(0x54585A); } // http://hex.colorrrs.com/54585A

+ (UIColor *)wfd_gray10 { return UIColorFromRGB(0xEBEBEB); }
+ (UIColor *)wfd_gray40 { return UIColorFromRGB(0xAAAAAA); }
+ (UIColor *)wfd_gray70 { return UIColorFromRGB(0x5E5E5E); }

@end
