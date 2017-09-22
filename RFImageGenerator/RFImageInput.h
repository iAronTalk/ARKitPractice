//
//  RFImageInput.h
//  RFImageGenerator
//
//  Created by Qi Xin on 15/9/2017.
//  Copyright © 2017 Qi Xin. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>

@interface RFImageInput : NSObject

@property (nonatomic, assign) CGSize originalSize;

@property (nonnull, nonatomic, strong) NSData *imageData;

@property (nonatomic, assign) CGSize thumbSize;

@property (nonatomic, assign) CGSize presentSize;

@property (nonatomic, assign) CGSize compressionSize;

+ (RFImageInput *_Nullable)imageInfo:(NSData *_Nullable)originalData thumb:(CGSize)thumbSize present:(CGSize)presentSize compression:(CGSize)compressionSize;

@end
