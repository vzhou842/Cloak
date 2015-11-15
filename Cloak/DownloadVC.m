//
//  DownloadVC.m
//  Cloak
//
//  Created by Mack on 11/14/15.
//  Copyright © 2015 Victor Zhou. All rights reserved.
//

#import "DownloadVC.h"
@import AssetsLibrary;

@interface DownloadVC ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation DownloadVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.imageView.image = self.downloadImage;
}

- (void)viewDidAppear:(BOOL)animated {
    [self saveImage];
}

-(void)saveImage {
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    UIImage *image = self.downloadImage;
    [library writeImageDataToSavedPhotosAlbum: UIImagePNGRepresentation(image) metadata:nil completionBlock:nil];
    
    UIAlertController* saveAlert = [UIAlertController alertControllerWithTitle:@"Success!" message:@"Cloaked image has been saved to Camera Roll" preferredStyle:UIAlertControllerStyleAlert];
    ;
    UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        [saveAlert dismissViewControllerAnimated:YES completion:nil];
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    [saveAlert addAction:(ok)];
    
    [self presentViewController:saveAlert animated:YES completion:nil];
}


@end
