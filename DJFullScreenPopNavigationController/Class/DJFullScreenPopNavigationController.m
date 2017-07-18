//
//  DJFullScreenPopNavigationController.m
//  DJFullScreenPopNavigationController
//
//  Created by Kilolumen on 18/07/2017.
//  Copyright © 2017 kilolumen. All rights reserved.
//

#import "DJFullScreenPopNavigationController.h"
#import "UIViewController+JDSwizzle.h"
#import <objc/runtime.h>


@interface DJFullscreenPopGestureRecognizerDelegate : NSObject <UIGestureRecognizerDelegate>

@property (nonatomic, weak) UINavigationController *dj_navigationController;

@end

@implementation DJFullscreenPopGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)gestureRecognizer {
    if (self.dj_navigationController.viewControllers.count <= 1) {
        return NO;
    }

    UIViewController *topViewController = self.dj_navigationController.viewControllers.lastObject;
    if (!(topViewController.fullScreenPopGestureEnabled)) {
        return NO;
    }

    CGPoint beginningLocation = [gestureRecognizer locationInView:gestureRecognizer.view];
    CGFloat maxAllowedInitialDistance = topViewController.interactivePopMaxAllowedInitialDistanceToLeftEdge;
    if (maxAllowedInitialDistance > 0 && beginningLocation.x > maxAllowedInitialDistance) {
        return NO;
    }

    if ([[self.dj_navigationController valueForKey:@"_isTransitioning"] boolValue]) {
        return NO;
    }

    CGPoint translation = [gestureRecognizer translationInView:gestureRecognizer.view];
    BOOL isLeftToRight = [UIApplication sharedApplication].userInterfaceLayoutDirection == UIUserInterfaceLayoutDirectionLeftToRight;
    CGFloat multiplier = isLeftToRight ? 1 : - 1;
    if ((translation.x * multiplier) <= 0) {
        return NO;
    }
    return YES;
}

@end

@interface DJFullScreenPopNavigationController () <UINavigationControllerDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIPanGestureRecognizer *dj_popPanGesture;

@property (nonatomic, strong) id dj_popGestureDelegate;

@end

@implementation DJFullScreenPopNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.delegate = self;

    self.dj_popGestureDelegate = self.interactivePopGestureRecognizer.delegate;
    SEL action = NSSelectorFromString(@"handleNavigationTransition:");
    self.dj_popPanGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self.dj_popGestureDelegate action:action];
    self.dj_popPanGesture.maximumNumberOfTouches = 1;
    self.dj_popPanGesture.delegate = self.dj_popGestureRecognizerDelegate;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    BOOL isRootVC = viewController == navigationController.viewControllers.firstObject;
    if (viewController.fullScreenPopGestureEnabled) {
        if (isRootVC) {
            [self.interactivePopGestureRecognizer.view removeGestureRecognizer:self.dj_popPanGesture];
        } else {
            [self.interactivePopGestureRecognizer.view addGestureRecognizer:self.dj_popPanGesture];
        }
        self.interactivePopGestureRecognizer.delegate = self.dj_popGestureDelegate;
        self.interactivePopGestureRecognizer.enabled = NO;
    } else {
        [self.interactivePopGestureRecognizer.view removeGestureRecognizer:self.dj_popPanGesture];
        self.interactivePopGestureRecognizer.delaysTouchesBegan = YES;
        self.interactivePopGestureRecognizer.delegate = self;
        self.interactivePopGestureRecognizer.enabled = !isRootVC;
    }
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return (gestureRecognizer == self.interactivePopGestureRecognizer);
}

- (DJFullscreenPopGestureRecognizerDelegate *)dj_popGestureRecognizerDelegate {
    DJFullscreenPopGestureRecognizerDelegate *delegate = objc_getAssociatedObject(self, _cmd);

    if (!delegate) {
        delegate = [[DJFullscreenPopGestureRecognizerDelegate alloc] init];
        delegate.dj_navigationController = self;
        objc_setAssociatedObject(self, _cmd, delegate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return delegate;
}

@end
