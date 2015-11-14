//
//  MainVC.m
//  Cloak
//
//  Created by Victor Zhou on 11/14/15.
//  Copyright © 2015 Victor Zhou. All rights reserved.
//

#import "MainVC.h"

@interface MainVC () <UITextViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

// Interface Builder
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIButton *uploadButton;
@property (weak, nonatomic) IBOutlet UIButton *cloakButton;
- (IBAction)upload:(id)sender;
- (IBAction)cloak:(id)sender;

@property (nonatomic, strong) UIImagePickerController *imagePicker;
@property (nonatomic, strong) UIImage *selectedImage;

@end

@implementation MainVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

#pragma mark - Accessors

- (UIImagePickerController *)imagePicker {
    if (!_imagePicker) {
        _imagePicker = [[UIImagePickerController alloc] init];
        _imagePicker.delegate = self;
        _imagePicker.allowsEditing = YES;
        _imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    return _imagePicker;
}

#pragma mark - UINavigationControllerDelegate

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    self.selectedImage = info[UIImagePickerControllerEditedImage];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Actions

- (IBAction)upload:(id)sender {
    [self presentViewController:self.imagePicker animated:YES completion:nil];
}

- (IBAction)cloak:(id)sender {
    //ensure they've selected an image
    if (!self.selectedImage) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:@"Please select an image first." preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

@end
