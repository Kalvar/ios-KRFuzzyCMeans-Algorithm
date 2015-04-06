//
//  KRFuzzyCMeans.m
//  KRFuzzyCMeans V1.0
//
//  Created by Kalvar on 2015/4/6.
//  Copyright (c) 2015年 Kalvar Lin, ilovekalvar@gmail.com. All rights reserved.
//

#import "KRFuzzyCMeans.h"

@interface KRFuzzyCMeans()

//上一次運算的群聚中心點集合
@property (nonatomic, strong) NSMutableArray *lastCenters;
//當前的迭代數
@property (nonatomic, assign) NSInteger currentGenerations;

@end

@implementation KRFuzzyCMeans(fixClusters)

-(void)_doneClustering
{
    if( self.clusterCompletion )
    {
        self.clusterCompletion(YES, self.results, self.centrals, self.currentGenerations);
    }
}

/*
 * @ 計算 2 點距離
 */
-(float)_distanceX1:(NSArray *)_x1 x2:(NSArray *)_x2
{
    return sqrtf(powf([[_x1 firstObject] floatValue] - [[_x2 firstObject] floatValue], 2) +
                 powf([[_x1 lastObject] floatValue] - [[_x2 lastObject] floatValue], 2));
}

/*
 * @ 依照群聚中心點(形心) _centers 進行 _sources 群聚分類
 */
