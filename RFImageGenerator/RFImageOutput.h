//
//  RFImageOutput.h
//  RFImageGenerator
//
//  Created by Qi Xin on 15/9/2017.
//  Copyright © 2017 Qi Xin. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>

@interface RFImageOutput : NSObject

@property (nullable, nonatomic, strong) NSData *thumbImageData;

@property (nullable, nonatomic, strong) NSData *presentImageData;

@property (nullable, nonatomic, strong) NSData *compressionImageData;

+ (RFImageOutput *_Nullable)outputImageInfo:(NSData *_Nullable)thumbData present:(NSData *_Nullable)presentData  compression:(NSData *_Nullable)compressionData;

@end
