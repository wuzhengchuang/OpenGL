//
//  ViewController.m
//  OpenGL ES大长腿1
//
//  Created by 吴闯 on 2020/8/24.
//  Copyright © 2020 吴闯. All rights reserved.
//

#import "ViewController.h"
#import "LongLegView.h"
@interface ViewController ()
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

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpButtons];
    [self.springView updateImage:[UIImage imageNamed:@"2.jpg"]];
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
#pragma mark - action
-(void)actionPanTop:(UIPanGestureRecognizer *)pan{
    
}
-(void)actionPanBottom:(UIPanGestureRecognizer *)pan{
    
}
#pragma mark - IBAction

- (IBAction)sliderValueDidChanged:(UISlider *)sender {
}
- (IBAction)sliderDidTouchDown:(id)sender {
    [self setViewsHidden:YES];
}

- (IBAction)sliderDidTouchUp:(id)sender {
    [self setViewsHidden:NO];
}
- (IBAction)saveAction:(id)sender {
}
@end
