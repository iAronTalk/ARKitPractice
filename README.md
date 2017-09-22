# ARKit 初体验
---
## ARKit 简介
增强现实技术（Augmented Reality，简称 AR），是一种实时地计算摄影机影像的位置及角度并加上相应图像、视频、3D模型的技术，这种技术的目标是在屏幕上把虚拟世界套在现实世界并进行互动。
>* ARKit框架提供了三种AR技术，分别基于三3D场景的**SceneKit**和**Metal2**，以及基于2D场景的**SpriktKit**。
>* 开发环境关键词：A9 和 iOS 11。

## ARKit的工作原理
简单说，ARKit就是摄像头拍摄的**2D世界转化成3D世界**，并加入**虚拟的3D模型**。并由SceneKit（或者其他两种框架）呈现出来(本文以SceneKit为例)。

* ARKit负责：1.相机捕捉现实世界图像 2.并计算出对应的虚拟3D模型。
* SceneKit负责：呈现3D世界，并添加3D模型。


## ARKit框架

#### ARSession
> An ARSession object coordinates the major processes that ARKit performs on your behalf to create an augmented reality experience. These processes include reading data from the device's motion sensing hardware, controlling the device's built-in camera, and performing image analysis on captured camera images.

> ARSession主要用于协调在构建增强现实体验的过程中各个关键步骤，如读取传感器数据，控制相机，分析图片等。

#### ARConfiguration
> ARWorldTrackingConfiguration：跟踪设备的位置、方向、平面检测和hit testing。

> AROrientationTrackingConfiguration：仅用于方向跟踪。

> ARFaceTrackingConfiguration：前置摄像头仅用于人脸跟踪。

#### ARSCNView
> The ARSCNView class provides the easiest way to create augmented reality experiences that blend virtual 3D content with a device camera view of the real world. When you run the view's provided ARSession object.

> ARSCNView本身包含了一个ARSession对象，二者相互协作，最终呈现出3D虚拟世界。简单理解，ARSCNView的主要作用就是呈现三维世界。

#### ARFrame

>A running AR session continuously captures video frames from the device camera. For each frame, ARKit analyzes the image together with data from the device's motion sensing hardware to estimate the device's real-world position. ARKit delivers this tracking information and imaging parameters in the form of an ARFrame object.

>配合ARSession使用（currentFrame属性）,ARSession不停的获取视频帧信息，并结合底层的传感器信息，将处理好的跟踪信息和图像参数放到这个类中。

#### ARCamera
>Information about the camera position and imaging characteristics for a captured video frame in an AR session.

>配置ARFrame使用，存放摄像头的位置等相关信息。

#### ARPlaneAnchor
>To track the positions and orientations of real or virtual objects relative to the camera.
ARKit also automatically adds anchors when you enable the planeDetection option in a world tracking session.

>ARPlaneAnchor是ARAnchor的子类，笔者称之为平地锚点。ARKit能够自动识别平地，并且会默认添加一个锚点到场景中，当然要想看到真实世界中的平地效果，需要我们自己使用SCNNode来渲染这个锚点。

#### ARHitTestResult
>Information about a real-world surface found by examining a point in the device camera view of an AR session.

>ARHitTestResult：点击回调结果，这个类主要用于虚拟增强现实技术（AR技术）中现实世界与3D场景中虚拟物体的交互。 比如我们在相机中移动。拖拽3D虚拟物体，都可以通过这个类来获取ARKit所捕捉的结果。由ARSCNView的`hitTest: type:`方法返回。

#### 其他
>1.还有ARLightEstimate、ARPlaneAnchor、ARError等，这里不做一一介绍，在实际项目中都会涉及。

>2.在实际的开发中使用**SceneKit**的API应用非常多，实现复杂、绚丽的AR效果熟练的掌握SceneKit也是必不可少的。您可以看这里[SceneKit]()。

>关于**SceneKit**的细节，可以阅读下面的文章：

>[Apple官方文档](https://developer.apple.com/scenekit/)

>[Objc中国 SceneKit](https://www.objccn.io/issue-18-3/)

>[Raywenderlich SceneKit](https://www.raywenderlich.com/83748/beginning-scene-kit-tutorial)

> [3D with SceneKit](http://ronnqvi.st/3d-with-scenekit/)

>[Introduction To SceneKit](https://www.weheartswift.com/introduction-scenekit-part-1/)
## ARKit类关系图
![ARKit类关系图][AR结构图]
<div style="border-bottom: #cccccc solid 1px ;width: 100px; margin: 0 auto">ARKit类关系图</div>

## AR相关常用SceneKit类介绍

#### SCNView
>SCNView:A view for displaying 3D SceneKit content.

>ARSCNView继承于这个view，呈现3D世界。

#### SCNScene
>An SCNScene object represents a three-dimensional scene and its contents.

>SCNView中一个属性scene正是这个类，SCNView提供对3D场景的控制能力，而这个Scene才是真正的3D场景。

#### SCNNode
>A structural element of a scene graph, representing a position and transform in a 3D coordinate space, to which you can attach geometry, lights, cameras, or other displayable content.

>每个Scene都有一个根节点（rootNode）,接下来对于场景添加各种3D模式都是通过这个SCNNode进行的添加，相当于UIView添加subview。节点代表一个个三维世界的实体。可以添加几何约束、追光、相机等。

#### SCNHitTestResult
>Detailed information about a result from searching for elements of a scene located at a specified point, or along a specified line segment (or ray).

>类似于ARHitTestResult，但是二者没有集成关系，但作用是一样的，SCNHitTestResult是由SCNView 的`hitTest: options:`返回的。
#### SCNLight
>A light source that can be attached to a node to illuminate the scene.

>光照是SceneKit中非常重要的属性，给SCNNode添加光照，调整视觉感。（4种光照效果）

#### SCNVector3和SCNVector4

> 三维和四维的坐标，可以用于表示位置、进行矩阵变换等。

## SceneKit结构图
![SceneKit类关系图][SK结构图]
<div style="border-bottom: #cccccc solid 1px ;width: 120px; margin: 0 auto">SceneKit类关系图</div>

---
#### ARKit参考传送门
>[Apple官方文档](https://developer.apple.com/arkit/)

>[ARKit系列教程](http://blog.csdn.net/biangabiang/article/details/76826264)

>[Github AR资源](https://github.com/olucurious/Awesome-ARKit)

>[ARKit 开发系列](https://zhuanlan.zhihu.com/p/27345673)


[AR结构图]: resources/结构图.jpeg "ARKit类关系图"
[SK结构图]: resources/SceneKit结构图.jpeg "SceneKit类关系图"
