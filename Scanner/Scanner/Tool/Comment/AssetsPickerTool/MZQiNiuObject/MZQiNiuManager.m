//
//  MZQiNiuManager.m
//  Scanner
//
//  Created by edz on 2020/7/8.
//  Copyright © 2020 rrdkf. All rights reserved.
//

#import "MZQiNiuManager.h"
#import <QiniuSDK.h>
#import "NSDate+MTDates.h"
#import "RRNetWorkingManager.h"
#import<QNConfiguration.h>

#define m_rootPath @"data/upload/timeline/"
#define m_soundPath @"data/upload/user_audio/"
#define m_GifPath @"data/upload/emoji/"

@interface MZQiNiuManager ()

@property (nonatomic, strong) NSMutableArray *imagesDataArray;

@end

@implementation MZQiNiuManager

+ (instancetype)shareManager
{
    static MZQiNiuManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[MZQiNiuManager alloc] init];
    });
    return manager;
}

- (void)uploadImagesWithDataArray:(NSMutableArray *)array andOnlyVideoData:(NSData *)videoData withProgressView:(MZSendProgressView *)progressView completion:(void(^)(BOOL success, NSMutableArray *paths))block
{
    self.imagesDataArray = array;
    [self tryUploadCurrentDatas:[NSMutableArray array]  andOnlyVideoData:videoData perCompletionBlock:^(int count){
        
    } WithCompletion:block];
}

- (void)tryUploadCurrentDatas:(NSMutableArray *)currentPaths andOnlyVideoData:(NSData *)videoData perCompletionBlock:(void(^)(int count))perComplete WithCompletion:(void(^)(BOOL success, NSMutableArray *paths))block
{
    if (self.imagesDataArray.count>0) {
        NSData *data = self.imagesDataArray.firstObject;
        NSString *fileTypeStr = @"jpg";
        if ([data isEqualToData:videoData]) {
            fileTypeStr = @"mp4";
        }
        __strong MZQiNiuManager *weakSelf = self;
        [self uploadImageAndVideoWithData:data fileTypeStr:fileTypeStr completion:^(BOOL success, NSString *fileUrl) {
            if (success) {
//                @strongify(self)
                [currentPaths addObject:@{@"path":fileUrl}];
                if (weakSelf.imagesDataArray.count >0) {
                    [weakSelf.imagesDataArray removeObjectAtIndex:0];
                }
                [weakSelf tryUploadCurrentDatas:currentPaths andOnlyVideoData:videoData perCompletionBlock:perComplete WithCompletion:block];
            }else
            {
                if (block) {
                    block(NO, nil);
                }
            }
            
            if (perComplete) {
                perComplete((int)currentPaths.count);
            }
        }];
    }else{
        if (block) {
            block(YES, currentPaths);
        }
    }
}

- (void)uploadImagesWithDataArray:(NSMutableArray *)array  withProgressView:(MZSendProgressView *)progressView completion:(void(^)(BOOL success, NSMutableArray *paths))block
{
    self.imagesDataArray = array;
    [self tryUploadCurrentDatas:[NSMutableArray array]  perCompletionBlock:^(int count){
        
    } WithCompletion:block];
}

- (void)tryUploadCurrentDatas:(NSMutableArray *)currentPaths  perCompletionBlock:(void(^)(int count))perComplete WithCompletion:(void(^)(BOOL success, NSMutableArray *paths))block
{
    if (self.imagesDataArray.count>0) {
        NSData *data = self.imagesDataArray.firstObject;
        NSString *fileTypeStr = @"jpg";
        __strong MZQiNiuManager *weakSelf = self;
        [self uploadImageAndVideoWithData:data fileTypeStr:fileTypeStr completion:^(BOOL success, NSString *fileUrl) {
            if (success) {
//                @strongify(self)
                [currentPaths addObject:@{@"path":fileUrl}];
                if (weakSelf.imagesDataArray.count >0) {
                    [weakSelf.imagesDataArray removeObjectAtIndex:0];
                }
                [weakSelf tryUploadCurrentDatas:currentPaths perCompletionBlock:perComplete WithCompletion:block];
            }else
            {
                if (block) {
                    block(NO, nil);
                }
            }
            
            if (perComplete) {
                perComplete((int)currentPaths.count);
            }
        }];
    }else{
        if (block) {
            block(YES, currentPaths);
        }
    }
}
////--------------------------------------------这里需要简化--------------------------------------------------------------------------------
//上传文件
- (void)uploadFiledWithData:(NSData *)imageData fileName:(NSString *)fileName fileTypeStr:(NSString *)fileTypeStr completion:(void(^)(BOOL success, NSString *fileUrl))block
{   // doctor空间名
    [self uploadImageWithData:imageData name:MZQiNiuManager_FieldName fileName:fileName fileTypeStr:fileTypeStr  completion:block];
}
- (void)uploadVideoWithData:(NSData *)imageData completion:(void(^)(BOOL success, NSString *fileUrl))block
{   // doctor空间名
    [self uploadImageWithData:imageData name:MZQiNiuManager_FieldName fileName:[NSString NA_UUIDString] fileTypeStr:@"mp4" completion:block];
}
/// 根据fileTypeStr： ;jpg ; mp4   图片和视频 生产url
- (void)uploadImageAndVideoWithData:(NSData *)imageData fileTypeStr:(NSString *)fileTypeStr  completion:(void(^)(BOOL success, NSString *fileUrl))block
{   // doctor空间名
    [self uploadImageWithData:imageData name:MZQiNiuManager_FieldName fileName:[NSString NA_UUIDString] fileTypeStr:fileTypeStr completion:block];
}


