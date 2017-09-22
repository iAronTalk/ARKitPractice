//
//  RFImageGeneratorManager.m
//  RFImageGenerator
//
//  Created by Qi Xin on 15/9/2017.
//  Copyright © 2017 Qi Xin. All rights reserved.
//

#import "RFImageGeneratorManager.h"
#import "RFImageInput.h"
#import "RFImageOutput.h"
#import "RFGeneratorHelper.h"

static const NSInteger RFThumbnailDefaultSideLength = 120;

static const NSInteger RFPresentDefaultSideLength = 800;

static const NSInteger RFCompressionDefaultSideLength = 1280;

static const NSInteger RFSuperSmallImageCriticalValue = 100;

@interface RFImageGeneratorManager()
{
    NSMutableDictionary *thumbImagesCache;
    
    NSMutableDictionary *presentImagesCache;
    
    NSMutableDictionary *compressionImagesCache;
}

@end
@implementation RFImageGeneratorManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        thumbImagesCache = [NSMutableDictionary dictionary];
        
        presentImagesCache =[NSMutableDictionary dictionary];
        
        compressionImagesCache = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)dealloc
{
    thumbImagesCache = nil;
    
    presentImagesCache = nil;
    
    compressionImagesCache = nil;
}

+ (RFImageGeneratorManager *)sharedInstance
{
    static RFImageGeneratorManager *manager = nil;
    static dispatch_once_t token;
    
    dispatch_once(&token, ^{
        manager = [[RFImageGeneratorManager alloc] init];
    });
    
    return manager;
}

- (void)generateThumbImage:(NSData *)imageData targetSize:(CGSize) size completion:(GeneratorDefault)completion
{
    RFImageInput *info =  [RFImageInput imageInfo:imageData thumb:size present:CGSizeZero compression:CGSizeZero];

    [self generateResizedImage:info completion:^(RFImageOutput *resultImagesData) {
        
        completion(resultImagesData.thumbImageData);
    }];
}

- (void)generatePresentImage:(NSData *)imageData targetSize:(CGSize) size completion:(GeneratorDefault)completion
{
    RFImageInput *info =  [RFImageInput imageInfo:imageData thumb:CGSizeZero present:size compression:CGSizeZero];
    
    [self generateResizedImage:info completion:^(RFImageOutput *resultImagesData) {
        
        completion(resultImagesData.presentImageData);
    }];
}

- (void)generateCompressionImage:(NSData *)imageData targetSize:(CGSize) size completion:(GeneratorDefault)completion
{
    RFImageInput *info =  [RFImageInput imageInfo:imageData thumb:CGSizeZero present:CGSizeZero compression:size];
    
    [self generateResizedImage:info completion:^(RFImageOutput *resultImagesData) {
        
        completion(resultImagesData.compressionImageData);
    }];
}

- (void)generateResizedImage:(RFImageInput *) imageInfo completion:(GeneratorResized)completion
{
    dispatch_group_t group = dispatch_group_create();
    
    __block NSData *thumb = nil;
    __block NSData *present = nil;
    __block NSData *compression = nil;
    
    NSString *imageMd5 = [RFGeneratorHelper md5DigestForData:imageInfo.imageData];
    
    dispatch_group_async(group, dispatch_get_global_queue(0, 0), ^{
        
        thumb = [thumbImagesCache objectForKey:imageMd5];
        
        if (!thumb)
        {
            thumb = [self generateThumbImage:imageInfo targetSize:imageInfo.thumbSize];
        }
    });
    
    dispatch_group_async(group, dispatch_get_global_queue(0, 0), ^{
        
        present = [presentImagesCache objectForKey:imageMd5];
        
        if (!present)
        {
            present = [self generatePresentImage:imageInfo targetSize:imageInfo.presentSize];
        }
    });
    
    dispatch_group_async(group, dispatch_get_global_queue(0, 0), ^{
        
        compression = [compressionImagesCache objectForKey:imageMd5];
        
        if (!compression)
        {
            compression = [self generateCompressionImage:imageInfo targetSize:imageInfo.compressionSize];
        }
    });
    
    dispatch_group_notify(group, dispatch_get_global_queue(0, 0), ^{
        
        RFImageOutput *output = [RFImageOutput outputImageInfo:thumb present:present compression:compression];
        
        completion(output);
    });
}

