//
//  ViewController.m
//  KRFuzzyCMeans
//
//  Created by Kalvar on 2015/4/6.
//  Copyright (c) 2015年 Kalvar. All rights reserved.
//

#import "ViewController.h"
#import "KRFuzzyCMeans.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    KRFuzzyCMeans *_krFcm   = [KRFuzzyCMeans sharedFCM];
    _krFcm.m                = 3;
    _krFcm.convergenceError = 0.001f;
    [_krFcm addCentralX:5.0f y:5.0f];
    [_krFcm addCentralX:10.0f y:10.0f];
    //[_krFcm addCentralX:12.0f y:14.0f];
    [_krFcm addPatterns:@[@[@2, @12], @[@4, @9], @[@7, @13], @[@11, @5], @[@12, @7], @[@14, @4]]];
    [_krFcm clusteringWithCompletion:^(BOOL success, NSArray *clusters, NSArray *centrals, NSInteger totalTimes)
    {
        NSLog(@"\n\n===============================================\n\n");
        NSLog(@"totalTimes : %li", totalTimes);
        NSLog(@"results : %@", clusters);
        NSLog(@"centrals : %@", centrals);
    }eachGeneration:^(NSInteger times, NSArray *clusters, NSArray *centrals)
    {
        NSLog(@"times : %li", times);
        NSLog(@"clusters : %@", clusters);
        NSLog(@"centrals : %@", centrals);
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
