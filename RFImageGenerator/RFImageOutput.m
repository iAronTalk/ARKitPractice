//
//  RFImageOutput.m
//  RFImageGenerator
//
//  Created by Qi Xin on 15/9/2017.
//  Copyright © 2017 Qi Xin. All rights reserved.
//

#import "RFImageOutput.h"

@implementation RFImageOutput


+ (RFImageOutput *_Nullable)outputImageInfo:(NSData *_Nullable)thumbData present:(NSData *_Nullable)presentData  compression:(NSData *_Nullable)compressionData
{
    RFImageOutput *output = [[RFImageOutput alloc] init];
    
    output.thumbImageData = thumbData;
    
    output.presentImageData = presentData;
    
    output.compressionImageData = compressionData;
    
    return output;
}
@end
