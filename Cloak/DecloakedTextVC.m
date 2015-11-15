//
//  DecloakedTextVC.m
//  Cloak
//
//  Created by Victor Zhou on 11/15/15.
//  Copyright © 2015 Victor Zhou. All rights reserved.
//

#import "DecloakedTextVC.h"
#import "Constants.h"

@interface DecloakedTextVC ()

@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;

- (IBAction)done:(id)sender;

@end

@implementation DecloakedTextVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.textView.text = self.decloakedText;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (IBAction)done:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:CLK_NOTIF_RESET_DECLOAK object:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
