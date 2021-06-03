//
//  RrAddImageView.m
//  Scanner
//
//  Created by edz on 2020/7/28.
//  Copyright © 2020 rrdkf. All rights reserved.
//

#import "RrAddImageView.h"

@interface RrAddImageView ()

@end
@implementation RrAddImageView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self createUI];
    }
    return self;
}

- (void)createUI{
    self.backgroundColor = [UIColor whiteColor];
    //    [self addSubview:self.contenViewBg];
    [self addCornerRadius:7.0f];
    [self addSubview:self.titleLabel];
    [self.titleLabel sizeToFit];
    self.subLabel.left = self.titleLabel.right +16;
    [self addSubview:self.subLabel];
    [self addSubview:self.addPView];
    
    @weakify(self)
    self.addPView.complemntBlock = ^(AddPhotoView * photoView) {
        @strongify(self)
        CGFloat height = photoView.bottom;
        self.height = height;
        !self.complemntBlock ?:self.complemntBlock(self);
        
    };
}
- (void)updateLayout{
    [self.titleLabel sizeToFit];
    self.subLabel.left = self.titleLabel.right +16;
    _subLabel.hidden = NO;

}

- (void)layoutSubviews{
    
}
-(void)drawRect:(CGRect)rect{
    
}

//- (UIView *)contenViewBg{
//    if (!_contenViewBg) {
//        _contenViewBg  = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height)];
//        _contenViewBg.backgroundColor = [UIColor yellowColor];
//        [_contenViewBg bezierPathWithRoundingCorners:(UIRectCornerAllCorners) cornerRadius:7.0f];
//    }
//    _contenViewBg.height = self.height;
//    return _contenViewBg;
//}

- (AddPhotoView *)addPView{
    if (!_addPView) {
        AddPhotoView *addPView = [[AddPhotoView alloc] initWithFrame:CGRectMake(17, self.titleLabel.bottom+ iPH(16), self.width -17*2, iPH(85))];
        _addPView = addPView;
    }
    return _addPView;
}


- (UILabel *)titleLabel{
    if (!_titleLabel) {
        UILabel * titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(17, 17, 300, 21)];
        titleLabel.text = @"上传测量数据";
        titleLabel.font = KFont20;
        titleLabel.textColor = [UIColor c_mianblackColor];
        _titleLabel = titleLabel;
    }
    return _titleLabel;
}

- (UILabel *)subLabel{
    if (!_subLabel) {
        _subLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.titleLabel.right+16, self.titleLabel.top+2, 300, 21)];
        _subLabel.text = @"（最多上传8张图片）";
        _subLabel.hidden = YES;
        _subLabel.font = KFont16;
        _subLabel.textColor = [UIColor redColor];
    }
    return _subLabel;
}




@end
