ios-KRFuzzyCMeans-Algorithm
=================

KRFuzzyCMeans has implemented Fuzzy C-Means (FCM) the fuzzy (ファジー理論) clustering / classification algorithm (クラスタリング分類) on Machine Learning (マシンラーニング). It could be used in data mining (データマイニング) and image compression (画像圧縮). If you wanna know how to use and the details, you could contact me via email.

#### Podfile

```ruby
platform :ios, '7.0'
pod "KRFuzzyCMeans", "~> 1.0"
```

## How to use

``` objective-c
#import "KRFuzzyCMeans.h"

- (void)viewDidLoad 
{
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
```

## Version

V1.0

## License

MIT.
