//
//  RFImageGeneratorManager.h
//  RFImageGenerator
//
//  Created by Qi Xin on 15/9/2017.
//  Copyright © 2017 Qi Xin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class RFImageInput,RFImageOutput;

typedef void (^GeneratorDefault)(NSData *resultImageData);

typedef void (^GeneratorResized)(RFImageOutput *resultImagesData);

typedef void (^GeneratorBatchResized)(NSArray <RFImageOutput *> *resultImages);


@interface RFImageGeneratorManager : NSObject

/* 图片生成器的初始化方法
 */

+ (RFImageGeneratorManager *)sharedInstance;

/* 生成缩略图，可用于头像、占位图。
 *
 * @param imageData 用于生成图片的原图
 *
 * @param size 生成缩略图的目标尺寸，可以传CGSizeZero，则默认为120 * 120
 *
 * @param completion 完成生成图片的回调
 */
- (void)generateThumbImage:(NSData *)imageData targetSize:(CGSize) size completion:(GeneratorDefault)completion;

/* 生成展示图片，可用于大图查看。
 *
 * @param imageData 用于生成图片的原图
 *
 * @param size 生成缩略图的目标尺寸，可以传CGSizeZero，则默认为1280 * 1280
 *
 * @param completion 完成生成图片的回调
 */
- (void)generatePresentImage:(NSData *)imageData targetSize:(CGSize) size completion:(GeneratorDefault)completion;

/* 生成压缩图，可用于网络发送图片。
 *
 * @param imageData 用于生成图片的原图
 *
 * @param size 生成缩略图的目标尺寸，可以传CGSizeZero，则默认为1280 * 1280
 *
 * @param completion 完成生成图片的回调
 */
- (void)generateCompressionImage:(NSData *)imageData targetSize:(CGSize) size completion:(GeneratorDefault)completion;

/* 同时生成缩略图、展示图、压缩图
 *
 * @param imageInfo 用于生成图片的原图相关信息，其中包括原图，各种目标图尺度，默认同上接口。
 *
 * @param completion 完成生成图片的回调
 */
- (void)generateResizedImage:(RFImageInput *) imageInfo completion:(GeneratorResized)completion;

/* 批量生成缩略图、展示图、压缩图，最多为10张图片，如果图片基于较多可能会影响执行效率。
 *
 * @param imageInfo 用于生成图片的原图相关信息，其中包括原图，各种目标图尺度，默认同上接口。
 *
 * @param completion 完成生成图片的回调
 */
- (void)generateBatchOfResizedImages:(NSArray <RFImageInput *> *)images completion:(GeneratorBatchResized)completion;


@end
