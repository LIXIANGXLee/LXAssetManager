//
//  LXObjcProxy.m
//  LXAssetManager
//
//  Created by Mac on 2020/9/26.
//  Copyright © 2020 李响. All rights reserved.
//

#import "LXAssetProxy.h"

@implementation LXAssetProxy

+ (instancetype)proxyWithTarget:(id)target{
    LXAssetProxy *proxy = [LXAssetProxy alloc];
    proxy.target = target;
    return proxy;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel{
    return [self.target methodSignatureForSelector:sel];
}

- (void)forwardInvocation:(NSInvocation *)invocation{
    [invocation invokeWithTarget:self.target];
}

@end