-(void)_clusterSources:(NSArray *)_sources compareCenters:(NSArray *)_centers
{
    NSMutableArray *_clusters = nil;
    if( [_centers count] > 0 )
    {
        NSInteger _m                 = self.m;
        if( _m < 2 )
        {
            _m = 2;
        }
        _clusters                    = [NSMutableArray new];
        //用於儲存每一個計算好的 Xi 對每一個群聚的歸屬度( Membership )
        NSMutableArray *_xMembersips = [NSMutableArray new];
        //先建立對應空間給要分群的陣列，這樣後續直接將數據放入該對應位置的群聚即可，ex : _centrals[0] = _results[0], _centrals[n] = _results[n] ...
        NSInteger _totalClusters     = [_centers count];
        for(int _n=0; _n<_totalClusters; _n++)
        {
            [_clusters addObject:[NSMutableArray new]];
        }
        //進行將目標集合分類至所屬分群的動作
        for( NSArray *_xy in _sources )
        {
            //float _x = [[_xy firstObject] floatValue];
            //float _y = [[_xy lastObject] floatValue];
            //跟每一個群聚中心點作比較，計算出歸屬度( Membership )
            //得先知道當前這 Xi 對每一個群聚的歸屬度，故須先求出對每一個點的距離數值才能再做後續處理
            NSMutableArray *_distances = [NSMutableArray new];
            for( NSArray *_centerXy in _centers )
            {
                //個別求出要分群的集合跟其它集合體的距離( 歐基里德定律, 求 2 個座標點的距離，但因 FCM 快速解公式關係，平方根抵消 )
                //float _distance = powf(_x - [[_centerXy firstObject] floatValue], 2) + powf(_y - [[_centerXy lastObject] floatValue], 2);
                //遵循 FCM 原公式*
                float _distance = [self _distanceX1:_centerXy x2:_xy];
                //儲存該 Xi 對每一個形心的距離
                [_distances addObject:[NSNumber numberWithFloat:_distance]];
            }
            
            //計算該 Xi 點對每一群聚的歸屬度
            NSMutableArray *_memberships = [NSMutableArray new];
            int _toClusterIndex          = 0;
            float _maxMembership         = -1.0f;
            int _j                       = 0;
            for( NSNumber *_xDistance in _distances )
            {
                float _selfDistance = [_xDistance floatValue];
                float _sumRatio     = 0.0f;
                for( NSNumber *_centerDistance in _distances )
                {
                    float _membershipRatio = 0.0f;
                    if( [_centerDistance floatValue] != 0.0f )
                    {
                        //_membershipRatio = powf(_selfDistance / [_centerDistance floatValue], ( 1 / (_m - 1) ));
                        //遵循 FCM 原公式*
                        _membershipRatio = powf(_selfDistance / [_centerDistance floatValue], ( 2 / (_m - 1) ));
                    }
                    _sumRatio += _membershipRatio;
                }
                //指定群聚的歸屬度, ex : 第 1 次迴圈 for 第 1 群、第 2 次迴圈 for 第 2 群、第 n 次迴圈 for 第 n 群 ...，一次一次的計算
                float _clusterMembership = 1 / _sumRatio;
                //照對應的群聚位置存放歸屬度
                [_memberships addObject:[NSNumber numberWithFloat:_clusterMembership]];
                
                //在這裡同時比較要存放到哪一個群聚裡
                if( _maxMembership < _clusterMembership )
                {
                    _maxMembership  = _clusterMembership;
                    _toClusterIndex = _j;
                }
                
                ++_j;
            }
            
            //將 source (x, y) 放入該所屬的群聚裡, 使用 Copy, 以免記憶體連動造成 Leaks
            [[_clusters objectAtIndex:_toClusterIndex] addObject:[_xy copy]];
            //存入 Xi 對每一個群聚形心的歸屬度 ( 後續要用來更新群聚形心用的 )
            [_xMembersips addObject:_memberships];
        }
        
        /*
         * @ Design thinks
         *   - 如果在上面的 for{} 區塊進行歸屬度累加計算，就必須同時考量存取 N 個 Array ( 裡面儲存對每一個形心做 SUM 的數值 ) 的效能，
         *     同時重複存取 Array 的次數越多，其 performance 就越差，會遠比使用單一 for{} 來重複做事要更沒效能，
         *     因此，這裡才改用單一 for{} 來做多重存取，以避免重複操作太多 arraies 造成效能大降的問題，
         *     也就是「一次只更新一個形心」，單純化計算模式，也一併保留日後維護與改進的容易度。
         *
         */
        //都計算完歸屬度與分群後，就執行更新形心的動作
        NSMutableArray *_newCentrals = [NSMutableArray new];
        //先取出每一個舊的形心
        int _clusterIndex            = 0;
        //取出跟上一次舊的群聚形心相比的最大誤差值
        float _maxDistance           = 0.0f;
        for( NSArray *_centerXy in _centers )
        {
            //取出每一個 Xi 對每一群聚形心的 Membership
            int _xIndex     = 0;
            float _sumX     = 0.0f;
            float _sumY     = 0.0f;
            float _sumRatio = 0.0f;
            for( NSArray *_memberships in _xMembersips )
            {
                //取出對應該群聚形心的歸屬度 ( 使用 _clusterIndex 取出對應值 )，並依公式乘上 m 次方 (積回去)
                float _membershipRatio = powf([[_memberships objectAtIndex:_clusterIndex] floatValue], _m);
                //取出對應的 source (x, y)
                NSArray *_xy = [_sources objectAtIndex:_xIndex];
                
                _sumX     += _membershipRatio * [[_xy firstObject] floatValue];
                _sumY     += _membershipRatio * [[_xy lastObject] floatValue];
                _sumRatio += _membershipRatio;
                
                ++_xIndex;
            }
            
            //更新群聚形心
            NSNumber *_cX = [NSNumber numberWithFloat:( _sumX / _sumRatio )];
            NSNumber *_cY = [NSNumber numberWithFloat:( _sumY / _sumRatio )];
            //放入新的群聚形心
            [_newCentrals addObject:@[_cX, _cY]];
            
            //跟 _centerXy 的距離做比較
            float _differDistance = [self _distanceX1:_centerXy x2:@[_cX, _cY]];
            if( _maxDistance < _differDistance )
            {
                _maxDistance = _differDistance;
            }
            
            ++_clusterIndex;
        }
        
        //更新群聚形心
        [self.centrals removeAllObjects];
        [self.centrals addObjectsFromArray:_newCentrals];
        
        //如果跟上次的最大誤差距離 <= 誤差值，就收斂。( 新舊相等 == 0.0f 也是小於誤差值 )
        if( _maxDistance <= self.convergenceError || self.currentGenerations >= self.limitGenerations )
        {
            [self.results removeAllObjects];
            [self.results addObjectsFromArray:_clusters];
            [self _doneClustering];
        }
        else
        {
            ++self.currentGenerations;
            if( self.eachGeneration )
            {
                self.eachGeneration(self.currentGenerations, _clusters, _newCentrals);
            }
            //把所有的群聚全部打散重新變成一個陣列
            NSMutableArray *_combinedSources = [NSMutableArray new];
            for( NSArray *_eachClusters in _clusters )
            {
                [_combinedSources addObjectsFromArray:_eachClusters];
            }
            //進行迭代運算
            [self _clusterSources:(NSArray *)_combinedSources compareCenters:(NSArray *)_newCentrals];
        }
        
    }
}

@end

@implementation KRFuzzyCMeans

