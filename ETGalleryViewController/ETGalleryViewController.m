//
//  ETPhotoGalleryViewController.m
//  InEvent
//
//  Created by Pedro Góes on 9/22/15.
//  Copyright © 2015 Pedro G√≥es. All rights reserved.
//

#import "ETGalleryViewController.h"
#import "ETGalleryViewCell.h"
#import "UIImageView+WebCache.h"
#import "JTSImageViewController.h"
#import "UIViewController+Share.h"

@interface ETGalleryViewController () <JTSImageViewControllerInteractionsDelegate> {
    NSMutableDictionary *imageDictionary;
}

@property (nonatomic, retain) JTSImageViewController *imageViewer;

@end

static NSString *CustomCellIdentifier = @"CustomCellIdentifier";

@implementation ETGalleryViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setMinimumInteritemSpacing:0.0f];
    [flowLayout setMinimumLineSpacing:0.0f];
    
    self = [super initWithCollectionViewLayout:flowLayout];
    if (self) {
        _indicatorColor = [UIColor whiteColor];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    imageDictionary = [NSMutableDictionary dictionaryWithCapacity:2];
    
    // Collection View
    self.collectionView.alwaysBounceVertical = YES;

    // Collection Cell
    [self.collectionView registerNib:[UINib nibWithNibName:@"ETGalleryViewCell" bundle:nil] forCellWithReuseIdentifier:CustomCellIdentifier];
    self.collectionView.pagingEnabled = YES;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Public Methods

- (void)cellDidLongPress:(NSIndexPath *)indexPath {
    [self showAlertControllerForImage:[imageDictionary objectForKey:indexPath]];
}

#pragma mark - Private Methods

- (void)showAlertControllerForImage:(UIImage *)image {
    
    NSString *translationTable = @"ETGalleryViewController";
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Photo", nil) message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"Save to camera roll", translationTable, nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"Share photo", translationTable, nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self shareImage:image];
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil]];
    
    @try {
        NSIndexPath *indexPath = [[imageDictionary allKeysForObject:image] firstObject];
        ETGalleryViewCell *cell = (ETGalleryViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
        [[alertController popoverPresentationController] setSourceView:cell.imageView];
        [[alertController popoverPresentationController] setSourceRect:cell.imageView.bounds];
        [self presentViewController:alertController animated:YES completion:nil];
    }
    @catch (NSException * __unused exception) {
        // Image could not be shared
    }
    
}

#pragma mark - UICollectionView Delegate

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return [_delegate numberOfSectionsInGalleryController:self];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [_delegate galleryController:self numberOfImagesAtSection:section];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    ETGalleryViewCell *cell = (ETGalleryViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:CustomCellIdentifier forIndexPath:indexPath];
    
    [cell.activityIndicator setHidden:YES];
    
    // Get our image path
    NSURL *imageURL = [_delegate galleryController:self urlForImageAtIndexPath:indexPath];
    
    // Know if images have already been loaded
    UIImage *image = [imageDictionary objectForKey:indexPath];
    
    // If our image is invalid, we can skip it
    if (![image isKindOfClass:[NSNull class]]) {
        
        // See if our image has loaded
        BOOL imageLoaded = (image != nil);
    
        // Center our indicator
        [cell.activityIndicator setCenter:cell.contentView.center];
        [cell.activityIndicator setHidden:imageLoaded];
        [cell.activityIndicator setColor:_indicatorColor];
        
        [cell.imageView sd_setImageWithURL:imageURL placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            
            if (image != nil) {
            
                // Save our image for calculations
                [self->imageDictionary setObject:image forKey:indexPath];
                
                // Get calculated size
                CGSize imageSize = [self collectionView:collectionView layout:collectionView.collectionViewLayout sizeForItemAtIndexPath:indexPath];
                
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    // Set image and resize our frame
                    [cell.imageView setImage:image];
                    [cell.imageView setFrame:CGRectMake(cell.imageView.frame.origin.x, cell.imageView.frame.origin.y, imageSize.width, imageSize.height)];
                    
                    // Hide our activity indicator
                    [cell.activityIndicator setHidden:YES];
                });
                
            } else {
                
                // Add null to hide cell
                [self->imageDictionary setObject:[NSNull null] forKey:indexPath];
                
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    // Hide our activity indicator
                    [cell.activityIndicator setHidden:YES];
                });
                
            }
            
            // Reload items after being added
            if (!imageLoaded) [collectionView reloadItemsAtIndexPaths:@[indexPath]];
            
        }];
        
    } else {
        
        // Hide indicator
        [cell.activityIndicator setHidden:YES];
        
    }
    
    cell.delegate = self;
    cell.indexPath = indexPath;
    
    return cell;
    
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UIImage *image = [imageDictionary objectForKey:indexPath];
    CGSize maxSize = [_delegate galleryController:self maximumSizeForImageAtIndexPath:indexPath];
    
    // Hide images that do not exist
    if ([image isKindOfClass:[NSNull class]]) {
        return CGSizeZero;
        
    } else if (image != nil) {
        
        // See if bounds are larger and resize
        if (image.size.width > maxSize.width || image.size.height > maxSize.height) {
            CGFloat widthRatio = image.size.width / maxSize.width;
            CGFloat heightRatio = image.size.height / maxSize.height;
            
            // Calculate image to its smaller size
            if (widthRatio < heightRatio) {
                return CGSizeMake(image.size.width / heightRatio, image.size.height / heightRatio);
            } else {
                return CGSizeMake(image.size.width / widthRatio, image.size.height / widthRatio);
            }
            
        } else {
            return image.size;
        }
        
    } else {
        // Return our maximum size by default
        return maxSize;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    // Alert our delegate
    if ([_delegate respondsToSelector:@selector(galleryController:imageTappedAtIndexPath:)]) {
        [_delegate galleryController:self imageTappedAtIndexPath:indexPath];
    }
    
    // Run our preview on screen
    // Create image info
    JTSImageInfo *imageInfo = [[JTSImageInfo alloc] init];
    imageInfo.imageURL = [_delegate galleryController:self urlForImageAtIndexPath:indexPath];
    imageInfo.referenceRect = self.view.frame;
    imageInfo.referenceView = self.view;
    
    // Setup view controller
    _imageViewer = [[JTSImageViewController alloc] initWithImageInfo:imageInfo mode:JTSImageViewControllerMode_Image backgroundStyle:JTSImageViewControllerBackgroundOption_Scaled];
    _imageViewer.interactionsDelegate = self;
    
    // Present the view controller.
    [_imageViewer showFromViewController:self transition:JTSImageViewControllerTransition_FromOffscreen];
}

#pragma mark - JTSImageViewController Delegate

- (void)imageViewerDidLongPress:(JTSImageViewController *)imageViewer atRect:(CGRect)rect {
    
    [imageViewer dismiss:YES];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.0f * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self showAlertControllerForImage:self->_imageViewer.image];
    });
}

@end
