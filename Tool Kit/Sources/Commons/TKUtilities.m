//
//  TKUtilities.m
//  Tool Kit
//
//  Created by Alexander Koryttsev on 3/5/14.
//  Copyright (c) 2014 Alexander Koryttsev. All rights reserved.
//

#import "TKUtilities.h"

#import <sys/utsname.h>




BOOL    isIPad(void) {
    return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;
}

BOOL    isIPhone(void) {
    return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone;
}

CGFloat screenScale(void) {
    return [[UIScreen mainScreen] scale];
}

CGSize  scaledSize(CGSize size) {
    CGFloat scale = screenScale();
    return CGSizeMake(size.width * scale, size.height * scale);
}

BOOL    isRetina(void) {
    return screenScale() > 1.0;
}

BOOL hasFourInchDisplay (void)
{
    return ( [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone
            && [UIScreen mainScreen].bounds.size.height == 568.0 );
}

BOOL hasIOS7orLater (void)
{
    return ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7);
}


BOOL    isIOS7OrLater(void) {
#ifdef NSFoundationVersionNumber_iOS_6_1
    return floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1;
#endif
    return NO;
}

BOOL deviceHasCamera() {
    return [UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera];
}

CGAffineTransform transformForCurrentOrientation(void) {
    return transformForOrientation([[UIApplication sharedApplication] statusBarOrientation]);
}

CGAffineTransform transformForOrientation(UIInterfaceOrientation orientation) {
    
    switch (orientation) {
            
        case UIInterfaceOrientationLandscapeLeft:
            return CGAffineTransformMakeRotation(-M_PI_2);
            
        case UIInterfaceOrientationLandscapeRight:
            return CGAffineTransformMakeRotation(M_PI_2);
            
        case UIInterfaceOrientationPortraitUpsideDown:
            return CGAffineTransformMakeRotation(M_PI);
            
        case UIInterfaceOrientationPortrait:
        default:
            return CGAffineTransformMakeRotation(0);
    }
}


@implementation TKUtilities

+ (NSString*) deviceName
{
    struct utsname systemInfo;
    
    uname(&systemInfo);
    
    NSString* code = [NSString stringWithCString:systemInfo.machine
                                        encoding:NSUTF8StringEncoding];
    
    static NSDictionary* deviceNamesByCode = nil;
    
    if (!deviceNamesByCode) {
        
        deviceNamesByCode = @{@"x86_64"    :@"Simulator",
                              @"i386"      :@"Simulator",
                              @"iPod1,1"   :@"iPod Touch",      // (Original)
                              @"iPod2,1"   :@"iPod Touch",      // (Second Generation)
                              @"iPod3,1"   :@"iPod Touch",      // (Third Generation)
                              @"iPod4,1"   :@"iPod Touch",      // (Fourth Generation)
                              @"iPhone1,1" :@"iPhone",          // (Original)
                              @"iPhone1,2" :@"iPhone",          // (3G)
                              @"iPhone2,1" :@"iPhone",          // (3GS)
                              @"iPad1,1"   :@"iPad",            // (Original)
                              @"iPad2,1"   :@"iPad 2",          //
                              @"iPad3,1"   :@"iPad",            // (3rd Generation)
                              @"iPhone3,1" :@"iPhone 4",        //
                              @"iPhone4,1" :@"iPhone 4S",       //
                              @"iPhone5,1" :@"iPhone 5",        // (model A1428, AT&T/Canada)
                              @"iPhone5,2" :@"iPhone 5",        // (model A1429, everything else)
                              @"iPad3,4"   :@"iPad",            // (4th Generation)
                              @"iPad2,5"   :@"iPad Mini",       // (Original)
                              @"iPhone5,3" :@"iPhone 5c",       // (model A1456, A1532 | GSM)
                              @"iPhone5,4" :@"iPhone 5c",       // (model A1507, A1516, A1526 (China), A1529 | Global)
                              @"iPhone6,1" :@"iPhone 5s",       // (model A1433, A1533 | GSM)
                              @"iPhone6,2" :@"iPhone 5s",       // (model A1457, A1518, A1528 (China), A1530 | Global)
                              @"iPad4,1"   :@"iPad Air",        // 5th Generation iPad (iPad Air) - Wifi
                              @"iPad4,2"   :@"iPad Air",        // 5th Generation iPad (iPad Air) - Cellular
                              @"iPad4,4"   :@"iPad Mini",       // (2nd Generation iPad Mini - Wifi)
                              @"iPad4,5"   :@"iPad Mini"        // (2nd Generation iPad Mini - Cellular)
                              };
    }
    
    NSString* deviceName = [deviceNamesByCode objectForKey:code];
    
    if (!deviceName) {
        // Not found on database. At least guess main device type from string contents:
        
        if ([code rangeOfString:@"iPod"].location != NSNotFound) {
            deviceName = @"iPod Touch";
        }
        else if([code rangeOfString:@"iPad"].location != NSNotFound) {
            deviceName = @"iPad";
        }
        else if([code rangeOfString:@"iPhone"].location != NSNotFound){
            deviceName = @"iPhone";
        }
    }
    
    return deviceName;
}


