//
//  MZAssetsManager.m
//  MiZi
//
//  Created by Nathan Ou on 2018/8/1.
//  Copyright © 2018年 Simple. All rights reserved.
//

#import "MZAssetsManager.h"
#import "CTAssetsPageViewController.h"
#import "MZQiNiuManager.h"
#import "PHImageManager+CTAssetsPickerController.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface MZAssetsManager () <CTAssetsPickerControllerDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, strong) PHImageRequestOptions *requestOptions;
@property (nonatomic, strong) MZQiNiuManager *qiNiuManager;
@property (nonatomic, strong) CTAssetsPickerController *picker;
@end

@implementation MZAssetsManager
- (MZQiNiuManager *)qiNiuManager{
    if (!_qiNiuManager) {
        _qiNiuManager = [[MZQiNiuManager alloc] init];
    }
    return _qiNiuManager;
}
+ (instancetype)shareManager
{
    static MZAssetsManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[MZAssetsManager alloc] init];
    });
    return manager;
}

-(instancetype)init{
    if ([super init]) {
        self.imageOnly = YES;
        self.maxPhotoNum = 9;
    }
    return self;
}

- (NSMutableArray *)currentAssets
{
    if (!_currentAssets) {
        _currentAssets = [NSMutableArray array];
    }
    return _currentAssets;
}

- (void)setVideoOnly:(BOOL)videoOnly
{
    _videoOnly = videoOnly;
    _imageOnly = NO;
}

- (void)setImageOnly:(BOOL)imageOnly
{
    _imageOnly = imageOnly;
    _videoOnly = NO;
}
- (void)setImageAndOneVideo:(BOOL)imageAndOneVideo{
    _imageAndOneVideo = imageAndOneVideo;
    _imageOnly = NO;
    _videoOnly = NO;
}

#pragma mark - Picker

- (void)pickAssetsFromAblum
{
    WEAKSELF;
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status){
        dispatch_async(dispatch_get_main_queue(), ^{
            // init picker
            if(!self.picker){
                self.picker = [[CTAssetsPickerController alloc] init];
            }
            
            
            // set delegate
            self.picker.delegate = weakSelf;
            self.picker.selectedAssets = [weakSelf.currentAssets mutableCopy];
            
            if (self.imageAndOneVideo) {
                [self setVideoAndImageForPicker:self.picker];
            }
            
            if (self.imageOnly)
                [self setImageOnlyForPicker:self.picker];
            else if (self.videoOnly)
                [self setVideoOnlyForPicker:self.picker];
            
            
            // to present picker as a form sheet in iPad
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
                self.picker.modalPresentationStyle = UIModalPresentationFormSheet;
            
            if (@available(iOS 11, *)) {
                        UIScrollView.appearance.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentAutomatic;
                
            }
            
            // present picker
            UIViewController *m_controller = [UIViewController visibleViewController];
            [m_controller presentViewController:self.picker animated:YES completion:nil];
            
        });
    }];
}

- (void)setImageOnlyForPicker:(CTAssetsPickerController *)picker
{
    NSPredicate *predicateMediaType = [NSPredicate predicateWithFormat:@"mediaType = %d",PHAssetMediaTypeImage];
    NSCompoundPredicate *compoundPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[predicateMediaType]];
    picker.assetsFetchOptions = [[PHFetchOptions alloc] init];
    picker.assetsFetchOptions.predicate = compoundPredicate;
}

- (void)setVideoOnlyForPicker:(CTAssetsPickerController *)picker
{
    NSPredicate *predicateMediaType = [NSPredicate predicateWithFormat:@"mediaType = %d",PHAssetMediaTypeVideo];
    NSCompoundPredicate *compoundPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[predicateMediaType]];
    picker.assetsFetchOptions = [[PHFetchOptions alloc] init];
    picker.assetsFetchOptions.predicate = compoundPredicate;
}

- (void)setVideoAndImageForPicker:(CTAssetsPickerController *)picker
{
    
    
}

#pragma mark - Camera

- (void)pickImageFromCamera
{
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    imagePickerController.editing = YES;
    imagePickerController.delegate = (id)self;
    UIViewController *m_controller = [UIViewController visibleViewController];
    [m_controller presentViewController:imagePickerController animated:YES completion:nil];
}

