//
//  iAXMaterialProgress.m
//  iAXMaterialProgress
//
//  Created by AmirHossein Aghajari on 10/16/20.
//  Copyright © 2020 Amir Hossein Aghajari. All rights reserved.
//

#import "iAXMaterialProgress.h"
#define RADIANS(degrees)((M_PI * degrees)/180)


@interface iAXMaterialProgressLayer : CALayer {
    BOOL linearProgress;
    int circleRadius;
    int barWidth;
    CGRect circleBounds;
    UIColor *barColor;
    float spinSpeed;
    int rimWidth;
    UIColor *rimColor;
}

@property(nonatomic) CGRect circleBounds;
@property(nonatomic) BOOL linearProgress;
@property(nonatomic) int circleRadius;
@property(nonatomic) int barWidth;
@property(nonatomic) UIColor *barColor;
@property(nonatomic) int rimWidth;
@property(nonatomic) UIColor *rimColor;
@property(nonatomic) float spinSpeed;
@end

@implementation iAXMaterialProgressLayer {
    int barLength;
    int barMaxLength;
    long long pauseGrowingTime;
    
    BOOL fillRadius;
    double timeStartGrowing;
    double barSpinCycleTime;
    float barExtraLength;
    BOOL barGrowingFromFront;
    long long pausedTimeWithoutGrowing;
    long long lastTimeAnimated;
    float mProgress;
    float mTargetProgress;
    BOOL isSpinning;
    BOOL shouldAnimate;
    BOOL needsUpdate;
    UIBezierPath *barPath;
    UIBezierPath *rimPath;
    iAXMaterialProgress *view;
}

@synthesize circleBounds;
@synthesize linearProgress;
@synthesize circleRadius;
@synthesize barWidth;
@synthesize barColor;
@synthesize spinSpeed;
@synthesize rimWidth;
@synthesize rimColor;

- (id) init {
    if (self = [super init]){
        self->barLength = 16;
        self->barMaxLength = 270;
        self->pauseGrowingTime = 200;
        
        self->circleRadius = 28;
        self->barWidth = 4;
        self->fillRadius = NO;
        self->timeStartGrowing = 0;
        self->barSpinCycleTime = 460;
        self->barExtraLength = 0;
        self->barGrowingFromFront = YES;
        self->pausedTimeWithoutGrowing = 0;
        self->barColor = [UIColor darkGrayColor];
        self->circleBounds = CGRectZero;
        self->rimColor = [UIColor clearColor];
        self->rimWidth = 4;
        
        self->spinSpeed = 230.0f;
        // The last time the spinner was animated
        self->lastTimeAnimated = 0;
        self->linearProgress = YES;
        self->mProgress = 0.0f;
        self->mTargetProgress = 0.0f;
        self->isSpinning = NO;
        self->shouldAnimate = YES;
        self->needsUpdate = YES;
    }
    return self;
}

+ (BOOL)needsDisplayForKey:(NSString *)key {
    return ([key isEqualToString:@"progress"] || [super needsDisplayForKey:key]);
}

- (id <CAAction>)actionForKey:(NSString *)key {
    CABasicAnimation *progressAnimation = [CABasicAnimation animation];
    progressAnimation.fromValue = [self.presentationLayer valueForKey:key];
    progressAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    progressAnimation.duration = 3.0;
    progressAnimation.repeatCount = HUGE_VALF;
    return progressAnimation;
}

/**
 * Set the bounds of the component
 */
- (void) setupBounds : (CGFloat) w : (CGFloat) h {
    if (!fillRadius) {
        // Width should equal to Height, find the min value to setup the circle
        CGFloat minValue = MIN(w,h);
        CGFloat circleDiameter = MIN(minValue, circleRadius * 2 - barWidth * 2);
        
        // Calc the Offset if needed for centering the wheel in the available space
        CGFloat xOffset = (w - circleDiameter) / 2;
        CGFloat yOffset = (h - circleDiameter) / 2;
        
        circleBounds = CGRectMake(xOffset+barWidth, yOffset+barWidth, xOffset + circleDiameter - barWidth,
                                  yOffset + circleDiameter - barWidth);
    } else {
        circleBounds = CGRectMake(barWidth, barWidth, w - barWidth, h - barWidth);
    }
}

