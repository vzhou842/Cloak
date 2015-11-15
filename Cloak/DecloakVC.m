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

@interface DecloakVC () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *uploadButton;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *decloakButton;
- (IBAction)upload:(id)sender;
- (IBAction)decloak:(id)sender;

@property (nonatomic, strong) UIImagePickerController *imagePicker;
@property (nonatomic, copy) NSString *decloakedText;

@end

@implementation DecloakVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showText"]) {
        DecloakedTextVC *vc = (DecloakedTextVC *)[segue destinationViewController];
        vc.decloakedText = self.decloakedText;
    }
}

@end
