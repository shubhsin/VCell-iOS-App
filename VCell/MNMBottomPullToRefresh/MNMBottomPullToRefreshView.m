/*
 * Copyright (c) 2012 Mario Negro Martín
 *
 * Permission is hereby granted, free of charge, to any person obtaining
 * a copy of this software and associated documentation files (the
 * "Software"), to deal in the Software without restriction, including
 * without limitation the rights to use, copy, modify, merge, publish,
 * distribute, sublicense, and/or sell copies of the Software, and to
 * permit persons to whom the Software is furnished to do so, subject to
 * the following conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 * LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 * OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 * WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#import "MNMBottomPullToRefreshView.h"

/*
 * Defines the localized strings table
 */
#define MNM_BOTTOM_PTR_LOCALIZED_STRINGS_TABLE                          @"MNMBottomPullToRefresh"
/*
 * Texts to show in different states
 */
#define MNM_BOTTOM_PTR_PULL_TEXT_KEY                                    NSLocalizedStringFromTable(@"MNM_BOTTOM_PTR_PULL_TEXT", MNM_BOTTOM_PTR_LOCALIZED_STRINGS_TABLE, nil)
#define MNM_BOTTOM_PTR_RELEASE_TEXT_KEY                                 NSLocalizedStringFromTable(@"MNM_BOTTOM_PTR_RELEASE_TEXT", MNM_BOTTOM_PTR_LOCALIZED_STRINGS_TABLE, nil)
#define MNM_BOTTOM_PTR_LOADING_TEXT_KEY                                 NSLocalizedStringFromTable(@"MNM_BOTTOM_PTR_LOADING_TEXT", MNM_BOTTOM_PTR_LOCALIZED_STRINGS_TABLE, nil)

/*
 * Defines icon image
 */
#define MNM_BOTTOM_PTR_ICON_BOTTOM_IMAGE                                @"MNMBottomPullToRefreshArrow.png"

@interface MNMBottomPullToRefreshView()

/*
 * View that contains all controls
 */
@property (nonatomic, readwrite, strong) UIView *containerView;

/*
 * Image with the icon that changes with states
 */
@property (nonatomic, readwrite, strong) UIImageView *iconImageView;

/*
 * Activiry indicator to show while loading
 */
@property (nonatomic, readwrite, strong) UIActivityIndicatorView *loadingActivityIndicator;

/*
 * Current state of the control
 */
@property (nonatomic, readwrite, assign) MNMBottomPullToRefreshViewState state;

/*
 * YES to apply rotation to the icon while view is in MNMBottomPullToRefreshViewStatePull state
 */
@property (nonatomic, readwrite, assign) BOOL rotateIconWhileBecomingVisible;

@property (nonatomic, assign) int repeatCount; // Used for bottom refresh

@end

@implementation MNMBottomPullToRefreshView

@synthesize containerView = containerView_;
@synthesize iconImageView = iconImageView_;
@synthesize loadingActivityIndicator = loadingActivityIndicator_;
@synthesize state = state_;
@synthesize rotateIconWhileBecomingVisible = rotateIconWhileBecomingVisible_;
@dynamic isLoading;
@synthesize fixedHeight = fixedHeight_;

#pragma mark -
#pragma mark Initialization

/*
 * Initializes and returns a newly allocated view object with the specified frame rectangle.
 *
 * @param aRect: The frame rectangle for the view, measured in points.
 * @return An initialized view object or nil if the object couldn't be created.
 */
- (id)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        
        [self setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin];
        [self setBackgroundColor:[UIColor colorWithWhite:1.0f alpha:1.0f]];
        
        containerView_ = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(frame), CGRectGetHeight(frame))];
        
        [containerView_ setBackgroundColor:[UIColor clearColor]];
        [containerView_ setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin];
        
        [self addSubview:containerView_];
        
        UIImage *iconImage = [UIImage imageNamed:@"loadingIcon.png"];
        
        iconImageView_ = [[UIImageView alloc] initWithFrame:CGRectMake(30.0f, round(CGRectGetHeight(frame) / 2.0f) - round([iconImage size].height / 2.0f), [iconImage size].width, [iconImage size].height)];
        [iconImageView_ setContentMode:UIViewContentModeCenter];
        [iconImageView_ setImage:iconImage];
        [iconImageView_ setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin];
        
        iconImageView_.center = CGPointMake(containerView_.center.x, self.frame.size.height/2);
        
        [containerView_ addSubview:iconImageView_];
        
        loadingActivityIndicator_ = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        [loadingActivityIndicator_ setCenter:[iconImageView_ center]];
        [loadingActivityIndicator_ setHidden:YES];
        [loadingActivityIndicator_ setAlpha:0];
        [loadingActivityIndicator_ setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin];
        
        [containerView_ addSubview:loadingActivityIndicator_];
        
        fixedHeight_ = CGRectGetHeight(frame);
        rotateIconWhileBecomingVisible_ = YES;
        
        [self changeStateOfControl:MNMBottomPullToRefreshViewStateIdle offset:CGFLOAT_MAX];
    }
    
    return self;
}