- (void)drawInContext:(CGContextRef)ctx {
    [super drawInContext:ctx];
    UIGraphicsPushContext(ctx);
    CGRect rect = self.bounds;
    
    //CGPoint center = CGPointMake(circleBounds.origin.x+(circleBounds.size.width/2), circleBounds.origin.y+(circleBounds.size.height/2));
    CGPoint center = CGPointMake(rect.size.width/2, rect.size.height/2);
    CGFloat radius = circleBounds.size.width/2;
    
    rimPath = nil;
    rimPath = [UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:RADIANS(0) endAngle:RADIANS(360) clockwise:YES];
    rimPath.lineWidth = rimWidth;
    [rimColor setStroke];
    [rimPath stroke];
    
    BOOL mustInvalidate = NO;
    if (!shouldAnimate) {
        return;
    }
    if (isSpinning) {
        //Draw the spinning bar
        mustInvalidate = YES;
        
        long long time = ([[NSDate date] timeIntervalSince1970] * 1000);
        long long deltaTime =  (time - lastTimeAnimated);
        float deltaNormalized = deltaTime * spinSpeed / 1000;
        
        [self updateBarLength:deltaTime];
        
        mProgress += deltaNormalized;
        if (mProgress > 360) {
            mProgress -= 360 ;
            
            [view updateDelegate:-1.0f];
        }
        
        lastTimeAnimated = time;
        
        float from = mProgress - 90;
        float length = barLength + barExtraLength + from;
        
        barPath = nil;
        barPath = [UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:RADIANS(from) endAngle:RADIANS(length) clockwise:YES];
        barPath.lineWidth = barWidth;
        [barColor setStroke];
        [barPath stroke];
    } else {
        
        float oldProgress = mProgress;
        
        if (mProgress != mTargetProgress) {
            //We smoothly increase the progress bar
            mustInvalidate = YES;
            
            long long time = [[NSDate date] timeIntervalSince1970] * 1000;
            float deltaTime = (float) (time - lastTimeAnimated) / 1000;
            float deltaNormalized = deltaTime * spinSpeed;
            
            mProgress = MIN(mProgress + deltaNormalized, mTargetProgress);
            lastTimeAnimated = [[NSDate date] timeIntervalSince1970] * 1000;
        }
        
        if (oldProgress != mProgress) {
            float normalizedProgress = roundf(mProgress * 100 / 360.0f) / 100;
            [view updateDelegate:normalizedProgress];
        }
        
        float offset = 0.0f;
        float progress = mProgress;
        if (!linearProgress) {
            float factor = 2.0f;
            offset = (float) (1.0f - pow(1.0f - mProgress / 360.0f, 2.0f * factor)) * 360.0f;
            progress = (float) (1.0f - pow(1.0f - mProgress / 360.0f, factor)) * 360.0f;
        }
        
        float from = offset - 90;
        float end = progress + offset;
        UIBezierPath *barPath = [UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:RADIANS(from) endAngle:RADIANS(end) clockwise:YES];
        barPath.lineWidth = barWidth;
        [barColor setStroke];
        [barPath stroke];
    }
    
    UIGraphicsPopContext();
    
    needsUpdate = mustInvalidate;
    if (needsUpdate) {
        [[NSRunLoop currentRunLoop] performSelector:@selector(setNeedsDisplay) target:self argument:nil order:0 modes:@[NSRunLoopCommonModes]];
    }
    
}

- (void) updateBarLength : (long long) deltaTimeInMilliSeconds {
    if (pausedTimeWithoutGrowing >= pauseGrowingTime) {
        timeStartGrowing += deltaTimeInMilliSeconds;
        
        if (timeStartGrowing > barSpinCycleTime) {
            // We completed a size change cycle
            // (growing or shrinking)
            timeStartGrowing -= barSpinCycleTime;
            //if(barGrowingFromFront) {
            pausedTimeWithoutGrowing = 0;
            //}
            barGrowingFromFront = !barGrowingFromFront;
        }
        
        float distance = (float) cos((timeStartGrowing / barSpinCycleTime + 1) * M_PI) / 2 + 0.5f;
        float destLength = (barMaxLength - barLength);
        
        if (barGrowingFromFront) {
            barExtraLength = distance * destLength;
        } else {
            float newLength = destLength * (1 - distance);
            mProgress += (barExtraLength - newLength);
            barExtraLength = newLength;
        }
    } else {
        pausedTimeWithoutGrowing += deltaTimeInMilliSeconds;
    }
}

- (BOOL) isSpinning {
    return isSpinning;
}

- (void) reset {
    mProgress = 0.0f;
    mTargetProgress = 0.0f;
}

- (void) stop {
    isSpinning = false;
    mProgress = 0.0f;
    mTargetProgress = 0.0f;
}

- (void) start {
    lastTimeAnimated = [[NSDate date] timeIntervalSince1970] * 1000;
    isSpinning = true;
}

- (void) setHidden:(BOOL)hidden {
    if (!hidden){
        lastTimeAnimated = [[NSDate date] timeIntervalSince1970] * 1000;
    }
}

- (void) setInstantProgress : (float) progress {
    if (isSpinning) {
        mProgress = 0.0f;
        isSpinning = NO;
    }
    
    if (progress > 1.0f) {
        progress -= 1.0f;
    } else if (progress < 0) {
        progress = 0;
    }
    
    if (progress == mTargetProgress) {
        return;
    }
    
    mTargetProgress = MIN(progress * 360.0f, 360.0f);
    mProgress = mTargetProgress;
    lastTimeAnimated = [[NSDate date] timeIntervalSince1970] * 1000;
}

