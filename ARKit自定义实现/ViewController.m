//
//  ViewController.m
//  ARKit自定义实现
//
//  Created by Aaron_Xin on 2017/6/11.
//  Copyright © 2017年 Aaron_Xin. All rights reserved.
//

#import "ViewController.h"

#import "ARSCNViewViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

///开启AR
- (IBAction)startButtonClick:(UIButton *)sender {
    
    //创建自定义AR控制器
    ARSCNViewViewController *vc = [[ARSCNViewViewController alloc] init];
    
    vc.arType = sender.tag;
    //跳转
    [self presentViewController:vc animated:YES completion:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
