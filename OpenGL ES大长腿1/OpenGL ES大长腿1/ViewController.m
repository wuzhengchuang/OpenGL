//
//  ViewController.m
//  OpenGL ES大长腿1
//
//  Created by 吴闯 on 2020/8/24.
//  Copyright © 2020 吴闯. All rights reserved.
//

#import "ViewController.h"
#import "LongLegView.h"
@interface ViewController ()<LongLegViewViewDelegate>
@property (weak, nonatomic) IBOutlet LongLegView *springView;
@property (weak, nonatomic) IBOutlet UIView *topLine;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomLineSpace;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topLineSpace;
@property (weak, nonatomic) IBOutlet UIView *mask;
@property (weak, nonatomic) IBOutlet UIView *bottomLine;
@property (weak, nonatomic) IBOutlet UIButton *topButton;
@property (weak, nonatomic) IBOutlet UIButton *bottomButton;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (weak, nonatomic) IBOutlet UISlider *slider;
@property (nonatomic, assign)CGFloat currentTop;
@property (nonatomic, assign)CGFloat currentBottom;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpButtons];
    self.springView.springDelegate=self;
    [self.springView updateImage:[UIImage imageNamed:@"2.jpg"]];
    [self setUpStretchArea];
}
-(void)viewDidAppear:(BOOL)animated{
    static dispatch_once_t onceToken;
    //单例~
    dispatch_once(&onceToken, ^{
        //这里的计算要用到view的size，所以等待AutoLayout把尺寸计算出来后再调用
        [self setUpStretchArea];
    });
}
#pragma mark - Private
- (void)setUpButtons{
    self.topButton.layer.cornerRadius = 15.f;
    self.topButton.layer.borderWidth = 1.f;
    self.topButton.layer.borderColor = [[UIColor whiteColor] CGColor];
    [self.topButton addGestureRecognizer:[[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(actionPanTop:)]];
    self.bottomButton.layer.cornerRadius = 15.f;
    self.bottomButton.layer.borderWidth = 1.f;
    self.bottomButton.layer.borderColor = [[UIColor whiteColor] CGColor];
    [self.bottomButton addGestureRecognizer:[[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(actionPanBottom:)]];
}
-(void)setViewsHidden:(BOOL)isHidden{
    self.topLine.hidden=isHidden;
    self.topButton.hidden=isHidden;
    self.mask.hidden=isHidden;
    self.bottomLine.hidden=isHidden;
    self.bottomButton.hidden=isHidden;
}
- (CGFloat)stretchAreaYWithLineSpace:(CGFloat)lineSpace {
    
    //
    return (lineSpace / self.springView.bounds.size.height - self.springView.textureTopY) / self.springView.textureHeight;
}
- (void)setUpStretchArea{
    self.currentTop=0.25;
    self.currentBottom=0.75;
    // 初始纹理占 View 的比例
    CGFloat textureOriginHeight = 0.7f;
    self.topLineSpace.constant = ((self.currentTop * textureOriginHeight) + (1 - textureOriginHeight) / 2) * self.springView.bounds.size.height;
    NSLog(@"self.topLineSpace.constant %f",self.topLineSpace.constant);
    
    //currentBottom * textureOriginHeight + (1 - textureOriginHeight)/2 * springViewHeight;
    self.bottomLineSpace.constant = ((self.currentBottom * textureOriginHeight) + (1 - textureOriginHeight) / 2) * self.springView.bounds.size.height;
     NSLog(@"self.bottomLineSpace.constant %f",self.bottomLineSpace.constant);
}
#pragma mark - action
-(void)actionPanTop:(UIPanGestureRecognizer *)pan{
    //1.判断springView是否发生改变
    if ([self.springView hasChange]) {
        //2.给springView 更新纹理
        [self.springView updateTexture];
        //3.重置滑杆位置(因为此时相当于对一个张新图重新进行拉伸处理~)
        self.slider.value = 0.5f;
    }
    
    //修改约束信息;
    CGPoint translation = [pan translationInView:self.view];
    //修改topLineSpace的预算条件;
    self.topLineSpace.constant = MIN(self.topLineSpace.constant + translation.y,
                                     self.bottomLineSpace.constant);
    
    //纹理Top = springView的height * textureTopY
    //606
    CGFloat textureTop = self.springView.bounds.size.height * self.springView.textureTopY;
    NSLog(@"%f,%f",self.springView.bounds.size.height,self.springView.textureTopY);
    NSLog(@"%f",textureTop);
    
    //设置topLineSpace的约束常量;
    self.topLineSpace.constant = MAX(self.topLineSpace.constant, textureTop);
    //将pan移动到view的Zero位置;
    [pan setTranslation:CGPointZero inView:self.view];
    
    //计算移动了滑块后的currentTop和currentBottom
    self.currentTop = [self stretchAreaYWithLineSpace:self.topLineSpace.constant];
    self.currentBottom = [self stretchAreaYWithLineSpace:self.bottomLineSpace.constant];
}
-(void)actionPanBottom:(UIPanGestureRecognizer *)pan{
    if ([self.springView hasChange]) {
        [self.springView updateTexture];
        self.slider.value = 0.5f;
    }
    
    CGPoint translation = [pan translationInView:self.view];
    self.bottomLineSpace.constant = MAX(self.bottomLineSpace.constant + translation.y,
                                        self.topLineSpace.constant);
    CGFloat textureBottom = self.springView.bounds.size.height * self.springView.textureBottomY;
    self.bottomLineSpace.constant = MIN(self.bottomLineSpace.constant, textureBottom);
    [pan setTranslation:CGPointZero inView:self.view];
    
    self.currentTop = [self stretchAreaYWithLineSpace:self.topLineSpace.constant];
    self.currentBottom = [self stretchAreaYWithLineSpace:self.bottomLineSpace.constant];
}
#pragma mark - IBAction

- (IBAction)sliderValueDidChanged:(UISlider *)sender {
    //获取图片的中间拉伸区域高度;
    //获取图片的中间拉伸区域高度: (currentBottom - currentTop)*sliderValue + 0.5;
    CGFloat newHeight = (self.currentBottom - self.currentTop) * ((sender.value) + 0.5);
    NSLog(@"%f",sender.value);
    NSLog(@"%f",newHeight);
    
    
    //将currentTop和currentBottom以及新图片的高度传给springView,进行拉伸操作;
    [self.springView stretchingFromStartY:self.currentTop
                                   toEndY:self.currentBottom
                            withNewHeight:newHeight];
}
- (IBAction)sliderDidTouchDown:(id)sender {
    [self setViewsHidden:YES];
}

- (IBAction)sliderDidTouchUp:(id)sender {
    [self setViewsHidden:NO];
}
- (IBAction)saveAction:(id)sender {
}
#pragma mark - MFSpringViewDelegate
//代理方法(SpringView拉伸区域修改)
- (void)springViewStretchAreaDidChanged:(LongLegView *)springView {
    
    //拉伸结束后,更新topY,bottomY,topLineSpace,bottomLineSpace 位置;
    CGFloat topY = self.springView.bounds.size.height * self.springView.stretchAreaTopY;
    CGFloat bottomY = self.springView.bounds.size.height * self.springView.stretchAreaBottomY;
    self.topLineSpace.constant = topY;
    self.bottomLineSpace.constant = bottomY;
}
@end
