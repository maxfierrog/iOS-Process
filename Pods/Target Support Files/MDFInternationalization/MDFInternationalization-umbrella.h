#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "MDFInternationalization/MDFInternationalization.h"
#import "MDFInternationalization/MDFRTL.h"
#import "MDFInternationalization/NSLocale+MaterialRTL.h"
#import "MDFInternationalization/NSString+MaterialBidi.h"
#import "MDFInternationalization/UIImage+MaterialRTL.h"
#import "MDFInternationalization/UIView+MaterialRTL.h"

FOUNDATION_EXPORT double MDFInternationalizationVersionNumber;
FOUNDATION_EXPORT const unsigned char MDFInternationalizationVersionString[];

