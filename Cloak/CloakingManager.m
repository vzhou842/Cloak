//
//  CloakingManager.m
//  Cloak
//
//  Created by Victor Zhou on 11/14/15.
//  Copyright © 2015 Victor Zhou. All rights reserved.
//

#import "CloakingManager.h"

static NSUInteger bytesPerPixel = 4;
static NSUInteger bitsPerComponent = 8;

static int bitsForLength = 16;

static NSString *const kCLKEncryptionSalt = @"10001010101011001100111010";

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
    NSString *binary = [self binaryStringForASCII:ascii];
    
    // encrpyt only the binary, not the length
    binary = [self encryptedBinaryFromString:binary];
    
    // store length of binary at beginning
    binary = [NSString stringWithFormat:@"%@%@", [self binaryStringForNSUInteger:binary.length], binary];
    
    // Convert UIImage to raw data
    CGImageRef imageRef = [image CGImage];
    NSUInteger width = CGImageGetWidth(imageRef);
    NSUInteger height = CGImageGetHeight(imageRef);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char *rawData = (unsigned char *) calloc(height * width * 4, sizeof(unsigned char));
    NSUInteger bytesPerRow = bytesPerPixel * width;
    CGContextRef context = CGBitmapContextCreate(rawData, width, height,
                                                 bitsPerComponent, bytesPerRow, colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    
    // Cloak binary into pixels
    int i = -1;
    int currentIndex = 0;
    while (currentIndex < binary.length)
    {
        i++;
        if (i % 4 == 3) {
            rawData[i] = 255;
            continue; //alpha channel
        }
        ////NSLog(@"old raw data[%d]: %d", i, (int)rawData[i]);
        rawData[i] = [self cloakedByteFromByte:rawData[i] withDigit:([binary characterAtIndex:currentIndex] == '1')];
        //NSLog(@"new raw data[%d]: %d", i, (int)rawData[i]);
        ////NSLog(@"trying to store digit: %d", ([binary characterAtIndex:i] == '1'));
        //rawData[i] = (i % 4 == 3) ? 255 : 0;
        currentIndex++;
    }
    
    //make it back into a UIImage
    UIImage *newImage = [[UIImage alloc] initWithCGImage:CGBitmapContextCreateImage(context)];
    
    CGContextRelease(context);
    free(rawData);
    
    if (completion) {
        completion(newImage);
    }
}

- (void)decloakTextFromImage:(UIImage *)image completion:(nullable void (^)(NSString *text))completion {
    // Convert UIImage to raw data
    CGImageRef imageRef = [image CGImage];
    NSUInteger width = CGImageGetWidth(imageRef);
    NSUInteger height = CGImageGetHeight(imageRef);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char *rawData = (unsigned char *) calloc(height * width * 4, sizeof(unsigned char));
    NSUInteger bytesPerRow = bytesPerPixel * width;
    CGContextRef context = CGBitmapContextCreate(rawData, width, height,
                                                 bitsPerComponent, bytesPerRow, colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    CGContextRelease(context);
    
    // Get length of binary text
    NSMutableString *lengthString = [NSMutableString new];
    int i = -1;
    while (lengthString.length < bitsForLength) {
        i++;
        if (i % 4 == 3) continue; //alpha channel
        //NSLog(@"rawData[%d]: %d", i, (int)rawData[i]);
        [lengthString appendString:[self lastBitFromByte:rawData[i]] ? @"1" : @"0"];
    }
    int length = [self intForBinaryString:lengthString];
    
    // round up to nearest multiple of 8 length
    if (length % bitsPerComponent != 0) {
        length += bitsPerComponentg - (length % bitsPerComponent);
    }
    
    // Reconstruct hidden data
    NSMutableString *dataString = [NSMutableString new];
    while (dataString.length < length) {
        i++;
        if (i % 4 == 3) continue; //alpha channel
        [dataString appendString:[self lastBitFromByte:rawData[i]] ? @"1" : @"0"];
    }
    
    // Decrypt the binary data
    NSString *decrypted = [self decryptedBinaryFromString:dataString];
    
    NSString *ascii = [self asciiForBinaryString:decrypted];
    
    if (completion) {
        completion(ascii);
    }
    
    free(rawData);
}

#pragma mark - Encryption

- (NSString *)encryptedBinaryFromString:(NSString *)string {
    return [self XORString:string withString:kCLKEncryptionSalt];
}

- (NSString *)decryptedBinaryFromString:(NSString *)string {
    return [self XORString:string withString:kCLKEncryptionSalt];
}

- (NSString *)XORString:(NSString *)string withString:(NSString *)salt {
    int saltIndex = 0;
    int stringIndex = 0;
    NSMutableString *encrypted = [NSMutableString new];
    while (stringIndex < string.length) {
        if ([string characterAtIndex:stringIndex] == [salt characterAtIndex:saltIndex]) {
            [encrypted appendString:@"0"];
        } else {
            [encrypted appendString:@"1"];
        }
        stringIndex++;
        saltIndex = (saltIndex + 1) % salt.length;
    }
    return [encrypted copy];
}

#pragma mark - Helper

- (unsigned char)cloakedByteFromByte:(unsigned char)original withDigit:(bool)d {
    if (original % 2 == 0 && d) {
        return original+1;
    } else if (original % 2 == 1 && !d) {
        return original-1;
    }
    return original;
}

- (bool)lastBitFromByte:(unsigned char)b {
    return (b % 2 == 1);
}

- (NSString *)binaryStringForASCII:(NSString *)ascii {
    NSMutableString *returnString = [NSMutableString new];
    for (int i = 0; i < [ascii length]; i++) {
        int character = (int)[ascii characterAtIndex:i];
        // for each bit in a byte extract the bit
        for (int j = 0; j < 8; j++) {
            int bit = (character >> j) & 1;
            [returnString insertString:[NSString stringWithFormat:@"%d", bit] atIndex:0];
        }           
    }
    return [returnString copy];
}

- (NSString *)binaryStringForNSUInteger:(NSUInteger)integer {
    NSMutableString *str = [NSMutableString string];
    for (NSInteger i = 0; i < bitsForLength ; i++) {
        // Prepend "0" or "1", depending on the bit
        [str insertString:((integer & 1) ? @"1" : @"0") atIndex:0];
        integer >>= 1;
    }
    return [str copy];
}

- (int)intForBinaryString:(NSString *)string {
    int num = 0;
    for (int i = (int)string.length - 1; i >= 0; i--) {
        num += (int)([string characterAtIndex:i] == '1') << ((int)string.length - 1 - i);
    }
    return num;
}

- (NSString *)asciiForBinaryString:(NSString *)string {
    NSMutableString *ret = [NSMutableString new];
    for (int i = 0; i < string.length; i += bitsPerComponent) {
        int thisChar = 0;
        for (int j = 0; j < bitsPerComponent; j++) {
            thisChar <<= 1;
            unsigned char c = [string characterAtIndex:i+j];
            thisChar = (thisChar + (int)(c == '1'));
        }
        [ret insertString:[NSString stringWithFormat:@"%c", (char)thisChar] atIndex:0];
    }
    return ret;
}

@end