- (void)uploadImageWithData:(NSData *)imageData completion:(void(^)(BOOL success, NSString *fileUrl))block
{   // doctor空间名
    [self uploadImageWithData:imageData name:MZQiNiuManager_FieldName completion:block];
}

- (void)uploadImageWithData:(NSData *)imageData name:(NSString *)name completion:(void(^)(BOOL success, NSString *fileUrl))block{
    [self uploadImageWithData:imageData name:name fileName:[NSString NA_UUIDString] fileTypeStr:@"jpg" completion:block];
}
////----------------------------------------------------------------------------------------------------------------------------
- (void)uploadImageWithData:(NSData *)imageData name:(NSString *)name fileName:(NSString *)fileName fileTypeStr:(NSString *)fileTypeStr completion:(void(^)(BOOL success, NSString *fileUrl))block
{
    __strong MZQiNiuManager *strongSelf = self;
    [[RRNetWorkingManager sharedSessionManager] getQiNiuImageUrl:@{name:name}     result:ResultBlockMake(^(NSDictionary * _Nonnull dict, RrResponseModel * _Nonnull responseModel, NSError * _Nonnull error) {
        if (!error) {
            NSString *fileName_copy = fileName;
            if(fileName.length == 0 || fileName == nil){
                fileName_copy = [NSString NA_UUIDString];//jpg
            }
            NSString *fileName_str = [NSString stringWithFormat:@"%@.%@", fileName_copy,fileTypeStr];
//            uploadData.rootPath
            NSString *mimeType =@"image/*";
            if ([fileTypeStr isEqualToString:@"mp4"]) {
                mimeType =@"video/*";
            }
            [strongSelf uploadData:imageData path:@"" fileNamePath:fileName_str mimeType:mimeType token:responseModel.data withCompletion:block];
        }else{
            if (block) {
                block(NO, nil);
            }
        }
    }, nil)];

}

- (void)uploadVideoData:(NSData *)video completion:(void (^)(BOOL, NSString *))block
{
    WEAKSELF;
//    [[RRNetWorkingManager sharedSessionManager] getUploadDataWithName:@"video" completion:^(BOOL succeeded, id responseObject, NSError *error) {
//        if (succeeded) {
//            MZUploadDatas *uploadData = [[MZUploadDatas alloc] safeInitWithDictionary:responseObject error:nil];
//
//            NSString *fileName = [NSString NA_UUIDString];
//            NSString *fileName_str = [NSString stringWithFormat:@"%@.mp4", fileName];
//
//            [self uploadData:video path:@"" fileNamePath:fileName_str mimeType:@"video/*" token:uploadData.token withCompletion:block];
//        }else{
//            if (block) {
//                block(NO, nil);
//            }
//        }
//    }];
}

/// 七牛。请求资源url
- (void)uploadData:(NSData *)data path:(NSString *)path fileNamePath:(NSString *)fn_path mimeType:(NSString *)mimeType token:(NSString *)token withCompletion:(void(^)(BOOL success, NSString *filePath))block
{
//    video

    QNConfiguration *config = [QNConfiguration build:^(QNConfigurationBuilder *builder) {
        builder.useConcurrentResumeUpload = YES;
        builder.chunkSize = 10 * 1024;
        builder.putThreshold = 4;
        builder.timeoutInterval = 120;
    }];
    
    QNUploadManager *upManager = [QNUploadManager sharedInstanceWithConfiguration:config];

 @weakify(self)
    QNUploadOption *option = [[QNUploadOption alloc] initWithMime:mimeType progressHandler:^(NSString *key, float percent) {
        dispatch_async(dispatch_get_main_queue(), ^{
            @strongify(self)
            if (self.currenProgressBlock) {
                self.currenProgressBlock(percent);
            }
            NSLog(@"上传进度 %.2f", percent);
        });
    } params:nil checkCrc:NO cancellationSignal:nil];
    
    
    
    
    [upManager putData:data key:fn_path token:token
              complete: ^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
                  if (info.statusCode == 200) {
                      // 成功
                      if (block) block(YES, [NSString stringWithFormat:@"%@",fn_path]);
                  }else{
                      block(NO, nil);
                  }
              } option:option];
}

@end