@synthesize centrals           = _centrals;
@synthesize patterns            = _patterns;
@synthesize results            = _results;
@synthesize convergenceError   = _convergenceError;
@synthesize limitGenerations   = _limitGenerations;
@synthesize m                  = _m;

@synthesize clusterCompletion  = _clusterCompletion;
@synthesize eachGeneration     = _eachGeneration;

@synthesize lastCenters        = _lastCenters;
@synthesize currentGenerations = _currentGenerations;

+(instancetype)sharedFCM
{
    static dispatch_once_t pred;
    static KRFuzzyCMeans *_object = nil;
    dispatch_once(&pred, ^
    {
        _object = [[KRFuzzyCMeans alloc] init];
    });
    return _object;
}

-(instancetype)init
{
    self = [super init];
    if( self )
    {
        _centrals           = [NSMutableArray new];
        _patterns            = nil;
        _results            = [NSMutableArray new];
        _convergenceError   = 0.001f;
        _limitGenerations   = 5000;
        _m                  = 2;
        
        _clusterCompletion  = nil;
        _eachGeneration     = nil;
        
        _lastCenters        = nil;
        _currentGenerations = 0;
    }
    return self;
}

/*
 * @ 直接分群，不進行迭代運算
 *   - 將數據依照跟各形心的距離直接分類至該群聚
 *   - 一般這裡是用於直接將後續數據分類至已經執行分群過的結果群聚裡
 *   - 不需要更新群聚形心
 *   - 不建議使用此方法
 */
-(void)directCluster
{
    //If it doesn't have sources, then directly use the original sets to be clustered results.
    if( _patterns == nil )
    {
        return;
    }
    
    if( [_centrals count] > 0 && [_patterns count] > 0 )
    {
        //分群結果陣列的長度 < 分群中心點的長度
        NSInteger _resultCount  = [_results count];
        NSInteger _centralCount = [_centrals count];
        if( _resultCount < _centralCount )
        {
            //填滿結果陣列長度
            NSInteger _differCount = _centralCount - _resultCount;
            int _i                 = 0;
            while ( _i < _differCount )
            {
                [_results addObject:[NSMutableArray new]];
                ++_i;
            }
        }
        
        _lastCenters = [_centrals copy]; //預留參數，暫無用處
        for( NSArray *_xy in _patterns )
        {
            float _maxDistance = 0.0f;
            int _toIndex       = 0;
            int _i             = 0;
            for( NSArray *_centers in _centrals )
            {
                float _distance = [self _distanceX1:_xy x2:_centers];
                if( _maxDistance < _distance )
                {
                    _maxDistance = _distance;
                    _toIndex     = _i;
                }
                ++_i;
            }
            //直接分群，後續都不需要更新群聚形心
            [[_results objectAtIndex:_toIndex] addObject:[_xy copy]];
        }
        
    }
}

/*
 * @ FCM 進行迭代運算不斷的重新分群
 *
 */
-(void)clusteringWithCompletion:(KRFuzzyCMeansClusteringCompletion)_completion eachGeneration:(KRFuzzyCMeansEachGeneration)_generation
{
    _clusterCompletion  = _completion;
    _eachGeneration     = _generation;
    _currentGenerations = 0;
    [self _clusterSources:_patterns compareCenters:_centrals];
}

-(void)clusteringWithCompletion:(KRFuzzyCMeansClusteringCompletion)_completion
{
    [self clusteringWithCompletion:_completion eachGeneration:nil];
}

-(void)clustering
{
    [self clusteringWithCompletion:nil];
}

-(void)addCentralX:(float)_x y:(float)_y
{
    [_centrals addObject:@[[NSNumber numberWithFloat:_x], [NSNumber numberWithFloat:_y]]];
}

-(void)addPatterns:(NSArray *)_theSets
{
    _patterns = _theSets;
}

-(void)printResults
{
    NSLog(@"centrals : %@", _centrals);
    NSLog(@"====================================\n\n\n");
    int _i = 1;
    for( NSArray *_clusters in _results )
    {
        NSLog(@"clusters (%i) : %@", _i, _clusters);
        NSLog(@"====================================\n\n\n");
        ++_i;
    }
}

#pragma --mark Blocks
-(void)setClusterCompletion:(KRFuzzyCMeansClusteringCompletion)_theBlock
{
    _clusterCompletion = _theBlock;
}

-(void)setEachGeneration:(KRFuzzyCMeansEachGeneration)_theBlock
{
    _eachGeneration    = _theBlock;
}

@end
