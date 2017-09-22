//
//  RFGeneratorHelper.m
//  RFImageGenerator
//
//  Created by Qi Xin on 15/9/2017.
//  Copyright © 2017 Qi Xin. All rights reserved.
//

#import "RFGeneratorHelper.h"

#import <CommonCrypto/CommonCrypto.h>

@implementation RFGeneratorHelper

+ (UIImage *)resizeImage:(UIImage *)image withSize:(CGSize)asize
{
    CGSize size = asize;
    
    if (image.size.width > size.width || image.size.height > size.height)
    {
        CGFloat scale;
        
        CGSize newSize = image.size;
        
        if (newSize.height && (newSize.height > size.height))
        {
            scale = size.height / newSize.height;
            newSize.height = size.height;
            newSize.width *= scale;
        }
        if (newSize.width && (newSize.width > size.width))
        {
            scale = size.width / newSize.width;
            newSize.height *= scale;
            newSize.width = size.width;
        }
        
        UIGraphicsBeginImageContext(newSize);
        //
        //        CGContextRef ctx = UIGraphicsGetCurrentContext();
        
        [image drawInRect:CGRectMake(0.0, 0.0, newSize.width, newSize.height)];
        
        image = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
    }
    
    return image;
}

+ (UIImage *)resizeImageOverflowShort:(UIImage *)image withSize:(CGSize)asize
{
    NSInteger imageMin = MIN(image.size.width, image.size.height);
    
    NSInteger imageMax = MAX(image.size.width, image.size.height);
    
    CGSize newSize;
    
    if (imageMin > MAX(asize.height, asize.width))
    {
        CGFloat scale = imageMin / imageMax;
        
        NSInteger height;
        
        NSInteger width;
        
        if (image.size.width > image.size.height)
        {
            height = MAX(asize.height, asize.width);
            
            width = MAX(asize.height, asize.width) / scale;
        }
        else
        {
            width = MAX(asize.height, asize.width);
            
            height = MAX(asize.height, asize.width) / scale;
        }
        
        newSize = CGSizeMake(width, height);
        
        UIGraphicsBeginImageContext(newSize);
        
        [image drawInRect:CGRectMake(0.0, 0.0, newSize.width, newSize.height)];
        
        image = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
    }
    
    return image;
}

+(UIImage*)getSubImage:(UIImage *)image mCGRect:(CGRect)mCGRect centerBool:(BOOL)centerBool
{
    /*如若centerBool为Yes则是由中心点取mCGRect范围的图片*/
    float imgwidth = image.size.width;
    float imgheight = image.size.height;
    float viewwidth = mCGRect.size.width;
    float viewheight = mCGRect.size.height;
    CGRect rect;
    if(centerBool)
        rect = CGRectMake((imgwidth-viewwidth)/2, (imgheight-viewheight)/2, viewwidth, viewheight);
    else{
        if (viewheight < viewwidth) {
            if (imgwidth <= imgheight) {
                rect = CGRectMake(0, 0, imgwidth, imgwidth*viewheight/viewwidth);
            }else {
                float width = viewwidth*imgheight/viewheight;
                float x = (imgwidth - width)/2 ;
                if (x > 0) {
                    rect = CGRectMake(x, 0, width, imgheight);
                }else {
                    rect = CGRectMake(0, 0, imgwidth, imgwidth*viewheight/viewwidth);
                }
            }
        }else {
            if (imgwidth <= imgheight) {
                float height = viewheight*imgwidth/viewwidth;
                if (height < imgheight) {
                    rect = CGRectMake(0, 0, imgwidth, height);
                }else {
                    rect = CGRectMake(0, 0, viewwidth*imgheight/viewheight, imgheight);
                }
            }else {
                float width = viewwidth*imgheight/viewheight;
                if (width < imgwidth) {
                    float x = (imgwidth - width)/2 ;
                    rect = CGRectMake(x, 0, width, imgheight);
                }else {
                    rect = CGRectMake(0, 0, imgwidth, imgheight);
                }
            }
        }
    }
    
    CGImageRef subImageRef = CGImageCreateWithImageInRect(image.CGImage, rect);
    CGRect smallBounds = CGRectMake(0, 0, CGImageGetWidth(subImageRef), CGImageGetHeight(subImageRef));
    
    UIGraphicsBeginImageContext(smallBounds.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextDrawImage(context, smallBounds, subImageRef);
    UIImage* smallImage = [UIImage imageWithCGImage:subImageRef];
    CGImageRelease(subImageRef);
    UIGraphicsEndImageContext();
    
    return smallImage;
}

+ (UIImage *) creatThumb:(UIImage *) originalImage targetSize:(CGSize)size;
{
    double rateW = size.width / originalImage.size.width;
    
    double rateH = size.height / originalImage.size.height;
    
    double rate = rateW < rateH ? rateW : rateH;
    
    CGRect rect = CGRectIntegral(CGRectMake(0, 0,rate * originalImage.size.width ,rate * originalImage.size.height));
    
    UIGraphicsBeginImageContext(rect.size);
    
    [originalImage drawInRect:rect];
    
    UIImage *thumb = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return thumb;
}

+ (NSString *) md5DigestForData:(NSData *)data
{
    unsigned char md[CC_MD5_DIGEST_LENGTH];
    
    memset(md, 0, sizeof(md));
    
    unsigned char *status = CC_MD5(data.bytes, (unsigned int) data.length, md);
    
    NSMutableString *string = [NSMutableString string];
    
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i ++)
    {
        [string appendFormat:@"%02X", status[i] & 0xFF];
    }
    
    return string;
}
@end
