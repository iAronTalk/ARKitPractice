//
//  ARSCNViewViewController.m
//  ARKit自定义实现
//
//  Created by Aaron_Xin on 2017/6/11.
//  Copyright © 2017年 Aaron_Xin. All rights reserved.
//

#import "ARSCNViewViewController.h"

//3D游戏框架
#import <SceneKit/SceneKit.h>
//ARKit框架
#import <ARKit/ARKit.h>

@interface ARSCNViewViewController ()<ARSCNViewDelegate,ARSessionDelegate>
{
    SCNNode *movedObject;
}
//AR视图：展示3D世界
@property(nonatomic,strong)ARSCNView *arSCNView;

//AR会话，负责管理相机追踪配置及3D相机坐标
@property(nonatomic,strong)ARSession *arSession;

//会话追踪配置：计算，搭建三维世界
@property(nonatomic,strong)ARConfiguration *arSessionConfiguration;

//展示模式
@property(nonatomic,strong)SCNNode *presentNode;

@property (nonatomic, getter = isPresented) BOOL presented;

@end

@implementation ARSCNViewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panEvent:)];
    
    [self.view addGestureRecognizer:pan];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapEvent:)];
    
    [self.view addGestureRecognizer:tap];
}

- (void)back:(UIButton *)btn
{
    [self.arSCNView.session pause];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.view addSubview:self.arSCNView];
    
    [self.arSession runWithConfiguration:self.arSessionConfiguration];
    
    //添加返回按钮
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:@"返回" forState:UIControlStateNormal];
    btn.frame = CGRectMake(self.view.bounds.size.width/2-50, self.view.bounds.size.height-100, 100, 50);
    btn.backgroundColor = [UIColor greenColor];
    [btn addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
}

- (void)panEvent:(UIPanGestureRecognizer *)recognizer
{
    CGPoint point = [recognizer locationInView:self.arSCNView];
    
    NSArray *results = [self.arSCNView hitTest:point types:ARHitTestResultTypeExistingPlane];
    
    ARHitTestResult *result = results.firstObject;
    
    if (result) {
        
        SCNVector3 vector = SCNVector3Make(result.worldTransform.columns[3].x, result.worldTransform.columns[3].y, result.worldTransform.columns[3].z);
        
        self.presentNode.position = vector;
    }

    if (recognizer.state == UIGestureRecognizerStateBegan) {
        NSLog(@"Pan state began");
        CGPoint tapPoint = [recognizer locationInView:self.arSCNView];
        NSArray <SCNHitTestResult *> *result = [self.arSCNView hitTest:tapPoint options:nil];
        
        if ([result count] == 0) {
            return;
        }
        SCNHitTestResult *hitResult = [result firstObject];
        movedObject = hitResult.node.parentNode; //This aspect varies based on the type of .SCN file that you have
    }
    
    if (movedObject){
        NSLog(@"Holding an Object");
    }

    if (recognizer.state == UIGestureRecognizerStateChanged) {
        NSLog(@"Pan State Changed");
        if (movedObject)
        {
            CGPoint tapPoint = [recognizer locationInView:self.arSCNView];
            NSArray <ARHitTestResult *> *hitResults = [self.arSCNView hitTest:tapPoint types:ARHitTestResultTypeFeaturePoint];
            ARHitTestResult *result = [hitResults lastObject];
            
//            SCNMatrix4 matrix = SCNMatrix4FromMat4(result.worldTransform);
            SCNVector3 vector = SCNVector3Make(result.worldTransform.columns[3].x * 100, result.worldTransform.columns[3].y * 100, result.worldTransform.columns[3].z * 100);
            
            [movedObject setPosition:vector];
        }
        
        if (recognizer.state == UIGestureRecognizerStateEnded) {
            NSLog(@"Done moving object homeie");
            movedObject = nil;
        }
    }
}

