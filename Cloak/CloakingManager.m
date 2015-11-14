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
    
    // Convert UIImage to raw data
    CGImageRef imageRef = [image CGImage];
    NSUInteger width = CGImageGetWidth(imageRef);
    NSUInteger height = CGImageGetHeight(imageRef);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char *rawData = (unsigned char *) calloc(height * width * 4, sizeof(unsigned char));
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    CGContextRef context = CGBitmapContextCreate(rawData, width, height,
                                                 bitsPerComponent, bytesPerRow, colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    
    // Cloak binary into pixels
    for (int i = 0; i < MIN(width*height, binary.length); i++)
    {
        rawData[i] = [self cloakedByteFromByte:rawData[i] withDigit:([binary characterAtIndex:i] == '1')];
    }
    
    //make it back into a UIImage
    UIImage *newImage = [[UIImage alloc] initWithCGImage:CGBitmapContextCreateImage(context)];
    
    CGContextRelease(context);
    free(rawData);
    
    if (completion) {
        completion(newImage);
    }
}

#pragma mark - Helper

- (unsigned char)cloakedByteFromByte:(unsigned char)original withDigit:(bool)d {
    if (original % 2 == 0 && d) {
        original++;
    } else if (original % 2 == 1 && !d) {
        original--;
    }
    return original;
}

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