- (void)pickImageFromCameraVideo{
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        // 检测设备是否支持录像。
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@""
                                                        message:@"设备无摄象头"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    UIImagePickerController* pickerView = [[UIImagePickerController alloc] init];
    pickerView.sourceType = UIImagePickerControllerSourceTypeCamera;
    NSArray* availableMedia = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
    pickerView.mediaTypes = [NSArray arrayWithObject:availableMedia[1]];
    //设置摄像头
    [self switchCameraIsFront:NO withPicker:pickerView];
    // 设置最大录像时间
    pickerView.videoMaximumDuration = 12.0f;
    //设置视频画质类别
    pickerView.videoQuality = UIImagePickerControllerQualityTypeMedium;
    //设置散光灯类型
    pickerView.cameraFlashMode = UIImagePickerControllerCameraFlashModeAuto;
    //隐藏系统自带UI
    pickerView.showsCameraControls = NO;
    pickerView.delegate = self;
    
    UIViewController *m_controller = [UIViewController visibleViewController];
    [m_controller presentViewController:pickerView animated:YES completion:nil];
    
}
///设置摄像头
- (void)switchCameraIsFront:(BOOL)front withPicker:(UIImagePickerController *) pickerView
{
    if (front) {
        if([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront]){
            [pickerView setCameraDevice:UIImagePickerControllerCameraDeviceFront];
            
        }
    } else {
        if([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear]){
            [pickerView setCameraDevice:UIImagePickerControllerCameraDeviceRear];
            
        }
    }
}



#pragma mark - Image picker delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey, id> *)info{
    //录制完的视频保存到相册
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    NSURL *recordedVideoURL= [info objectForKey:UIImagePickerControllerMediaURL];
    if ([library videoAtPathIsCompatibleWithSavedPhotosAlbum:recordedVideoURL]) {
        [library writeVideoAtPathToSavedPhotosAlbum:recordedVideoURL
                                    completionBlock:^(NSURL *assetURL, NSError *error){}
         ];
    }
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo
{
    WEAKSELF;
    __block NSString *localId = nil;
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        PHAssetChangeRequest *assetChangeRequest = [PHAssetChangeRequest creationRequestForAssetFromImage:image];
        localId = [[assetChangeRequest placeholderForCreatedAsset] localIdentifier];
    } completionHandler:^(BOOL success, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [picker dismissViewControllerAnimated:YES completion:^{
                if (!success) {
                    NSLog(@"Error creating asset: %@", error);
                } else {
                    PHFetchResult* assetResult = [PHAsset fetchAssetsWithLocalIdentifiers:@[localId] options:nil];
                    PHAsset *asset = [assetResult firstObject];
                    if (asset) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [weakSelf.currentAssets addObject:asset];
                            [weakSelf didFinishPickAssets];
                        });
                    }
                }
            }];
        });
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Assets

