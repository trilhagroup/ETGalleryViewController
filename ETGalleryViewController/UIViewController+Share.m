//
//  UIViewController+Share.m
//  InEvent
//
//  Created by Pedro Góes on 9/22/15.
//  Copyright © 2015 Pedro G√≥es. All rights reserved.
//

#import <objc/runtime.h>
#import "UIViewController+Share.h"
#import "EmailActivity.h"
#import "FacebookActivity.h"
#import "MessengerActivity.h"
#import "TwitterActivity.h"
#import "WhatsActivity.h"
#import "InstagramActivity.h"

@interface UIViewController (Category) <UIPopoverControllerDelegate>

@property (strong, nonatomic) UIPopoverController *popover;

@end

@implementation UIViewController (Share)

- (void)shareText:(NSString *)body {
    [self shareItems:@[body]];
}

- (void)shareImage:(UIImage *)image {
    [self shareItems:@[image]];
}

- (void)shareText:(NSString *)body withImage:(UIImage *)image {
    [self shareItems:@[body, image]];
}

- (void)shareItems:(NSArray *)items {
    
    // Create activities
    InstagramActivity *instagramActivity = [InstagramActivity sharedInstance];
    FacebookActivity *fbActivity = [[FacebookActivity alloc] init];
    WhatsActivity *whatsActivity = [[WhatsActivity alloc] init];
    EmailActivity *emailActivity = [[EmailActivity alloc] init];
    MessengerActivity *messengerActivity = [[MessengerActivity alloc] init];
    TwitterActivity *twActivity = [[TwitterActivity alloc] init];
    
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:items applicationActivities:@[instagramActivity, fbActivity, whatsActivity, emailActivity, messengerActivity, twActivity]];
    activityViewController.excludedActivityTypes = @[UIActivityTypePostToFacebook, UIActivityTypePostToTwitter, UIActivityTypePostToWeibo, UIActivityTypeMessage, UIActivityTypeMail, UIActivityTypePrint, UIActivityTypeCopyToPasteboard, UIActivityTypeAssignToContact, UIActivityTypeSaveToCameraRoll, UIActivityTypeAddToReadingList, UIActivityTypePostToFlickr, UIActivityTypePostToVimeo, UIActivityTypePostToTencentWeibo, UIActivityTypeAirDrop];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [self presentViewController:activityViewController animated:YES completion:nil];
    } else {
        [self setPopover:[[UIPopoverController alloc] initWithContentViewController:activityViewController]];
        [[self popover] setDelegate:self];
        [[self popover] presentPopoverFromRect:CGRectMake(0.0f, self.view.frame.size.height - 100.0f, self.view.frame.size.width, 100.0f) inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
}

- (UIPopoverController*)popover {
    return objc_getAssociatedObject(self, @selector(popover));
}

- (void)setPopover:(UIPopoverController *)popover {
    objc_setAssociatedObject(self, @selector(popover), popover, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
