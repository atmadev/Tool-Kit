//
//  TKUtilities.h
//  Tool Kit
//
//  Created by Alexander Koryttsev on 3/5/14.
//  Copyright (c) 2014 Alexander Koryttsev. All rights reserved.
//

#import <Foundation/Foundation.h>


#define IS_IPAD ( isIPad() )
#define IS_IPHONE ( isIPhone() )
#define IS_HEIGHT_GTE_568 [[UIScreen mainScreen ] bounds].size.height >= 568.0f

#define IS_IPHONE_5 ( IS_IPHONE && IS_HEIGHT_GTE_568 )


BOOL        isIPad(void);
BOOL        isIPhone(void);
CGFloat     screenScale(void);
CGSize      scaledSize(CGSize size);
BOOL        isRetina(void);
BOOL        hasFourInchDisplay (void);
BOOL        hasIOS7orLater (void);
BOOL        isIOS7OrLater(void);
BOOL        deviceHasCamera();
CGAffineTransform transformForCurrentOrientation(void);
CGAffineTransform transformForOrientation(UIInterfaceOrientation orientation);


@interface TKUtilities : NSObject

+ (NSInteger)hexValueForColor:(UIColor *)color;
+ (UIColor *)colorForRGBValue:(NSInteger)rgbValue;
+ (void)writeToUserDefaultsObject:(id)object key:(NSString *)key;
+ (id)readFromUserDefaultsForKey:(NSString *)key;

+ (NSString*) deviceName;


@end


void dispatch_sync_safe_to_main_queue(dispatch_block_t block);
void dispatch_sync_safe(dispatch_queue_t queue, dispatch_block_t block);
void dispatch_after_simple(double delayInSeconds, dispatch_block_t block);

NSInteger BitMaskWithFlag(NSInteger mask, BOOL flag, NSInteger positions);


int base64encode(unsigned s_len, char *src, unsigned d_len, char *dst);