#pragma mark -
#pragma mark Visuals

/*
 * Lays out subviews.
 */
- (void)layoutSubviews {
    
    [super layoutSubviews];
    CGRect frame = containerView_.frame;
    frame.size.width = 320;
    containerView_.frame = frame;
}

/*
 * Changes the state of the control depending on state_ value
 */
- (void)changeStateOfControl:(MNMBottomPullToRefreshViewState)state offset:(CGFloat)offset {
    
    state_ = state;
    
    CGFloat height = fixedHeight_;
    
    switch (state_) {
            
        case MNMBottomPullToRefreshViewStateIdle: {
            
            [iconImageView_ setTransform:CGAffineTransformIdentity];
            [iconImageView_ setHidden:NO];
            
            [loadingActivityIndicator_ stopAnimating];
            [self iconImageViewStopAnimation];
            
            break;
            
        } case MNMBottomPullToRefreshViewStatePull: {
            
            if (rotateIconWhileBecomingVisible_) {
                
                CGFloat angle = 30*(-offset * M_PI) / CGRectGetHeight([self.superview frame]);
                CGAffineTransform scale = CGAffineTransformMakeScale((- offset / 60) ,(- offset / 60));
                [iconImageView_ setTransform:CGAffineTransformRotate(scale, angle)];
                
            } else {
                [iconImageView_ setTransform:CGAffineTransformIdentity];
            }
            
            break;
            
        } case MNMBottomPullToRefreshViewStateRelease: {
            
            CGFloat angle = 30*(-offset * M_PI) / CGRectGetHeight([self.superview frame]);
            [iconImageView_ setTransform:CGAffineTransformRotate(CGAffineTransformIdentity, angle)];
            
            height = fixedHeight_ + fabs(offset);
            
            break;
            
        } case MNMBottomPullToRefreshViewStateLoading: {
            
            [loadingActivityIndicator_ startAnimating];
            self.repeatCount = 3;
            [self iconImageViewStartAnimation];
            
            height = fixedHeight_ + fabs(offset);
            
            break;
            
        } default:
            break;
    }
    
    CGRect frame = [self frame];
    frame.size.height = height;
    [self setFrame:frame];
    
    [self setNeedsLayout];
}

#pragma mark -
#pragma mark Properties

/*
 * Returns state of activity indicator
 */
- (BOOL)isLoading {
    
    return [loadingActivityIndicator_ isAnimating];
}

- (void)iconImageViewStartAnimation {
    [UIView animateWithDuration:0 animations:^{
        [iconImageView_ setTransform:CGAffineTransformIdentity];
    } completion:^(BOOL finished) {
        CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        rotationAnimation.delegate = self;
        rotationAnimation.fromValue = [NSNumber numberWithDouble:0];
        rotationAnimation.toValue = [NSNumber numberWithDouble:M_PI * 2.0];
        rotationAnimation.duration = .4;
        rotationAnimation.repeatCount = self.repeatCount;
        rotationAnimation.cumulative = YES;
        [iconImageView_.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
        
    }];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if (flag == NO) return;
    self.repeatCount--;
    [iconImageView_.layer removeAllAnimations];
    CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.fromValue = [NSNumber numberWithDouble:0];
    rotationAnimation.toValue = [NSNumber numberWithDouble:M_PI * 2.0];
    
    switch (self.repeatCount) {
        case 2:
            rotationAnimation.duration = .6;
            break;
        case 1:
            rotationAnimation.duration = .8;
            break;
        case 0:
            rotationAnimation.duration = 1.0;
            break;
        default:
            break;
    }
    
    rotationAnimation.cumulative = YES;
    rotationAnimation.delegate = self;
    rotationAnimation.repeatCount = self.repeatCount == 0 ? INFINITY : self.repeatCount;;
    [iconImageView_.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}

- (void)iconImageViewStopAnimation {
    [iconImageView_.layer removeAllAnimations];
}

@end
