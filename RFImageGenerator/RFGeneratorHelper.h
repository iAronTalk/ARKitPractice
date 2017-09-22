//
//  RFGeneratorHelper.h
//  RFImageGenerator
//
//  Created by Qi Xin on 15/9/2017.
//  Copyright © 2017 Qi Xin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RFGeneratorHelper : NSObject

+ (UIImage *) resizeImage:(UIImage *)image withSize:(CGSize)asize;

+ (UIImage *) resizeImageOverflowShort:(UIImage *)image withSize:(CGSize)asize;

+ (UIImage *) getSubImage:(UIImage *)image mCGRect:(CGRect)mCGRect centerBool:(BOOL)centerBool;

+ (UIImage *) creatThumb:(UIImage *) originalImage targetSize:(CGSize)size;

+ (NSString *) md5DigestForData:(NSData *)data;

@end
