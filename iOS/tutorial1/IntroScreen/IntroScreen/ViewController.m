//
//  ViewController.m
//  IntroScreen
//
//  Created by Wei Zhang on 9/14/18.
//  Copyright © 2018 VeraZhang. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 200, self.view.frame.size.width -40, 50)];
    label.backgroundColor = [UIColor orangeColor];
    [self.view addSubview:label];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