// implement should select asset delegate
- (BOOL)assetsPickerController:(CTAssetsPickerController *)picker shouldSelectAsset:(PHAsset *)asset
{
    NSInteger max = self.maxPhotoNum;
    
    if (asset.mediaType == PHAssetMediaTypeVideo ) {
        for (PHAsset *assets in picker.selectedAssets) {
            if (assets.mediaType == PHAssetMediaTypeVideo ) {
                UIAlertController *alert =
                [UIAlertController alertControllerWithTitle:@"提示"
                                                    message:[NSString stringWithFormat:@"最多只能选择1个视频"]
                                             preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction *action =
                [UIAlertAction actionWithTitle:@"好的"
                                         style:UIAlertActionStyleDefault
                                       handler:nil];
                
                [alert addAction:action];
                
                [picker presentViewController:alert animated:YES completion:nil];
                return  NO;
            }
        }
    }
    
    
    // show alert gracefully
    if (picker.selectedAssets.count >= max)
    {
        UIAlertController *alert =
        [UIAlertController alertControllerWithTitle:@"提示"
                                            message:[NSString stringWithFormat:@"最多只能选择%ld张照片", (long)max]
                                     preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *action =
        [UIAlertAction actionWithTitle:@"好的"
                                 style:UIAlertActionStyleDefault
                               handler:nil];
        
        [alert addAction:action];
        
        [picker presentViewController:alert animated:YES completion:nil];
    }
    
    // limit selection to max
    return (picker.selectedAssets.count < max);
}

#pragma mark - Assets Delegate

- (void)assetsPickerController:(CTAssetsPickerController *)picker didFinishPickingAssets:(NSArray *)assets
{
    if (@available(iOS 11, *)) {
        
                UIScrollView.appearance.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        
    }
    
    
    [picker.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    self.currentAssets = [NSMutableArray array];
    [self.currentAssets addObjectsFromArray:assets];
    
    [self didFinishPickAssets];
    
}

- (void)assetsPickerControllerDidCancel:(CTAssetsPickerController *)picker
{
    [picker.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)assetsPickerController:(CTAssetsPickerController *)picker shouldEnableAsset:(PHAsset *)asset
{
    if (asset.mediaType == PHAssetMediaTypeVideo) {
        if (asset.duration > 30) {
            return NO;
        }
    }
    return YES;
}

#pragma mark - Commons

- (void)reset
{
    [self.currentAssets removeAllObjects];
    self.videoOnly = NO;
    self.imageOnly = YES;
}

#pragma mark - 获取图片

- (void)getImageWithAsserts:(PHAsset *)asset
                       size:(CGSize)size
                 completion:(void (^)(UIImage *, NSData *))block
{
    
    if (!self.requestOptions) {
        self.requestOptions = [[PHImageRequestOptions alloc] init];
        self.requestOptions.resizeMode   = PHImageRequestOptionsResizeModeExact;
        self.requestOptions.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
        self.requestOptions.synchronous = YES;
        self.requestOptions.networkAccessAllowed = YES;
    }
    
    PHImageManager *manager = [PHImageManager defaultManager];
    UIScreen *screen    = UIScreen.mainScreen;
    CGFloat scale       = screen.scale;
    CGSize targetSize = CGSizeMake(size.width * scale, size.height * scale);
    
    [manager ctassetsPickerRequestImageForAsset:asset
                                     targetSize:targetSize
                                    contentMode:PHImageContentModeAspectFit
                                        options:self.requestOptions
                                  resultHandler:^(UIImage *image, NSDictionary *info){
        
        NSData *imageData;
        CGSize timageSize = CGSizeMake(1500, 1500);
        if (image.size.width >= timageSize.width && image.size.height >= timageSize.height) {
            image = [image zipImageWithSize:timageSize];
        }
        imageData = UIImageJPEGRepresentation(image, 0.5);
        
        if (block) {
            block(image, imageData);
        }
    }];
}

#pragma mark - 图片Nav

- (void)goToImagePageControllerWithIndex:(NSInteger)index
{
    CTAssetsPageViewController *vc = [[CTAssetsPageViewController alloc] initWithAssets:self.currentAssets];
    vc.pageIndex = index;
    vc.hidesBottomBarWhenPushed = YES;
    [[UIViewController visibleViewController].navigationController pushViewController:vc animated:YES];
}


#pragma mark - 选择

- (void)showImagePickerSheet
{
    NSArray *arr = @[@"从相册中选择图片",@"使用照相机"];
//    if (self.imageAndOneVideo) {
//        arr= @[@"从相册中选择图片",@"使用照相机",@"录制视频"];
//    }
    MZActionSheetView *sheet = [[MZActionSheetView alloc] initWithActionSheetWithTitle:nil ListArray:arr completeSelctBlock:^(NSInteger selectIndex) {
        [self actionSheetIndexAction:selectIndex];
    }];
    [sheet show];
}

- (void)actionSheetIndexAction:(NSInteger)selectIndex
{
    if (selectIndex == 1) {
        // 拍照
        [self pickImageFromCamera];
    }
    
    if (selectIndex == 0) {
        // 手机相册
        [self pickAssetsFromAblum];
    }
    if (selectIndex == 2) {
        [self pickImageFromCameraVideo];
    }
}

- (void)didFinishPickAssets{
    
    if (self.didFinishPickAssetsBlock) {
        self.didFinishPickAssetsBlock();
    }
}

#pragma mark - 上传
// 相册内部
- (void)uploadCurrentAssetsWithCompletion:(void (^)(BOOL, id, id))block
{
    if (self.currentAssets.count == 0) {
        !block?: block(YES, nil, nil);
        return;
    }
    //    MZSendProgressView *progressView = [MZSendProgressView showProgressView];
    MZSendProgressView *progressView ;
    
    progressView.progress = 0.f;
    self.currentProgressView = progressView;
    
    self.qiNiuManager.currenProgressBlock = nil;
    
    if (self.currentAssets.count > 0) {
        
        NSMutableArray *imageDatasArray = [NSMutableArray arrayWithCapacity:self.currentAssets.count];
        
        dispatch_group_t asset_group = dispatch_group_create();
       __block NSData *videoData;
        WEAKSELF;
        for (PHAsset *asset in self.currentAssets) {
            
            dispatch_group_enter(asset_group);
            
            
            PHImageManager *manager = [PHImageManager defaultManager];
            UIScreen *screen    = UIScreen.mainScreen;
            CGFloat scale       = screen.scale;
            CGSize targetSize = CGSizeMake(CGRectGetWidth(screen.bounds) * scale, CGRectGetHeight(screen.bounds) * scale);
            
            if (asset.mediaType == PHAssetMediaTypeVideo) {
                // 视频
//                [self uploadVideoAsset:asset completion:block];
               
                
                [self.qiNiuManager setCurrenProgressBlock:^(CGFloat progress){
                    NSLog(@"----> Progress : %f", progress);
                    weakSelf.currentProgressView.progress = progress*0.2f;
                    weakSelf.currentProgressView.bottomTipLabel.text = [NSString stringWithFormat:@"%d%%",(int)(progress*100*0.2f)];
                }];

                
                [manager ctassetsPickerRequestImageForAsset:asset
                                                 targetSize:targetSize
                                                contentMode:PHImageContentModeAspectFit
                                                    options:self.requestOptions
                                              resultHandler:^(UIImage *images, NSDictionary *info){
                    PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
                    options.version = PHImageRequestOptionsVersionCurrent;
                    options.deliveryMode = PHVideoRequestOptionsDeliveryModeFastFormat;
                    
                    [manager requestAVAssetForVideo:asset
                                            options:options
                                      resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
                        AVURLAsset* myAsset = (AVURLAsset*)asset;
                        NSData * data = [NSData dataWithContentsOfFile:myAsset.URL.relativePath];
                        if (data) {
                            videoData = data;
                            [imageDatasArray addObject:data];
                            dispatch_group_leave(asset_group);
                        }
               
                    }];
                }];

            }else{
                
                [manager ctassetsPickerRequestImageForAsset:asset
                                                 targetSize:targetSize
                                                contentMode:PHImageContentModeAspectFit
                                                    options:self.requestOptions
                                              resultHandler:^(UIImage *image, NSDictionary *info){
                    
                    NSData *imageData;
                    CGSize timageSize = CGSizeMake(2000, 2000);
                    if (image.size.width >= timageSize.width && image.size.height >= timageSize.height) {
                        image = [image zipImageWithSize:timageSize];
                    }
                    imageData = UIImageJPEGRepresentation(image, 0.3);
                    [imageDatasArray addObject:imageData];
                    
                    dispatch_group_leave(asset_group);
                }];
            }
        }
 
        
        dispatch_group_notify(asset_group, dispatch_get_main_queue(), ^{
            WEAKSELF;
            CGFloat pp = 1.00f;  //0.82f;
            weakSelf.currentProgressView.totalProgress = 0.f;
            [self.qiNiuManager setCurrenProgressBlock:^(CGFloat progress){
                if (progress==1.0) {
                    weakSelf.currentProgressView.totalProgress = weakSelf.currentProgressView.totalProgress+progress;
                    weakSelf.currentProgressView.progress = weakSelf.currentProgressView.totalProgress*pp/((CGFloat)weakSelf.currentAssets.count);
                }else
                {
                    weakSelf.currentProgressView.progress = (weakSelf.currentProgressView.totalProgress+progress)*pp/((CGFloat)weakSelf.currentAssets.count);
                }
                NSLog(@"----> assets progress : %f", progress);
                weakSelf.currentProgressView.bottomTipLabel.text = [NSString stringWithFormat:@"%d%%", (int)(weakSelf.currentProgressView.progress*100)];
            }];
            
        
            NSLog(@"------xiao-----%@",self.qiNiuManager);
            
            [self.qiNiuManager uploadImagesWithDataArray:imageDatasArray andOnlyVideoData:videoData withProgressView:progressView completion:^(BOOL success, NSMutableArray *paths) {
                [progressView dismiss];
                if (success) {
                    if (block) {
                        block(YES, paths, nil);
                    }
                }else{
                    if (block) {
                        block(NO, paths, nil);
                    }
                    [iToast  showCenter_ToastWithText:@"出错啦，再试一次哈！"];
                }
            }];
            
        });
        
    }else{
        if (block) {
            block(YES, nil, nil);
        }
    }
}

// 外部数据 imageArr
- (void)uploadImageArr:(NSArray *)imageArr Completion:(void (^)(BOOL, id, id))block
{
    if (imageArr.count == 0) {
        !block?: block(YES, nil, nil);
        return;
    }
    //    MZSendProgressView *progressView = [MZSendProgressView showProgressView];
    MZSendProgressView *progressView ;
    progressView.progress = 0.f;
    self.currentProgressView = progressView;
    
    self.qiNiuManager.currenProgressBlock = nil;
    
    if (imageArr.count > 0) {
        
        NSMutableArray *imageDatasArray = [NSMutableArray arrayWithCapacity:imageArr.count];
        
        dispatch_group_t asset_group = dispatch_group_create();
        
        WEAKSELF;
        for (UIImage *image in imageArr) {
            dispatch_group_enter(asset_group);
            NSData * imageData = UIImageJPEGRepresentation(image, 0.3);
            [imageDatasArray addObject:imageData];
            dispatch_group_leave(asset_group);
        }
        
        dispatch_group_notify(asset_group, dispatch_get_main_queue(), ^{
            WEAKSELF;
            CGFloat pp = 1.00f;  //0.82f;
            weakSelf.currentProgressView.totalProgress = 0.f;
            [self.qiNiuManager setCurrenProgressBlock:^(CGFloat progress){
                if (progress==1.0) {
                    weakSelf.currentProgressView.totalProgress = weakSelf.currentProgressView.totalProgress+progress;
                    weakSelf.currentProgressView.progress = weakSelf.currentProgressView.totalProgress*pp/((CGFloat)weakSelf.currentAssets.count);
                }else
                {
                    weakSelf.currentProgressView.progress = (weakSelf.currentProgressView.totalProgress+progress)*pp/((CGFloat)weakSelf.currentAssets.count);
                }
                NSLog(@"----> assets progress : %f", progress);
                weakSelf.currentProgressView.bottomTipLabel.text = [NSString stringWithFormat:@"%d%%", (int)(weakSelf.currentProgressView.progress*100)];
            }];
            
            NSLog(@"------xiao-----%@",self.qiNiuManager);
            [self.qiNiuManager uploadImagesWithDataArray:imageDatasArray withProgressView:progressView completion:^(BOOL success, NSMutableArray *paths) {
                [progressView dismiss];
                if (success) {
                    if (block) {
                        block(YES, paths, nil);
                    }
                }else{
                    [iToast  showCenter_ToastWithText:@"出错啦，再试一次哈！"];
                }
            }];
        });
        
    }else
    {
        if (block) {
            block(YES, nil, nil);
        }
    }
}



- (void)uploadVideoAsset:(PHAsset *)asset completion:(void (^)(BOOL, id, id))block
{
    WEAKSELF;
    PHImageManager *manager = [PHImageManager defaultManager];
    
    UIScreen *screen    = UIScreen.mainScreen;
    CGFloat scale       = screen.scale;
    CGSize targetSize = CGSizeMake(CGRectGetWidth(screen.bounds) * scale, CGRectGetHeight(screen.bounds) * scale);
    
    [self.qiNiuManager setCurrenProgressBlock:^(CGFloat progress){
        NSLog(@"----> Progress : %f", progress);
        weakSelf.currentProgressView.progress = progress*0.2f;
        weakSelf.currentProgressView.bottomTipLabel.text = [NSString stringWithFormat:@"%d%%",(int)(progress*100*0.2f)];
    }];

    
    [manager ctassetsPickerRequestImageForAsset:asset
                                     targetSize:targetSize
                                    contentMode:PHImageContentModeAspectFit
                                        options:self.requestOptions
                                  resultHandler:^(UIImage *images, NSDictionary *info){
        PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
        options.version = PHImageRequestOptionsVersionCurrent;
        options.deliveryMode = PHVideoRequestOptionsDeliveryModeFastFormat;
        
        [manager requestAVAssetForVideo:asset
                                options:options
                          resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
            AVURLAsset* myAsset = (AVURLAsset*)asset;
            NSData * data = [NSData dataWithContentsOfFile:myAsset.URL.relativePath];
            
            if (data) {
                
                [self.qiNiuManager uploadVideoWithData:data completion:^(BOOL img_success, NSString *img_fileUrl) {
                    
                    if (img_success) {
                        if (block) {
                            block(YES, @[@{@"path":img_fileUrl}], nil);
                        };
                        
                    }else{
                        [weakSelf.currentProgressView dismiss];
                        [iToast  showCenter_ToastWithText:@"出错啦，再试一次哈！"];
                    }
                }];
            }else{
                [weakSelf.currentProgressView dismiss];
                [iToast  showCenter_ToastWithText:@"出错啦，再试一次哈！"];
            }
        }];
    }];
}

- (BOOL)isCurrentVideo
{
    if (self.currentAssets.count >= 1 && [(PHAsset *)self.currentAssets.firstObject mediaType] == PHAssetMediaTypeVideo) {
        // 视频
        return YES;
    }else
        return NO;
}

@end
