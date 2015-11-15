//
//  CloakVC.m
//  Cloak
//
//  Created by Victor Zhou on 11/14/15.
//  Copyright © 2015 Victor Zhou. All rights reserved.
//

#import "CloakVC.h"
#import "CloakingManager.h"
#import "DownloadVC.h"

@interface CloakVC () <UITextViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

// Interface Builder
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *uploadButton;
@property (weak, nonatomic) IBOutlet UIButton *cloakButton;
@property (strong, nonatomic) IBOutlet UILabel *uploadText;
- (IBAction)upload:(id)sender;
- (IBAction)cloak:(id)sender;

@property (nonatomic, strong) UIImagePickerController *imagePicker;
@property (nonatomic, strong) UIImage *cloakedImage;

@end

@implementation CloakVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
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
    self.imageView.image = info[UIImagePickerControllerEditedImage];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Actions

- (IBAction)upload:(id)sender {
    [self presentViewController:self.imagePicker animated:YES completion:nil];
    self.uploadText.hidden = YES;
}

- (IBAction)cloak:(id)sender {
    //ensure they've entered text
    if (self.textView.text.length == 0) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:@"Please enter text first." preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    //ensure they've selected an image
    if (!self.imageView.image) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:@"Please select an image first." preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    [[CloakingManager sharedManager] cloakText:self.textView.text inImage:self.imageView.image completion:^(UIImage *cloakedImage) {
        self.cloakedImage = cloakedImage;
        [self performSegueWithIdentifier:@"showDownload" sender:self];
    }];
}

-(void)dismissKeyboard {
    [self.textView resignFirstResponder];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showDownload"]) {
        DownloadVC *vc = (DownloadVC *)[segue destinationViewController];
        vc.downloadImage = self.cloakedImage;
    }
}




@end
