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
    [_krFcm addCentralX:5.0f y:5.0f];     //The center 1, cluster 1 start in here
    [_krFcm addCentralX:10.0f y:10.0f];   //The center 2, cluster 2 start in here
    [_krFcm addCentralX:12.0f y:14.0f];   //The center 3, cluster 3 start in here
    [_krFcm addPatterns:@[@[@2, @12], @[@4, @9], @[@7, @13], @[@11, @5], @[@12, @7], @[@14, @4]]];
    [_krFcm clusteringWithCompletion:^(BOOL success, NSArray *clusters, NSArray *centrals, NSInteger totalTimes)
    {
        NSLog(@"\n\n===============================================\n\n");
        NSLog(@"totalTimes : %li", totalTimes);
        NSLog(@"results : %@", clusters);
        NSLog(@"centrals : %@", centrals);
        NSLog(@"\n\n===============================================\n\n");
        
        //Start in verify and classify others pattern.
        //When train finished, add one pattern to classify.
        //[_krFcm addOnePattern:@[@2, @3]];
        //If you have more patterns need to classify, use this :
        [_krFcm addPatterns:@[@[@2, @3], @[@3, @3], @[@5, @9]]];
        
        //Then, if you don't want to adjust the central groups, just wanna directly classify them, you could use :
        //[_krFcm directCluster];
        //[_krFcm printResults];
        
        //Then, if you wanna renew all groups and re-adjust the central groups, you could use :
        [_krFcm clusteringWithCompletion:^(BOOL success, NSArray *clusters, NSArray *centrals, NSInteger totalTimes)
        {
            [_krFcm printResults];
            //... Do your next step.
        }];
        
    } eachGeneration:^(NSInteger times, NSArray *clusters, NSArray *centrals)
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
