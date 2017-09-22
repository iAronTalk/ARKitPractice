//
//  RFImageInput.m
//  RFImageGenerator
//
//  Created by Qi Xin on 15/9/2017.
//  Copyright © 2017 Qi Xin. All rights reserved.
//

#import "RFImageInput.h"

@implementation RFImageInput

+ (RFImageInput *)imageInfo:(NSData *)originalData thumb:(CGSize)thumbSize present:(CGSize)presentSize compression:(CGSize)compressionSize
{
    RFImageInput *info = [[RFImageInput alloc] init];
    
    info.imageData = originalData;
    
    info.thumbSize = thumbSize;
    
    info.presentSize = presentSize;
    
    info.compressionSize = compressionSize;
    
    return info;
}
@end
