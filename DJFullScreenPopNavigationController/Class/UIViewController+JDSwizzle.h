//
//  UIViewController+JDSwizzle.h
//  DJFullScreenPopNavigationController
//
//  Created by Kilolumen on 18/07/2017.
//  Copyright © 2017 kilolumen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (JDSwizzle)

@property (nonatomic, assign) BOOL interactiveNavigationBarHidden;
@property (nonatomic, assign) BOOL fullScreenPopGestureEnabled;
@property (nonatomic, assign) CGFloat interactivePopMaxAllowedInitialDistanceToLeftEdge;

@end
