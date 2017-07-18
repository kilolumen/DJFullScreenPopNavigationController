//
//  DJScrollView.m
//  DJFullScreenPopNavigationController
//
//  Created by Kilolumen on 18/07/2017.
//  Copyright © 2017 kilolumen. All rights reserved.
//

#import "DJScrollView.h"

@implementation DJScrollView

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if (self.contentOffset.x <= 0) {
        if ([otherGestureRecognizer.delegate isKindOfClass:NSClassFromString(@"DJFullscreenPopGestureRecognizerDelegate")]) {
            return YES;
        }
    }
    return NO;
}

@end
