//
//  KRFuzzyCMeans.h
//  KRFuzzyCMeans V1.0
//
//  Created by Kalvar on 2015/4/6.
//  Copyright (c) 2015年 Kalvar Lin, ilovekalvar@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 * @ 訓練完成時
 *   - success     : 是否訓練成功
 *   - clusters    : 分群結果
 *   - centrals    : 群聚中心點
 *   - totalTimes  : 共迭代了幾次即達到收斂
 */
typedef void(^KRFuzzyCMeansClusteringCompletion)(BOOL success, NSArray *clusters, NSArray *centrals, NSInteger totalTimes);

/*
 * @ 每一次的迭代資料
 *   - times       : 第幾迭代運算
 *   - clusters    : 本次的分群結果
 *   - centers     : 本次的群聚中心點
 */
typedef void(^KRFuzzyCMeansEachGeneration)(NSInteger times, NSArray *clusters, NSArray *centrals);

@interface KRFuzzyCMeans : NSObject

//群聚形心集合(會被 Updated)
@property (nonatomic, strong) NSMutableArray *centrals;
//要分群的集合數據
@property (nonatomic, strong) NSArray *patterns;
//分群結果
@property (nonatomic, strong) NSMutableArray *results;
//收斂誤差
@property (nonatomic, assign) float convergenceError;
//迭代運算上限次數
@property (nonatomic, assign) NSInteger limitGenerations;
//FCM 公式 m 參數
@property (nonatomic, assign) NSInteger m;

@property (nonatomic, copy) KRFuzzyCMeansClusteringCompletion clusterCompletion;
@property (nonatomic, copy) KRFuzzyCMeansEachGeneration eachGeneration;

+(instancetype)sharedFCM;
-(instancetype)init;
-(void)directCluster;
-(void)clusteringWithCompletion:(KRFuzzyCMeansClusteringCompletion)_completion eachGeneration:(KRFuzzyCMeansEachGeneration)_generation;
-(void)clusteringWithCompletion:(KRFuzzyCMeansClusteringCompletion)_completion;
-(void)clustering;
-(void)addCentralX:(float)_x y:(float)_y;
-(void)addPatterns:(NSArray *)_theSets;
-(void)printResults;

#pragma --mark Blocks
-(void)setClusterCompletion:(KRFuzzyCMeansClusteringCompletion)_theBlock;
-(void)setEachGeneration:(KRFuzzyCMeansEachGeneration)_theBlock;

@end