//
//  ETGalleryViewController.h
//  InEvent
//
//  Created by Pedro Góes on 9/22/15.
//  Copyright © 2015 Pedro G√≥es. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ETGalleryViewController;

@protocol ETGalleryViewControllerDelegate <NSObject>

@required
- (NSInteger)numberOfSectionsInGalleryController:(ETGalleryViewController *)galleryController;
- (NSInteger)galleryController:(ETGalleryViewController *)galleryController numberOfImagesAtSection:(NSInteger)section;
- (NSURL *)galleryController:(ETGalleryViewController *)galleryController urlForImageAtIndexPath:(NSIndexPath *)indexPath;
- (CGSize)galleryController:(ETGalleryViewController *)galleryController maximumSizeForImageAtIndexPath:(NSIndexPath *)indexPath;

@optional
- (void)galleryController:(ETGalleryViewController *)galleryController imageTappedAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface ETGalleryViewController : UICollectionViewController

@property (strong, nonatomic) id<ETGalleryViewControllerDelegate> delegate;
@property (strong, nonatomic) UIColor *indicatorColor;

@end
