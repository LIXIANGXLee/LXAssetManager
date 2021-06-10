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

#import "LXAssetCloud.h"
#import "LXAssetCollection.h"
#import "LXAssetItem.h"
#import "LXAssetManager.h"
#import "LXAssetSave.h"
#import "LXAuthorManager.h"

FOUNDATION_EXPORT double LXAssetManagerVersionNumber;
FOUNDATION_EXPORT const unsigned char LXAssetManagerVersionString[];

