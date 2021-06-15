//
//  LXAssetDefine.h
//  LXAssetManager
//
//  Created by 李响 on 2021/6/11.
//

#ifndef LXAssetDefine_h
#define LXAssetDefine_h

#define SCREEN_WDITH_A [[UIScreen mainScreen] bounds].size.width

#define LXWeakObj(o) try{}@finally{} __weak typeof(o) o##Weak = o;
#define LXStrongObj(o) autoreleasepool{} __strong typeof(o) o = o##Weak;

#define ASYNC_THREAD(...) \
        dispatch_async(self.fetchQueue, ^{ \
            __VA_ARGS__; \
        });

#define ASYNC_MAINTHREAD(...) \
        dispatch_async(dispatch_get_main_queue(), ^{ \
           __VA_ARGS__; \
        });

#endif /* LXAssetDefine_h */
