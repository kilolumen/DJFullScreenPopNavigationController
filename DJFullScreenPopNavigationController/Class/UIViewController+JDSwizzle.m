//
//  UIViewController+JDSwizzle.m
//  DJFullScreenPopNavigationController
//
//  Created by Kilolumen on 18/07/2017.
//  Copyright © 2017 kilolumen. All rights reserved.
//

#import "UIViewController+JDSwizzle.h"
#import <objc/runtime.h>


static void *DJInteractiveNavigationBarHiddenAssociationKey = &DJInteractiveNavigationBarHiddenAssociationKey;
static void *DJFullScreenPopGestureEnabledAssociationKey = &DJFullScreenPopGestureEnabledAssociationKey;
static void *DJFullScreenPopGestureDistanceToLeftEdgeAssociationKey = &DJFullScreenPopGestureDistanceToLeftEdgeAssociationKey;

static void swizzle_selector(Class class, SEL original, SEL new) {
    Method originalMethod = class_getInstanceMethod(class, original);
    Method newMethod = class_getInstanceMethod(class, new);
    if (class_addMethod(class, original, method_getImplementation(  newMethod), method_getTypeEncoding(newMethod))) {
        class_replaceMethod(class, new, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, newMethod);
    }
}

@implementation UIViewController (JDSwizzle)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        swizzle_selector(self, @selector(viewWillAppear:), @selector(dj_swizzled_viewWillAppear:));
        swizzle_selector(self, @selector(viewWillDisappear:), @selector(dj_swizzled_viewWillDisappear:));
    });
}

- (void)dj_swizzled_viewWillAppear:(BOOL)animated {
    [self dj_swizzled_viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:self.interactiveNavigationBarHidden animated:animated];
}

- (void)dj_swizzled_viewWillDisappear:(BOOL)animated {
    [self dj_swizzled_viewWillDisappear:animated];
    // fix Navigation bar hidden when switch status bar 
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIViewController *viewController = self.navigationController.viewControllers.lastObject;
        if (viewController && !viewController.interactiveNavigationBarHidden) {
            [self.navigationController setNavigationBarHidden:NO animated:NO];
        }
    });

}

#pragma mark - Setter and Getter
- (void)setInteractiveNavigationBarHidden:(BOOL)interactiveNavigationBarHidden {
    objc_setAssociatedObject(self, DJInteractiveNavigationBarHiddenAssociationKey, @(interactiveNavigationBarHidden), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)interactiveNavigationBarHidden {
    return [(NSNumber *)objc_getAssociatedObject(self, DJInteractiveNavigationBarHiddenAssociationKey) boolValue];
}

- (void)setFullScreenPopGestureEnabled:(BOOL)fullScreenPopGestureEnabled {
    objc_setAssociatedObject(self, DJFullScreenPopGestureEnabledAssociationKey, @(fullScreenPopGestureEnabled), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)fullScreenPopGestureEnabled {
    return [(NSNumber *)objc_getAssociatedObject(self, DJFullScreenPopGestureEnabledAssociationKey) boolValue];
}

- (void)setInteractivePopMaxAllowedInitialDistanceToLeftEdge:(CGFloat)interactivePopMaxAllowedInitialDistanceToLeftEdge {
    objc_setAssociatedObject(self, DJFullScreenPopGestureDistanceToLeftEdgeAssociationKey, @(interactivePopMaxAllowedInitialDistanceToLeftEdge), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGFloat)interactivePopMaxAllowedInitialDistanceToLeftEdge {
    return [objc_getAssociatedObject(self, DJFullScreenPopGestureDistanceToLeftEdgeAssociationKey) floatValue];
}

@end
