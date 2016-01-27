ios-KRFuzzyCMeans-Algorithm
=================

KRFuzzyCMeans has implemented Fuzzy C-Means (FCM) the fuzzy (ファジー理論) clustering / classification algorithm (クラスタリング分類) on Machine Learning (マシンラーニング). It could be used in data mining (データマイニング) and image compression (画像圧縮). If you wanna know how to use and the details, you could contact me via email.

#### Podfile

```ruby
platform :ios, '7.0'
pod "KRFuzzyCMeans", "~> 1.4"
```

## How to use

#### Import
``` objective-c
#import "KRFuzzyCMeans.h"
```

##### Distance Methods

``` objective-c
KRFuzzyCMeansDistanceFormulaEuclidean
KRFuzzyCMeansDistanceFormulaCosine
KRFuzzyCMeansDistanceFormulaRBF
```

#### Training
``` objective-c
KRFuzzyCMeans *_krFcm   = [KRFuzzyCMeans sharedFCM];
_krFcm.doneThenSave     = YES;
_krFcm.m                = 3;
_krFcm.convergenceError = 0.001f;
_krFcm.distanceFormula  = KRFuzzyCMeansDistanceFormulaEuclidean; //KRFuzzyCMeansDistanceFormulaCosine
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
```
#### Recalling Tranined Centers
``` objective-c
// Recalling tranined centers that last saved.
[_krFcm recallCenters];
// Then, start to train or directly cluster the patterns.
[_krFcm directClusterPatterns:@[@[@1, @5], @[@4, @2], @[@7, @3]]];
```

## Version

V1.4

## License

MIT.
