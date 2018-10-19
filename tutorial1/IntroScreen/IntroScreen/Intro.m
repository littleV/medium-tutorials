//
//  Intro.m
//  IntroScreen
//
//  Created by Wei Zhang on 9/14/18.
//  Copyright © 2018 VeraZhang. All rights reserved.
//

#import "Intro.h"
#import "CustomPageControl.h"

@implementation Intro
- (void)viewDidLoad
{
    self.title = @"Welcome!";
    self.view.backgroundColor = [UIColor whiteColor];
    // Add skip button
    UIButton *skip = [[UIButton alloc] initWithFrame:CGRectMake(20, self.view.frame.size.height - 75, self.view.frame.size.width- 40., 50)];
    [skip setTitle:@"Skip" forState:UIControlStateNormal];
    skip.backgroundColor = [UIColor blueColor];
    skip.layer.cornerRadius = 15;
    skip.clipsToBounds = YES;
    [self.view addSubview:skip];
    [skip addTarget:self action:@selector(skipPressed:) forControlEvents:UIControlEventTouchUpInside];
    // Add Page control
    CustomPageControl *pageControl = [[CustomPageControl alloc] initWithFrame:CGRectMake(0, 0,self.view.frame.size.width, self.view.frame.size.height - 100)];
    [self.view addSubview:pageControl];
}

- (void) skipPressed: (id ) sender
{
    UIStoryboard *main = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    [self presentViewController:    [main instantiateInitialViewController] animated:YES completion:nil];
}


@end
