//
//  DecloakVC.m
//  Cloak
//
//  Created by Victor Zhou on 11/14/15.
//  Copyright © 2015 Victor Zhou. All rights reserved.
//

#import "DecloakVC.h"
#import "CloakingManager.h"
#import "DecloakedTextVC.h"
#import "Constants.h"

@interface DecloakVC () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *uploadButton;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *decloakButton;
@property (weak, nonatomic) IBOutlet UILabel *imagePlaceholderLabel;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
- (IBAction)upload:(id)sender;
- (IBAction)decloak:(id)sender;
- (IBAction)back:(id)sender;

@property (nonatomic, strong) UIImagePickerController *imagePicker;
@property (nonatomic, copy) NSString *decloakedText;

@end

@implementation DecloakVC

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetVC) name:CLK_NOTIF_RESET_DECLOAK object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Accessors

- (UIImagePickerController *)imagePicker {
    if (!_imagePicker) {
        _imagePicker = [[UIImagePickerController alloc] init];
        _imagePicker.delegate = self;
        _imagePicker.allowsEditing = NO;
        _imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    return _imagePicker;
}

#pragma mark - UINavigationControllerDelegate

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    self.imageView.image = info[UIImagePickerControllerOriginalImage];
    self.imageView.backgroundColor = [UIColor clearColor];
    self.imagePlaceholderLabel.alpha = 0;
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    self.uploadButton.enabled = NO;
    self.uploadButton.alpha = 0;
    self.decloakButton.enabled = YES;
    self.decloakButton.alpha = 1;
    self.backButton.enabled = YES;
    self.backButton.alpha = 1;
}

#pragma mark - Actions

- (IBAction)upload:(id)sender {
    [self presentViewController:self.imagePicker animated:YES completion:nil];    
}

- (IBAction)decloak:(id)sender {
    //ensure they've selected an image
    if (!self.imageView.image) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:@"Please select an image first." preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    [[CloakingManager sharedManager] decloakTextFromImage:self.imageView.image completion:^(NSString *text) {
        NSLog(@"decloaked text: %@", text);
        self.decloakedText = text;
        [self performSegueWithIdentifier:@"showText" sender:self];
    }];
}

- (IBAction)back:(id)sender {
    if (self.decloakButton.alpha == 1) {
        //in decloak
        
        //animate out
        self.imageView.image = nil;
        self.imageView.backgroundColor = DARK_DARK_GRAY;
        self.decloakButton.enabled = NO;
        self.backButton.enabled = NO;
        [UIView animateWithDuration:0.5 animations:^{
            self.decloakButton.alpha = 0;
            self.backButton.alpha = 0;
        }];
        
        //animate in
        self.uploadButton.enabled = YES;
        [UIView animateWithDuration:0.5 animations:^{
            self.uploadButton.alpha = 1;
            self.imagePlaceholderLabel.alpha = 1;
        }];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showText"]) {
        DecloakedTextVC *vc = (DecloakedTextVC *)[segue destinationViewController];
        vc.decloakedText = self.decloakedText;
    }
}

- (void)resetVC {
    [self back:self];
}

@end