- (float) getProgress {
    return isSpinning ? -1 : mProgress / 360.0f;
}

- (void) setProgress : (float) progress {
    if (isSpinning) {
        mProgress = 0.0f;
        isSpinning = false;
        
        float normalizedProgress = roundf(mProgress * 100 / 360.0f) / 100;
        [view updateDelegate:normalizedProgress];
    }
    
    if (progress > 1.0f) {
        progress -= 1.0f;
    } else if (progress < 0) {
        progress = 0;
    }
    
    if (progress == mTargetProgress) {
        return;
    }
    
    if (mProgress == mTargetProgress) {
        lastTimeAnimated = [[NSDate date] timeIntervalSince1970] * 1000;
    }
    
    mTargetProgress = MIN(progress * 360.0f, 360.0f);
}

- (void) setUIView : (iAXMaterialProgress*) view {
    self->view = view;
}

@end

@implementation iAXMaterialProgress

- (id) init {
    if (self = [super init]){
        self.isAccessibilityElement = YES;
        self.layer.contentsScale = [UIScreen mainScreen].scale;
        [self.layer setNeedsDisplay];
        [((iAXMaterialProgressLayer*)self.layer) setUIView:self];
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void) updateDelegate : (float) value {
    if (self.delegate!=nil) {
        [self.delegate ProgressUpdate:value];
    }
}

- (void) setBarColor:(UIColor *)barColor {
    ((iAXMaterialProgressLayer*)self.layer).barColor = barColor;
}

- (UIColor*) getBarColor {
    return ((iAXMaterialProgressLayer*)self.layer).barColor;
}

- (void) setBarWidth:(int)barWidth {
    ((iAXMaterialProgressLayer*)self.layer).barWidth = barWidth;
}

- (int) getBarWidth {
    return ((iAXMaterialProgressLayer*)self.layer).barWidth;
}

- (void) setRimColor:(UIColor *)rimColor {
    ((iAXMaterialProgressLayer*)self.layer).rimColor = rimColor;
}

- (UIColor*) getRimColor {
    return ((iAXMaterialProgressLayer*)self.layer).rimColor;
}

- (void) setRimWidth:(int)rimWidth {
    ((iAXMaterialProgressLayer*)self.layer).rimWidth = rimWidth;
}

- (int) getRimWidth {
    return ((iAXMaterialProgressLayer*)self.layer).rimWidth;
}

- (void) setSpinSpeed:(float)spinSpeed {
    ((iAXMaterialProgressLayer*)self.layer).spinSpeed = spinSpeed;
}

- (float) getSpinSpeed {
    return ((iAXMaterialProgressLayer*)self.layer).spinSpeed;
}

- (void) setLinearProgress:(BOOL)linearProgress{
    ((iAXMaterialProgressLayer*)self.layer).linearProgress = linearProgress;
}

- (BOOL) getLinearProgress {
    return ((iAXMaterialProgressLayer*)self.layer).linearProgress;
}

- (void) setHidden:(BOOL)hidden {
    [super setHidden:hidden];
    [self.layer setHidden:hidden];
}

- (CGSize) sizeThatFits:(CGSize)size {
    return CGSizeMake([self getCircleRadius],[self getCircleRadius]);
}

- (void) sizeToFit {
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, [self getCircleRadius], [self getCircleRadius]);
}

- (int) getCircleRadius {
    return ((iAXMaterialProgressLayer*)self.layer).circleRadius;
}

- (void) setCircleRadius : (int) circleRadius {
    ((iAXMaterialProgressLayer*)self.layer).circleRadius = circleRadius;
}

- (void) setFrame:(CGRect)frame {
    [super setFrame:frame];
    [(iAXMaterialProgressLayer*)self.layer setupBounds:frame.size.width:frame.size.height];
}

- (BOOL) isSpinning {
    return [(iAXMaterialProgressLayer*)self.layer isSpinning];
}

- (void) reset {
    [(iAXMaterialProgressLayer*)self.layer reset];
    [self setNeedsDisplay];
}

- (void) stop {
    [(iAXMaterialProgressLayer*)self.layer stop];
    [self setNeedsDisplay];
}

- (void) start {
    [(iAXMaterialProgressLayer*)self.layer start];
    [self setNeedsDisplay];
}

- (void) setInstantProgress : (float) progress {
    [(iAXMaterialProgressLayer*)self.layer setInstantProgress:progress];
    [self setNeedsDisplay];
}

- (float) getProgress {
    return [(iAXMaterialProgressLayer*)self.layer getProgress];
}

- (void) setProgress : (float) progress {
    [(iAXMaterialProgressLayer*)self.layer setProgress:progress];
    [self setNeedsDisplay];
}

+ (Class)layerClass {
    return [iAXMaterialProgressLayer class];
}
@end