- (void)tapEvent:(UIPanGestureRecognizer *)sender
{
    CGPoint point = [sender locationInView:self.arSCNView];
    
    NSArray <SCNHitTestResult *> *results = [self.arSCNView hitTest:point options:0];
    
    SCNHitTestResult *result = results.firstObject;
    
    if (result)
    {
        SCNNode *parent = result.node.parentNode;
        
        for (SCNNode *child in parent.childNodes) {
            
            SCNVector3 original = child.position;
            
            child.position = SCNVector3Make(original.x, original.y , original.z + 10);
        }
    }
}
#pragma mark- 点击屏幕添加飞机
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if (self.arType == ARTypePlane || self.presentNode != nil) {
//        return;
    }
    
    if (self.isPresented == YES) {
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSArray *array = @[@"Models.scnassets/ship.scn", @"Models.scnassets/candle/candle.scn", @"Models.scnassets/chair/chair.scn", @"Models.scnassets/cup/cup.scn", @"Models.scnassets/lamp/lamp.scn", @"Models.scnassets/vase/vase.scn"];
        
        NSInteger index = -2;
        
        for (NSString *node in array) {
            
            SCNScene *scene = [SCNScene sceneNamed:node];
            
            SCNNode *targetNode = scene.rootNode.childNodes[0];
            
            SCNVector3 vector;
            
            switch (index) {
                case -2:
                    vector = SCNVector3Make(0.5, 0.5, 0.5);
                    break;
                case -1:
                    vector = SCNVector3Make(1, 1, 1);
                    break;
                case 0:
                    vector = SCNVector3Make(8, 8, 8);
                    break;
                case 1:
                    vector = SCNVector3Make(10, 10, 10);
                    break;
                case 2:
                    vector = SCNVector3Make(0.5, 0.5, 0.5);
                    break;
                    
                default:
                    vector = SCNVector3Make(10, 10, 10);
                    break;
            }
            
            targetNode.scale = vector;
            
            targetNode.position = SCNVector3Make(10 * index, -15,-25);
            
            //如果targetNode有子节点的情况下。
            for (SCNNode *node in targetNode.childNodes) {
                node.scale = vector;
                node.position = SCNVector3Make(5 * index, -15,-25);
            }
            
            //将节点添加到当前屏幕中
            CABasicAnimation *inAnimation = [CABasicAnimation animationWithKeyPath:@"transform.x"];
            
            inAnimation.duration = 1;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self.arSCNView.scene.rootNode addChildNode:targetNode];
            });
            
            index++;
        }
    });
    
    _presented = YES;
    
    //台灯
    if(self.arType == ARTypeRotation)
    {
        [self.presentNode removeFromParentNode];
        
        SCNScene *scene = [SCNScene sceneNamed:@"Models.scnassets/lamp/lamp.scn"];
        SCNNode *shipNode = scene.rootNode.childNodes[0];
        self.presentNode = shipNode;
        
        //台灯比较大，适当缩放一下并且调整位置让其在屏幕中间
        shipNode.scale = SCNVector3Make(0.5, 0.5, 0.5);
        shipNode.position = SCNVector3Make(0, -15,-25);
        
        for (SCNNode *node in shipNode.childNodes) {
            node.scale = SCNVector3Make(0.5, 0.5, 0.5);
            node.position = SCNVector3Make(0, -15,-25);
        }
        
        self.presentNode.position = SCNVector3Make(0, 0, -20);
        
        //3.绕相机旋转
        SCNNode *node1 = [[SCNNode alloc] init];
        
        node1.position = self.arSCNView.scene.rootNode.position;
        
        [self.arSCNView.scene.rootNode addChildNode:node1];

        [node1 addChildNode:self.presentNode];
        
        //旋转核心动画
        CABasicAnimation *moonRotationAnimation = [CABasicAnimation animationWithKeyPath:@"rotation"];
        
        moonRotationAnimation.duration = 30;
        
        moonRotationAnimation.toValue = [NSValue valueWithSCNVector4:SCNVector4Make(0, 1, 0, M_PI * 2)];
    
        moonRotationAnimation.repeatCount = FLT_MAX;
        
        [node1 addAnimation:moonRotationAnimation forKey:@"moon rotation around earth"];
        
        [self.presentNode addAnimation:moonRotationAnimation forKey:@"moon rotation around earth"];
    }
}

#pragma mark -搭建ARKit环境

- (ARConfiguration *)arSessionConfiguration
{
    if (_arSessionConfiguration != nil) {
        return _arSessionConfiguration;
    }
    
    ARWorldTrackingConfiguration *configuration = [[ARWorldTrackingConfiguration alloc] init];

    configuration.planeDetection = ARPlaneDetectionHorizontal;
    _arSessionConfiguration = configuration;
    _arSessionConfiguration.lightEstimationEnabled = YES;
    
    return _arSessionConfiguration;
}

- (ARSession *)arSession
{
    if(_arSession != nil)
    {
        return _arSession;
    }
    //1.创建会话
    _arSession = [[ARSession alloc] init];
    _arSession.delegate = self;
    //2返回会话
    return _arSession;
}

//创建AR视图
- (ARSCNView *)arSCNView
{
    if (_arSCNView != nil) {
        return _arSCNView;
    }
    
    _arSCNView = [[ARSCNView alloc] initWithFrame:self.view.bounds];
    
    _arSCNView.delegate = self;

    _arSCNView.session = self.arSession;

    _arSCNView.automaticallyUpdatesLighting = YES;
    
    return _arSCNView;
}

#pragma mark -- ARSCNViewDelegate

