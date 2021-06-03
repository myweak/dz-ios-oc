//
// Created by Shaokang Zhao on 15/1/12.
// Copyright (c) 2015 Shaokang Zhao. All rights reserved.
//

#import "SKTagButton.h"
#import "SKTag.h"
#import "SKTagView.h"

@implementation SKTagButton

+ (instancetype)buttonWithTag: (SKTag *)tag {
    
	SKTagButton *btn = [super buttonWithType:UIButtonTypeCustom];
	
	if (tag.attributedText) {
		[btn setAttributedTitle: tag.attributedText forState: UIControlStateNormal];
	} else {
		[btn setTitle: tag.text forState:UIControlStateNormal];
		[btn setTitleColor: tag.textColor forState: UIControlStateNormal];
		btn.titleLabel.font = tag.font ?: [UIFont systemFontOfSize: tag.fontSize];
	}
	
	btn.backgroundColor = tag.bgColor;
	btn.contentEdgeInsets = tag.padding;
    btn.titleLabel.numberOfLines = 0;
	
    if (tag.bgImg) {
        [btn setBackgroundImage: tag.bgImg forState: UIControlStateNormal];
    }
    
    if (tag.image) {
        [btn setImage:tag.image forState:UIControlStateNormal];
    }
    
    if (tag.borderColor) {
        btn.layer.borderColor = tag.borderColor.CGColor;
    }
    
    if (tag.borderWidth) {
        btn.layer.borderWidth = tag.borderWidth;
    }
    
    btn.userInteractionEnabled = tag.enable;
    if (tag.enable) {
        UIColor *highlightedBgColor = tag.highlightedBgColor ?: [self darkerColor:btn.backgroundColor];
        [btn setBackgroundImage:[self imageWithColor:highlightedBgColor] forState:UIControlStateHighlighted];
    }
    
    btn.layer.cornerRadius = tag.cornerRadius;
    btn.layer.masksToBounds = YES;
    tag.tagButton = btn;
    
    return btn;
}

+ (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();

    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return image;
}

+ (UIColor *)darkerColor:(UIColor *)color {
    CGFloat h, s, b, a;
    if ([color getHue:&h saturation:&s brightness:&b alpha:&a])
        return [UIColor colorWithHue:h
                          saturation:s
                          brightness:b * 0.85
                               alpha:a];
    return color;
}


-(CGSize)intrinsicContentSize {
    
    CGSize size = [super intrinsicContentSize];
    
    SKTagView * superView = (SKTagView *)self.superview;
    
    if (size.width <= superView.preferredMaxLayoutWidth) {
        return size;
    }
    CGSize maxSize = CGSizeMake(superView.preferredMaxLayoutWidth, MAXFLOAT);
    
    maxSize.width -= (
                      self.contentEdgeInsets.left +
                      self.contentEdgeInsets.right +
                      self.currentImage.size.width
                      );

    CGSize newSize = [self.titleLabel.text boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:self.titleLabel.font} context:nil].size;
    
    newSize.width += (
                      self.contentEdgeInsets.left +
                      self.contentEdgeInsets.right +
                      self.currentImage.size.width
                      );
    
    newSize.height += (
                       self.contentEdgeInsets.top +
                       self.contentEdgeInsets.bottom
                       );
    
    newSize.width = ceil(newSize.width);
    newSize.height = ceil(newSize.height);

    return newSize;
}

@end
