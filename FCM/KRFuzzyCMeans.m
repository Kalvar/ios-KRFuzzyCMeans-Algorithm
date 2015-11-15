//
//  KRFuzzyCMeans.m
//  KRFuzzyCMeans V1.1
//
//  Created by Kalvar on 2015/4/6.
//  Copyright (c) 2015年 Kalvar Lin, ilovekalvar@gmail.com. All rights reserved.
//

#import "KRFuzzyCMeans.h"
#import "KRFuzzyCMeansSaves.h"

@interface KRFuzzyCMeans()

//上一次運算的群聚中心點集合
@property (nonatomic, strong) NSMutableArray *lastCenters;
//當前的迭代數
@property (nonatomic, assign) NSInteger currentIteration;
//儲存訓練好的群心和其它數據
@property (nonatomic, strong) KRFuzzyCMeansSaves *trainedSaves;

@end

@implementation KRFuzzyCMeans(fixDistance)

// Euclidean distance which multi-dimensional formula, 距離越小越近
-(float)_distanceEuclideanX1:(NSArray *)_x1 x2:(NSArray *)_x2
{
    NSInteger _index = 0;
    float _sum       = 0.0f;
    for( NSNumber *_x in _x1 )
    {
        _sum        += powf([_x floatValue] - [[_x2 objectAtIndex:_index] floatValue], 2);
        ++_index;
    }
    //return _sum;
    // 累加完距離後直接開根號
    return (_index > 0) ? sqrtf(_sum) : _sum;
}

// Cosine Similarity method that multi-dimensional, 同歸屬度越大越近
-(float)_distanceCosineSimilarityX1:(NSArray *)_x1 x2:(NSArray *)_x2
{
    float _sumA  = 0.0f;
    float _sumB  = 0.0f;
    float _sumAB = 0.0f;
    int _index   = 0;
    for( NSNumber *_featureValue in _x1 )
    {
        NSNumber *_trainValue = [_x2 objectAtIndex:_index];
        float _aValue  = [_featureValue floatValue];
        float _bValue  = [_trainValue floatValue];
        _sumA         += ( _aValue * _aValue );
        _sumB         += ( _bValue * _bValue );
        _sumAB        += ( _aValue * _bValue );
        ++_index;
    }
    float _ab = _sumA * _sumB;
    return ( _ab > 0.0f ) ? ( _sumAB / sqrtf( _ab ) ) : 0.0f;
}

// 距離概念是越小越近，歸屬度概念是越大越近 ( 或取其差值，使歸屬度同距離越小越近 )
-(float)_distanceX1:(NSArray *)_x1 x2:(NSArray *)_x2
{
    float _distance = 0.0f;
    switch (self.distanceFormula)
    {
        case KRFuzzyCMeansDistanceFormulaByCosine:
            _distance = 1.0f - [self _distanceCosineSimilarityX1:_x1 x2:_x2];
            break;
        case KRFuzzyCMeansDistanceFormulaByEuclidean:
            _distance = [self _distanceEuclideanX1:_x1 x2:_x2];
            break;
        default:
            break;
    }
    return _distance;
}

@end

@implementation KRFuzzyCMeans(fixSaves)

-(void)_saveCenters
{
    [self.trainedSaves saveCenters:self.centrals];
}

-(NSArray *)_fetchSavedCenters
{
    return [self.trainedSaves fetchCenters];
}

@end

@implementation KRFuzzyCMeans(fixClusters)

-(void)_doneClustering
{
    if( self.doneThenSave )
    {
        [self _saveCenters];
    }
    
    if( self.clusterCompletion )
    {
        self.clusterCompletion(YES, self.results, self.centrals, self.currentIteration);
    }
}

