//
//  iAXMaterialProgress.h
//  iAXMaterialProgress
//
//  Created by AmirHossein Aghajari on 10/16/20.
//  Copyright © 2020 Amir Hossein Aghajari. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol MaterialProgressDelegate <NSObject>
- (void) ProgressUpdate : (float) progress;
@end

@interface iAXMaterialProgress : UIView

@property (nullable, nonatomic, weak) id <MaterialProgressDelegate> delegate;

//the determinate progress mode
@property(nonatomic,readwrite) BOOL linearProgress;
//the radius of the wheel in pixels
@property(nonatomic,readwrite) int circleRadius;
//the width of the spinning bar
@property(nonatomic,readwrite) int barWidth;
//the width of the wheel's contour
@property(nonatomic,readwrite) int rimWidth;
//the color of the spinning bar
@property(nonatomic,readwrite) UIColor * _Nonnull barColor;
//the color of the wheel's contour
@property(nonatomic,readwrite) UIColor * _Nonnull rimColor;
//The amount of degrees per second
@property(nonatomic,readwrite) float spinSpeed;

/**
 * Check if the wheel is currently spinning
 */
- (BOOL) isSpinning;

/**
 * Reset the count (in increment mode)
 */
- (void) reset;
/**
 * Turn off spin mode
 */
- (void) stop;

/**
 * Puts the view on spin mode
 */
- (void) start;

/**
 * Set the progress to a specific value,
 * the bar will be set instantly to that value
 *
 * the progress should be between 0 and 1
 */
- (void) setInstantProgress : (float) progress;

/**
 * return the current progress between 0.0 and 1.0,
 * if the wheel is indeterminate, then the result is -1
 */
- (float) getProgress;

/**
 * Set the progress to a specific value,
 * the bar will smoothly animate until that value
 *
 * the progress should be between 0 and 1
 */
- (void) setProgress : (float) progress;

- (void) updateDelegate : (float) value;
@end
