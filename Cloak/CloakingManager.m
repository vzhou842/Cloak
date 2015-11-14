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
    
}

@end
