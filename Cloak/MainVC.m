//
//  MainVC.m
//  Cloak
//
//  Created by Victor Zhou on 11/14/15.
//  Copyright © 2015 Victor Zhou. All rights reserved.
//

#import "MainVC.h"

@interface MainVC () <UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIButton *uploadButton;
@property (weak, nonatomic) IBOutlet UIButton *cloakButton;
- (IBAction)upload:(id)sender;
- (IBAction)cloak:(id)sender;

@end

@implementation MainVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

#pragma mark - Actions

- (IBAction)upload:(id)sender {
}

- (IBAction)cloak:(id)sender {
}

@end