+ (NSInteger)hexValueForColor:(UIColor *)color
{
    CGColorRef colorref = [color CGColor];
    
    size_t numComponents = CGColorGetNumberOfComponents(colorref);
    
    int hexValue = 0;
    
    if (numComponents >= 3) {
        const CGFloat *components = CGColorGetComponents(colorref);
        int red     = ((int)(components[0] * 255.0) << 16) & 0xFF0000;
        int green   = ((int)(components[1] * 255.0) << 8) & 0xFF00;
        int blue    = (int)(components[2] * 255.0) & 0xFF;
        
        hexValue =  red | green | blue;
    }
    
    return hexValue;
}

+ (UIColor *)colorForRGBValue:(NSInteger)rgbValue
{
    return  [UIColor
             colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0
             green:((float)((rgbValue & 0xFF00) >> 8))/255.0
             blue:((float)(rgbValue & 0xFF))/255.0
             alpha:1.0];
}

+ (void)writeToUserDefaultsObject:(id)object key:(NSString *)key
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setObject:object forKey:key];
    
    [defaults synchronize];
}

+ (id)readFromUserDefaultsForKey:(NSString *)key
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:key];
}

@end


void dispatch_sync_safe_to_main_queue(dispatch_block_t block) {
    if ([NSThread isMainThread]) {
        block();
    }
    else {
        dispatch_sync(dispatch_get_main_queue(), block);
    }
}

void dispatch_sync_safe(dispatch_queue_t queue, dispatch_block_t block) {
    if (dispatch_get_current_queue() == queue) {
        block();
    }
    else {
        dispatch_sync(queue, block);
    }
}

void dispatch_after_simple(double delayInSeconds, dispatch_block_t block) {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC)), dispatch_get_main_queue(), block);
}

NSInteger BitMaskWithFlag(NSInteger mask, BOOL flag, NSInteger positions) {
    if (flag) {
        mask |= positions;
    }
    else {
        mask &= ~positions;
    }
    return mask;
}


#pragma mark - Base64 encoding

static char base64[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
"abcdefghijklmnopqrstuvwxyz"
"0123456789"
"+/";

int base64encode(unsigned s_len, char *src, unsigned d_len, char *dst)
{
    unsigned triad;
    
    for (triad = 0; triad < s_len; triad += 3)
    {
        unsigned long int sr = 0;
        unsigned byte;
        
        for (byte = 0; (byte<3)&&(triad+byte<s_len); ++byte)
        {
            sr <<= 8;
            sr |= (*(src+triad+byte) & 0xff);
        }
        
        sr <<= (6-((8*byte)%6))%6; /*shift left to next 6bit alignment*/
        
        if (d_len < 4) return 1; /* error - dest too short */
        
        *(dst+0) = *(dst+1) = *(dst+2) = *(dst+3) = '=';
        switch(byte)
        {
            case 3:
                *(dst+3) = base64[sr&0x3f];
                sr >>= 6;
            case 2:
                *(dst+2) = base64[sr&0x3f];
                sr >>= 6;
            case 1:
                *(dst+1) = base64[sr&0x3f];
                sr >>= 6;
                *(dst+0) = base64[sr&0x3f];
        }
        dst += 4; d_len -= 4;
    }
    
    return 0;
    
}
