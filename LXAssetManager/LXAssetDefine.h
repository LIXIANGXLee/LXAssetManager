//
//  LXAssetDefine.h
//  LXAssetManager
//
//  Created by 李响 on 2021/6/11.
//

#ifndef LXAssetDefine_h
#define LXAssetDefine_h

#define LXWeakObj(o) try{}@finally{} __weak typeof(o) o##Weak = o;
#define LXStrongObj(o) autoreleasepool{} __strong typeof(o) o = o##Weak;

#define ASYNC_THREAD(...) @LXWeakObj(self); \
                    [[LXAssetManager shared].assetThread executeTask:^{ \
                    @LXStrongObj(self); \
                        __VA_ARGS__; \
                    }];

#endif /* LXAssetDefine_h */
