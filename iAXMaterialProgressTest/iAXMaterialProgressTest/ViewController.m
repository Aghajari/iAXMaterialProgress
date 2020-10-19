//
//  ViewController.m
//  iAXMaterialProgressTest
//
//  Created by AmirHossein Aghajari on 10/16/20.
//  Copyright © 2020 Amir Hossein Aghajari. All rights reserved.
//

#import "ViewController.h"
#import "iAXMaterialProgress.h"

@interface ViewController ()

@end

@implementation ViewController{
    iAXMaterialProgress *progress;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    progress = [[iAXMaterialProgress alloc] init];
    progress.frame = CGRectMake((self.view.frame.size.width/2)-28,
                                (self.view.frame.size.height/2)-28, 56, 56);
    [self.view addSubview:progress];
    [progress start];

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