//添加节点时候调用（当开启平地捕捉模式之后，如果捕捉到平地，ARKit会自动添加一个平地节点）
- (void)renderer:(id <SCNSceneRenderer>)renderer didAddNode:(SCNNode *)node forAnchor:(ARAnchor *)anchor
{
    
    if(self.arType != ARTypePlane)
    {
        return;
    }
    
    if ([anchor isMemberOfClass:[ARPlaneAnchor class]]) {
        NSLog(@"捕捉到平地");
        
        //添加一个3D平面模型，ARKit只有捕捉能力，锚点只是一个空间位置，要想更加清楚看到这个空间，我们需要给空间添加一个平地的3D模型来渲染他
        
        //1.获取捕捉到的平地锚点
        ARPlaneAnchor *planeAnchor = (ARPlaneAnchor *)anchor;
        //2.创建一个3D物体模型    （系统捕捉到的平地是一个不规则大小的长方形，这里笔者将其变成一个长方形，并且是否对平地做了一个缩放效果）
        //参数分别是长宽高和圆角
        SCNBox *plane = [SCNBox boxWithWidth:planeAnchor.extent.x*0.3 height:0 length:planeAnchor.extent.x*0.3 chamferRadius:0];
        //3.使用Material渲染3D模型（默认模型是白色的，这里笔者改成红色）
        plane.firstMaterial.diffuse.contents = [UIColor redColor];
        
        //4.创建一个基于3D物体模型的节点
        SCNNode *presentNode = [SCNNode nodeWithGeometry:plane];
        //5.设置节点的位置为捕捉到的平地的锚点的中心位置  SceneKit框架中节点的位置position是一个基于3D坐标系的矢量坐标SCNVector3Make
        presentNode.position =SCNVector3Make(planeAnchor.center.x, 0, planeAnchor.center.z);
        
        //self.presentNode = presentNode;
        [node addChildNode:presentNode];
        
        //2.当捕捉到平地时，2s之后开始在平地上添加一个3D模型
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            //1.创建一个花瓶场景
            SCNScene *scene = [SCNScene sceneNamed:@"Models.scnassets/vase/vase.scn"];
            //2.获取花瓶节点（一个场景会有多个节点，此处我们只写，花瓶节点则默认是场景子节点的第一个）
            //所有的场景有且只有一个根节点，其他所有节点都是根节点的子节点
            SCNNode *vaseNode = scene.rootNode.childNodes[0];
            
            //4.设置花瓶节点的位置为捕捉到的平地的位置，如果不设置，则默认为原点位置，也就是相机位置
            vaseNode.position = SCNVector3Make(planeAnchor.center.x, 0, planeAnchor.center.z);
            
            //5.将花瓶节点添加到当前屏幕中
            //!!!此处一定要注意：花瓶节点是添加到代理捕捉到的节点中，而不是AR试图的根节点。因为捕捉到的平地锚点是一个本地坐标系，而不是世界坐标系
            [node addChildNode:vaseNode];
        });
    }
}

//刷新时调用
- (void)renderer:(id <SCNSceneRenderer>)renderer willUpdateNode:(SCNNode *)node forAnchor:(ARAnchor *)anchor
{
    NSLog(@"刷新中");
}

//更新节点时调用
- (void)renderer:(id <SCNSceneRenderer>)renderer didUpdateNode:(SCNNode *)node forAnchor:(ARAnchor *)anchor
{
    NSLog(@"节点更新");
    
}

//移除节点时调用
- (void)renderer:(id <SCNSceneRenderer>)renderer didRemoveNode:(SCNNode *)node forAnchor:(ARAnchor *)anchor
{
    NSLog(@"节点移除");
}

#pragma mark -ARSessionDelegate

//会话位置更新（监听相机的移动），此代理方法会调用非常频繁，只要相机移动就会调用，如果相机移动过快，会有一定的误差，具体的需要强大的算法去优化，笔者这里就不深入了
- (void)session:(ARSession *)session didUpdateFrame:(ARFrame *)frame
{
//    NSLog(@"相机移动");
    if (self.arType != ARTypeMove || self.arType == ARTypePlane) {
        return;
    }
    
    if (true) {
        
        //捕捉相机的位置，让节点随着相机移动而移动
        //根据官方文档记录，相机的位置参数在4X4矩阵的第三
        for (SCNNode *node in self.arSCNView.scene.rootNode.childNodes)
        {
            node.position =SCNVector3Make(frame.camera.transform.columns[3].x,
                                          frame.camera.transform.columns[3].y,
                                          frame.camera.transform.columns[3].z);
        }
    }
}
- (void)session:(ARSession *)session didAddAnchors:(NSArray<ARAnchor*>*)anchors
{
    NSLog(@"添加锚点");
    
}


- (void)session:(ARSession *)session didUpdateAnchors:(NSArray<ARAnchor*>*)anchors
{
    NSLog(@"刷新锚点");
    
}


- (void)session:(ARSession *)session didRemoveAnchors:(NSArray<ARAnchor*>*)anchors
{
    NSLog(@"移除锚点");
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
