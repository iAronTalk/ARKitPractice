//
//  ViewController.m
//  RFImageGenerator
//
//  Created by Qi Xin on 15/9/2017.
//  Copyright © 2017 Qi Xin. All rights reserved.
//

#import "ViewController.h"

#import "RFImageInput.h"

#import "RFImageGeneratorManager.h"

#import "RFImageOutput.h"

@interface ViewController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
    NSMutableArray <RFImageInput *> * images;
}
- (IBAction)selectImage:(id)sender;

- (IBAction)generateImages:(id)sender;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    images = [NSMutableArray array];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)selectImage:(id)sender {
    
    UIImagePickerController *controller = [[UIImagePickerController alloc] init];
    
    controller.allowsEditing = NO;
    
    controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    controller.delegate = self;
    
    if (self.navigationController)
    {
        [self.navigationController pushViewController:controller animated:YES];
    }
    else
    {
        [self presentViewController:controller animated:YES completion:nil];
    }
}

- (IBAction)generateImages:(id)sender {
    
    NSInteger count = 0;
    
    for (RFImageInput *input in images) {
        
        NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory , NSUserDomainMask, YES).firstObject;
        
        NSString *nameori = [NSString stringWithFormat:@"%@/%ld_ori.png",path,count];
        
        [input.imageData writeToFile:nameori atomically:YES];
        
        count ++;
    }
    
    [[RFImageGeneratorManager sharedInstance] generateBatchOfResizedImages:(NSArray *)images completion:^(NSArray<RFImageOutput *> *resultImages) {
        
        NSMutableArray *array = [NSMutableArray array];
        
        NSInteger index = 0;
        
        for (RFImageOutput *output in resultImages) {
            
//            UIImage *imageCom = [UIImage imageWithData:output.compressionImageData];
//
//            UIImage *imagePre = [UIImage imageWithData:output.presentImageData];
//
//            UIImage *imageThum = [UIImage imageWithData:output.thumbImageData];
            
            NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory , NSUserDomainMask, YES).firstObject;
            
            NSString *nameCom = [NSString stringWithFormat:@"%@/%ld_com.png",path,index];
            [output.compressionImageData writeToFile:nameCom atomically:YES];
            
            NSString *namePre = [NSString stringWithFormat:@"%@/%ld_pre.png",path,index];
            [output.presentImageData writeToFile:namePre atomically:YES];
            
            NSString *nameThum = [NSString stringWithFormat:@"%@/%ld_thum.png",path,index];
            [output.thumbImageData writeToFile:nameThum atomically:YES];
            
            index ++;
        }
        NSLog(@"fetched images");
    }];
    
    NSLog(@"fetching images");
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(nullable NSDictionary<NSString *,id> *)editingInfo
{
    RFImageInput *input = [RFImageInput imageInfo:UIImageJPEGRepresentation(image, 1) thumb:CGSizeZero present:CGSizeZero compression:CGSizeZero];
    
    [images addObject:input];
    
    if(picker.navigationController)
    {
        [picker.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        [picker dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{

}
@end
