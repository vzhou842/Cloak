//
//  CloakingManager.m
//  Cloak
//
//  Created by Victor Zhou on 11/14/15.
//  Copyright © 2015 Victor Zhou. All rights reserved.
//

#import "CloakingManager.h"

@implementation CloakingManager

+ (instancetype)sharedManager {
    static CloakingManager *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (instancetype)init {
    if (self = [super init]) {
        
    }
    return self;
}

- (void)cloakText:(NSString *)text inImage:(UIImage *)image completion:(nullable void (^)(UIImage *cloakedImage))completion {
    NSData *data = [text dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:NO];
    NSString *ascii = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    NSLog(@"ascii: %@", ascii);
    NSString *binary = [self binaryStringForASCII:ascii];
    NSLog(@"binary: %@", binary);
    
    
}

#pragma mark - Helper

- (NSString *)binaryStringForASCII:(NSString *)ascii {
    NSMutableString *returnString = [@"" mutableCopy];
    for (int i = 0; i < [ascii length]; i++) {
        unsigned char character = [ascii characterAtIndex:i];
        // for each bit in a byte extract the bit
        for (int j=0; j < 8; j++) {
            int bit = (character >> j) & 1;
            [returnString appendString:[NSString stringWithFormat:@"%d", bit]];
        }           
    }
    return returnString;
}

@end
