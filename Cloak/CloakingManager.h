//
//  CloakingManager.h
//  Cloak
//
//  Created by Victor Zhou on 11/14/15.
//  Copyright © 2015 Victor Zhou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CloakingManager : NSObject

+ (nonnull instancetype)sharedManager;

- (void)cloakText:(NSString *)text inImage:(UIImage *)image completion:(nullable void (^)(UIImage *cloakedImage))completion;

@end