// 更新群聚形心
-(NSArray *)_updateCenters:(NSArray *)_centers memberships:(NSArray *)_xMembersips patterns:(NSArray *)_sources
{
    /*
     * @ Design thinks before
     *   - 如果在上面的 for{} 區塊進行歸屬度累加計算，就必須同時考量存取 N 個 Array ( 裡面儲存對每一個形心做 SUM 的數值 ) 的效能，
     *     同時重複存取 Array 的次數越多，其 performance 就越差，會遠比使用單一 for{} 來重複做事要更沒效能，
     *     因此，這裡才改用單一 for{} 來做多重存取，以避免重複操作太多 arraies 造成效能大降的問題，
     *     也就是「一次只更新一個形心」，單純化計算模式，也一併保留日後維護與改進的容易度。
     *
     */
    //都計算完歸屬度與分群後，就執行更新形心的動作
    float _m                     = self.m;
    NSMutableArray *_newCentrals = [NSMutableArray new];
    //先取出每一個舊的形心
    NSInteger _clusterIndex      = 0;
    for( NSArray *_centerXy in _centers )
    {
        NSMutableArray *_newCentralFeatures = [NSMutableArray new];
        NSInteger _featureCount = [_centerXy count];
        for( NSInteger _featureIndex = 0; _featureIndex < _featureCount; ++_featureIndex)
        {
            //每一個 New Central 的 Feature 值
            float _sumFeature       = 0.0f;
            //每個群心的總歸屬度母數, Sums the membership ratio of xi to be usded on updating new centers.
            float _sumMembership    = 0.0f;
            NSInteger _patternIndex = 0;
            //取出每一個相對的 source pattern
            for( NSArray *_patterns in _sources )
            {
                //取出每一個點的及其對該群心的 Membership
                NSArray *_memberships        = [_xMembersips objectAtIndex:_patternIndex];
                NSNumber *_centralMembership = [_memberships objectAtIndex:_clusterIndex];
                float _membershipRatio       = powf([_centralMembership floatValue], _m);
                
                //取出每一個點的 Feature, (x, y, z, ...)
                NSNumber *_feature           = [_patterns objectAtIndex:_featureIndex];
                
                //將歸屬度 ^m 後的值相加，要用在之後更新群心時要除的分母
                _sumMembership              += _membershipRatio;
                
                //加總每一個點的 Feature
                _sumFeature                 += [_feature floatValue] * _membershipRatio;
                
                ++_patternIndex;
            }
            
            //更新群聚形心的每一個特徵值
            float _newCentralFeatureValue = _sumFeature / _sumMembership;
            [_newCentralFeatures addObject:[NSNumber numberWithFloat:_newCentralFeatureValue]];
        }
        
        //放入新的群聚形心
        [_newCentrals addObject:_newCentralFeatures];
        
        ++_clusterIndex;
    }
    return _newCentrals;
}

