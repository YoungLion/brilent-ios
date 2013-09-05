//
//  BLEventLabel.m
//  brilent-ios
//
//  Created by Yong Lin on 9/5/13.
//  Copyright (c) 2013 brilent. All rights reserved.
//

#import "BLEventLabel.h"
#import "BLEvent.h"

@interface BLEventLabel()
@property (nonatomic, strong) UILabel *label;
@end

@implementation BLEventLabel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        
    }
    return self;
}

- (void)setEvent:(BLEvent *)event
{
    _event = event;
    self.backgroundColor = [self colorFromEventType:event.type];
    self.alpha = 0.5;
    self.label.text = event.title;
    self.label.backgroundColor = [UIColor clearColor];
    [self.label sizeToFit];
}

- (UILabel *)label
{
    if (!_label) {
        _label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    }
    if (!_label.superview) {
        [self addSubview:_label];
    }
    return _label;
}

- (UIColor *)colorFromEventType:(NSString *)type
{
    if ([type isEqualToString:@"a"]) {
        return [UIColor greenColor];
    } else if ([type isEqualToString:@"r"]) {
        return [UIColor lightGrayColor];
    } else if ([type isEqualToString:@"c"]) {
        return [UIColor blueColor];
    } else {
        return [UIColor purpleColor];
    }
}
@end