- (void)generateBatchOfResizedImages:(NSArray <RFImageInput *> *)images completion:(GeneratorBatchResized)completion
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        dispatch_group_t group = dispatch_group_create();
        
        dispatch_queue_t queue = dispatch_queue_create("BatchImagesResizeQueue", DISPATCH_QUEUE_CONCURRENT);
        
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        
        __block NSMutableArray <RFImageOutput *> *outputArr = [NSMutableArray array];
        
        [images enumerateObjectsUsingBlock:^(RFImageInput * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            dispatch_group_async(group, queue, ^{
                
                [self generateResizedImage:obj completion:^(RFImageOutput *resultImagesData) {
                    
                    [outputArr addObject:resultImagesData];
                    
                    dispatch_semaphore_signal(semaphore);
                }];
                
                dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            });
        }];
        
        dispatch_group_notify(group, queue, ^{
            
            completion(outputArr);
        });
    });
}

#pragma mark - Private
- (NSData *)generateThumbImage:(RFImageInput *)inputInfo targetSize:(CGSize)size
{
    NSData *output = nil;
    
    CGSize targetSize = CGSizeEqualToSize(size, CGSizeZero)? CGSizeMake(RFThumbnailDefaultSideLength, RFThumbnailDefaultSideLength): CGSizeMake(size.width, size.height);
    
    UIImage * thumb = [RFGeneratorHelper creatThumb:[UIImage imageWithData:inputInfo.imageData] targetSize:targetSize];
    
    output = UIImageJPEGRepresentation(thumb, 0.5);
    
    NSString *thumMd5 = [RFGeneratorHelper md5DigestForData:inputInfo.imageData];
    
    [self checkCacheQuantity];
    
    [thumbImagesCache setObject:output forKey:thumMd5];
    
    return output;
}

- (NSData *)generatePresentImage:(RFImageInput *)inputInfo targetSize:(CGSize)size
{
    NSData *output = nil;
    
    UIImage *original = [UIImage imageWithData:inputInfo.imageData];
    
    CGFloat ratio = inputInfo.originalSize.width/inputInfo.originalSize.height;
    
    CGSize targetSize = CGSizeEqualToSize(size, CGSizeZero)? CGSizeMake(RFPresentDefaultSideLength, RFPresentDefaultSideLength): CGSizeMake(size.width, size.height);
    
    if (ratio < 1/3.0f || ratio > 3)//长图和宽图
    {
        UIImage *tem = [RFGeneratorHelper resizeImageOverflowShort:original withSize:CGSizeMake(1280.0f, 1280.0f)];
        
        NSInteger min = MIN(tem.size.width, tem.size.height);
        NSInteger max = MAX(tem.size.width, tem.size.height);
        
        CGRect subRect;
        if (tem.size.width > tem.size.height)
        {
            subRect = CGRectMake((max - min * 3) / 2.0f, 0.0f, min * 3.0f, min);
        }
        else
        {
            subRect = CGRectMake(0.0f,(max - min * 3) / 2.0f, min, min * 3.0f);
        }
        
        UIImage *presentImage = [RFGeneratorHelper getSubImage:tem mCGRect:subRect centerBool:YES];
        
        output = UIImageJPEGRepresentation(presentImage, 0.5f);
    }
    else
    {
        output = [self generateCompressionImage:inputInfo targetSize:targetSize];
    }
    
    NSString *presentMd5 = [RFGeneratorHelper md5DigestForData:inputInfo.imageData];
    
    [self checkCacheQuantity];
    
    [presentImagesCache setObject:output forKey:presentMd5];
    
    return output;
}

- (NSData *)generateCompressionImage:(RFImageInput *)inputInfo targetSize:(CGSize)size
{
    NSData *output = nil;
    
    if (inputInfo.imageData.length < RFSuperSmallImageCriticalValue * 1024) {
        
        output = inputInfo.imageData;
    }
    else
    {
        UIImage *originalImage = [UIImage imageWithData:inputInfo.imageData];
        
        CGSize targetSize = CGSizeEqualToSize(size, CGSizeZero)? CGSizeMake(RFCompressionDefaultSideLength, RFCompressionDefaultSideLength): CGSizeMake(size.width, size.height);
        
        UIImage *resizedImage = [RFGeneratorHelper resizeImage:originalImage withSize:targetSize];
        
        output = UIImageJPEGRepresentation(resizedImage, 0.5f);
    }
    
    NSString *compressionMd5 = [RFGeneratorHelper md5DigestForData:inputInfo.imageData];
    
    [self checkCacheQuantity];
    
    [compressionImagesCache setObject:output forKey:compressionMd5];
    
    return output;
}

- (void)checkCacheQuantity{

    if (thumbImagesCache.count > 9 || presentImagesCache.count > 9 || compressionImagesCache.count > 9) {
        
        [thumbImagesCache removeAllObjects];
        
        [presentImagesCache removeAllObjects];
        
        [compressionImagesCache removeAllObjects];
    }
}
@end
