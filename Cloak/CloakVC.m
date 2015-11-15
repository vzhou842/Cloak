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
#import "UITextView+Placeholder.h"
#import "Constants.h"

@interface CloakVC () <UITextViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

// Interface Builder
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *uploadButton;
@property (weak, nonatomic) IBOutlet UIButton *cloakButton;
@property (weak, nonatomic) IBOutlet UIButton *continueButton;
@property (strong, nonatomic) IBOutlet UILabel *uploadText;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIView *divider;
- (IBAction)upload:(id)sender;
- (IBAction)cloak:(id)sender;
- (IBAction)continuePressed:(id)sender;
- (IBAction)back:(id)sender;

@property (nonatomic, strong) UIImagePickerController *imagePicker;
@property (nonatomic, strong) UIImage *cloakedImage;
@property (nonatomic, strong) UISwipeGestureRecognizer *swipeRecognizer;

@end

@implementation CloakVC

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
    [self.view addGestureRecognizer:self.swipeRecognizer];
    
    self.textView.placeholder = @"Type or Paste any sensitive text that you want hidden here.";
    self.textView.placeholderColor = [UIColor lightGrayColor];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetVC) name:CLK_NOTIF_RESET_CLOAK object:nil];
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

- (UISwipeGestureRecognizer *)swipeRecognizer {
    if (!_swipeRecognizer) {
        _swipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
        _swipeRecognizer.direction = UISwipeGestureRecognizerDirectionDown;
    }
    return _swipeRecognizer;
}

#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView {
    self.divider.alpha = (textView.text.length > 0) ? 1 : 0;
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    self.imageView.image = info[UIImagePickerControllerEditedImage];
    self.imageView.backgroundColor = [UIColor clearColor];
    [picker dismissViewControllerAnimated:YES completion:nil];
    self.uploadText.alpha = 0;
    
    self.uploadButton.alpha = 0;
    self.uploadButton.enabled = NO;
    self.cloakButton.alpha = 1;
    self.cloakButton.enabled = YES;
}

#pragma mark - Actions

- (IBAction)upload:(id)sender {
    [self presentViewController:self.imagePicker animated:YES completion:nil];
    
}

- (IBAction)cloak:(id)sender {
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

- (IBAction)continuePressed:(id)sender {
    //ensure they've entered text
    if (self.textView.text.length == 0) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:@"Please enter text first." preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    //animate out
    self.continueButton.enabled = NO;
    self.textView.userInteractionEnabled = NO;
    [UIView animateWithDuration:0.5 animations:^{
        self.continueButton.alpha = 0;
        self.textView.alpha = 0;
        self.divider.alpha = 0;
    }];
    
    //animate in
    self.uploadButton.enabled = YES;
    self.uploadButton.alpha = 0;
    self.imageView.alpha = 0;
    self.uploadText.alpha = 0;
    self.backButton.enabled = YES;
    self.backButton.alpha = 0;
    [UIView animateWithDuration:0.5 animations:^{
        self.uploadButton.alpha = 1;
        self.imageView.alpha = 1;
        self.uploadText.alpha = 1;
        self.backButton.alpha = 1;
    }];
}

- (IBAction)back:(id)sender {
    if (self.uploadButton.alpha == 1) {
        //currently in upload
        
        //animate out
        self.uploadButton.enabled = NO;
        self.backButton.enabled = NO;
        [UIView animateWithDuration:0.5 animations:^{
            self.uploadButton.alpha = 0;
            self.imageView.alpha = 0;
            self.uploadText.alpha = 0;
            self.backButton.alpha = 0;
        }];
        
        //animate in
        self.continueButton.enabled = YES;
        self.textView.userInteractionEnabled = YES;
        [UIView animateWithDuration:0.5 animations:^{
            self.continueButton.alpha = 1;
            self.textView.alpha = 1;
            self.divider.alpha = 1;
        }];
    } else if (self.cloakButton.alpha == 1) {
        //currently in cloak
        
        //animate out
        self.cloakButton.enabled = NO;
        self.imageView.image = nil;
        self.imageView.backgroundColor = DARK_DARK_GRAY;
        [UIView animateWithDuration:0.5 animations:^{
            self.cloakButton.alpha = 0;
        }];
        
        //animate in
        self.uploadButton.enabled = YES;
        [UIView animateWithDuration:0.5 animations:^{
            self.uploadText.alpha = 1;
            self.uploadButton.alpha = 1;
        }];
    }
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

- (void)resetVC {
    [self back:self];
    [self back:self];
    self.textView.text = @"";
    self.divider.alpha = 0;
}

@end
