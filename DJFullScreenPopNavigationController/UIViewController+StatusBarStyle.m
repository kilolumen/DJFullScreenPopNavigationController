//
//  UIViewController+StatusBarStyle.m
//  DJFullScreenPopNavigationController
//
//  Created by Kilolumen on 2017/8/7.
//  Copyright © 2017年 kilolumen. All rights reserved.
//

#import "UIViewController+StatusBarStyle.h"
#import <objc/runtime.h>

@implementation UIViewController (StatusBarStyle)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Method originalMethod = class_getInstanceMethod(self, @selector(preferredStatusBarStyle));
        Method newMethod = class_getInstanceMethod(self, @selector(dj_swizzled_preferredStatusBarStyle));
        if (class_addMethod(self, @selector(preferredStatusBarStyle), method_getImplementation(newMethod), method_getTypeEncoding(newMethod))) {
            class_replaceMethod(self, @selector(dj_swizzled_preferredStatusBarStyle), method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
        } else {
            method_exchangeImplementations(originalMethod, newMethod);
        }
    });
}

- (UIStatusBarStyle)dj_swizzled_preferredStatusBarStyle {
    UIStatusBarStyle style = [self dj_swizzled_preferredStatusBarStyle];
    if (style != UIStatusBarStyleDefault) {
        return style;
    } else {
        return UIStatusBarStyleDefault;
    }
}

@end
