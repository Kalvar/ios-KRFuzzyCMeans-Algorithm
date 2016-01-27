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

- (void)viewDidLoad
{
    [super viewDidLoad];
    KRFuzzyCMeans *_krFcm   = [KRFuzzyCMeans sharedFCM];
    _krFcm.doneThenSave     = YES;
    _krFcm.m                = 3;
    _krFcm.convergenceError = 0.001f;
    _krFcm.distanceFormula  = KRFuzzyCMeansDistanceFormulaRBF; //KRFuzzyCMeansDistanceFormulaEuclidean; //KRFuzzyCMeansDistanceFormulaByCosine
    [_krFcm addCenters:@[@5.0f, @5.0f]];     //The center 1, cluster 1 start in here
    [_krFcm addCenters:@[@10.0f, @10.0f]];   //The center 2, cluster 2 start in here
    [_krFcm addCenters:@[@12.0f, @14.0f]];   //The center 3, cluster 3 start in here
    [_krFcm addPatterns:@[@[@2, @12], @[@4, @9], @[@7, @13], @[@11, @5], @[@12, @7], @[@14, @4]]];
    
    [_krFcm clusterWithCompletion:^(BOOL success, NSArray *clusters, NSArray *centrals, NSInteger totalTimes)
    {
        NSLog(@"\n\n===============================================\n\n");
        NSLog(@"totalTimes : %li", totalTimes);
        NSLog(@"results : %@", clusters);
        NSLog(@"centrals : %@", centrals);
        NSLog(@"\n\n===============================================\n\n");
        
        //Directly verify and classify others pattern without continually training the centers, you could use :
        [_krFcm directClusterPatterns:@[@[@2, @3], @[@3, @3], @[@5, @9]]];
        [_krFcm printResults];
        
        //If you have one or more patterns need to do standard classification, use this to renew all groups and re-adjust the central groups :
        [_krFcm addPatterns:@[@[@2, @3], @[@3, @3], @[@5, @9]]];
        [_krFcm clusterWithCompletion:^(BOOL success, NSArray *clusters, NSArray *centrals, NSInteger totalTimes)
        {
            [_krFcm printResults];
            //... Do your next step.
        }];
        
    } perIteration:^(NSInteger times, NSArray *clusters, NSArray *centrals)
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
