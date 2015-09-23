//
//  UIViewController+Share.h
//  InEvent
//
//  Created by Pedro Góes on 9/22/15.
//  Copyright © 2015 Pedro G√≥es. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (Share)

- (void)shareText:(NSString *)body;
- (void)shareImage:(UIImage *)image;
- (void)shareText:(NSString *)body withImage:(UIImage *)image;
- (void)shareItems:(NSArray *)items;

@end
