//
//  DownloadVC.m
//  Cloak
//
//  Created by Mack on 11/14/15.
//  Copyright © 2015 Victor Zhou. All rights reserved.
//

#import "DownloadVC.h"

@interface DownloadVC ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@end

@implementation DownloadVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.imageView.image = self.downloadImage;
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
}

@end