// 進行 Patterns 分類和歸屬度運算
// return [0] = 分類好的群聚, [1] = 每一個 Pattern 對每一群心的歸屬度
-(NSArray *)_clusteringPatterns:(NSArray *)_sources centers:(NSArray *)_centers
{
    float _m                  = self.m;
    NSMutableArray *_clusters = [NSMutableArray new];
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
        //Xi (_xy) 跟每一個群聚中心點作比較，計算出歸屬度( Membership )
        //得先知道當前這 Xi 對每一個群聚的歸屬度，故須先求出對每一個點的距離數值才能再做後續處理
        NSMutableArray *_distances = [NSMutableArray new];
        for( NSArray *_centerXy in _centers )
        {
            //個別求出要分群的集合跟其它集合體的距離( 簡化公式因 FCM 公式為 ||dist||^2，故平方根抵消 )
            //這裡遵循 FCM 原公式* 不先做平方根抵消
            float _distance = [self _distanceX1:_centerXy x2:_xy];
            //儲存該 Xi 對每一個形心的距離
            [_distances addObject:[NSNumber numberWithFloat:_distance]];
        }
        
        //計算該 Xi 點對每一群聚的歸屬度
        NSMutableArray *_memberships = [NSMutableArray new];
        int _toClusterIndex          = 0;
        float _maxMembership         = -1.0f;
        int _j                       = 0;
        //取出 Xi 對每群心的距離
        for( NSNumber *_xDistance in _distances )
        {
            float _selfDistance = [_xDistance floatValue];
            float _sumRatio     = 0.0f;
            for( NSNumber *_centerDistance in _distances )
            {
                float _membershipRatio = 0.0f;
                if( [_centerDistance floatValue] != 0.0f )
                {
                    // _selfDistance = 58, _centerDistance = 68 ; 1 / (58/58 + 58/68) ...
                    //這裡遵循 FCM 原公式*, Follows FCM original formula since it already did the sqrt(distance) on the above.
                    //https://en.wikipedia.org/wiki/Fuzzy_clustering
                    _membershipRatio   = _selfDistance / [_centerDistance floatValue];
                }
                _sumRatio += _membershipRatio;
            }
            //指定群聚的歸屬度, ex : 第 1 次迴圈 for 第 1 群、第 2 次迴圈 for 第 2 群、第 n 次迴圈 for 第 n 群 ...，一次一次的計算
            //float _clusterMembership = 1 / ( powf(_sumRatio, ( 1 / (_m - 1)) ) );
            float _clusterMembership = 1 / ( powf(_sumRatio, ( 2 / (_m - 1)) ) );
            
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
    return @[_clusters, _xMembersips];
}

// 取出跟上一次舊的群聚形心相比的最大誤差值
-(float)_calculateErrorDistanceFromNewCenters:(NSArray *)_newCenters oldCenters:(NSArray *)_oldCenters
{
    float _maxDistance     = 0.0f;
    NSInteger _centerIndex = 0;
    for( NSArray *_compareNewCenters in _newCenters )
    {
        NSArray *_compareOldCenters = [_oldCenters objectAtIndex:_centerIndex];
        //跟 _centerXy 的距離做比較
        float _differDistance       = [self _distanceX1:_compareOldCenters x2:_compareNewCenters];
        
        //NSLog(@"_differDistance : %f", _differDistance);
        
        if( _maxDistance < _differDistance )
        {
            _maxDistance = _differDistance;
        }
        ++_centerIndex;
    }
    return _maxDistance;
}

// 依照群聚中心點(形心) _centers 進行 _sources 群聚分類
-(void)_clusterSources:(NSArray *)_sources compareCenters:(NSArray *)_centers
{
    if( [_centers count] > 0 )
    {
        if( self.m < 2 )
        {
            self.m = 2;
        }
        NSArray *_results     = [self _clusteringPatterns:_sources centers:_centers];
        NSArray *_clusters    = [_results objectAtIndex:0];
        NSArray *_membersips  = [_results objectAtIndex:1];
        NSArray *_newCentrals = [self _updateCenters:_centers memberships:_membersips patterns:_sources];
        float _maxDistance    = [self _calculateErrorDistanceFromNewCenters:_newCentrals oldCenters:_centers];
        [self.centrals removeAllObjects];
        [self.centrals addObjectsFromArray:_newCentrals];
        
        //如果跟上次的最大誤差距離 <= 誤差值，就收斂。( 新舊相等 == 0.0f 也是小於誤差值 )
        if( _maxDistance <= self.convergenceError || self.currentIteration >= self.maxIteration )
        {
            [self.results removeAllObjects];
            [self.results addObjectsFromArray:_clusters];
            [self _doneClustering];
        }
        else
        {
            ++self.currentIteration;
            if( self.perIteration )
            {
                self.perIteration(self.currentIteration, _clusters, _newCentrals);
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

+(instancetype)sharedFCM
{
    static dispatch_once_t pred;
    static KRFuzzyCMeans *_object = nil;
    dispatch_once(&pred, ^{
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
        _patterns           = [NSMutableArray new];
        _results            = [NSMutableArray new];
        _convergenceError   = 0.001f;
        _maxIteration       = 5000;
        _m                  = 2;
        _doneThenSave       = YES;
        
        _clusterCompletion  = nil;
        _perIteration       = nil;
        
        _lastCenters        = nil;
        _currentIteration   = 0;
        
        _distanceFormula    = KRFuzzyCMeansDistanceFormulaByEuclidean;
        _trainedSaves       = [KRFuzzyCMeansSaves sharedInstance];
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
-(void)directClusterPatterns:(NSArray *)_directPatterns
{
    //If it doesn't have sources, then directly use the original sets to be clustered results.
    if( _directPatterns == nil || [_directPatterns count] < 1 )
    {
        return;
    }
    
    [self addPatterns:_directPatterns];
    
    if( [_centrals count] > 0 )
    {
        //分群結果陣列的組數 < 分群中心點的組數
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
        for( NSArray *_xy in _directPatterns )
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
-(void)clusterWithCompletion:(KRFuzzyCMeansClusteringCompletion)_completion perIteration:(KRFuzzyCMeansPerIteration)_generation
{
    _clusterCompletion  = _completion;
    _perIteration       = _generation;
    _currentIteration   = 0;
    [self _clusterSources:_patterns compareCenters:_centrals];
}

-(void)clusterWithCompletion:(KRFuzzyCMeansClusteringCompletion)_completion
{
    [self clusterWithCompletion:_completion perIteration:nil];
}

-(void)cluster
{
    [self clusterWithCompletion:nil];
}

-(void)addCenters:(NSArray *)_theCenters
{
    [_centrals addObject:_theCenters];
}

-(void)addPatterns:(NSArray *)_theSets
{
    [_patterns addObjectsFromArray:_theSets];
}

// Recalling trained centers which saved in KRFuzzyCMeansSaves
-(void)recallCenters
{
    NSArray *_savedCenters = [self _fetchSavedCenters];
    if( nil != _savedCenters )
    {
        [_centrals removeAllObjects];
        [_centrals addObjectsFromArray:_savedCenters];
    }
}

-(void)printResults
{
    NSLog(@"=================== printResults (Start) =================\n\n\n");
    NSLog(@"centrals : %@", _centrals);
    int _i = 1;
    for( NSArray *_clusters in _results )
    {
        NSLog(@"clusters (%i) : %@", _i, _clusters);
        NSLog(@"---------------------------------------------\n\n\n");
        ++_i;
    }
    NSLog(@"=================== printResults (End) =================\n\n\n");
}

#pragma --mark Blocks
-(void)setClusterCompletion:(KRFuzzyCMeansClusteringCompletion)_theBlock
{
    _clusterCompletion = _theBlock;
}

-(void)setPerIteration:(KRFuzzyCMeansPerIteration)_theBlock
{
    _perIteration = _theBlock;
}

@end
