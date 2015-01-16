/*
 File: UIImage+ImageEffects.m
 Abstract: This is a category of UIImage that adds methods to apply blur and tint effects to an image. This is the code you’ll want to look out to find out how to use vImage to efficiently calculate a blur.
 Version: 1.0
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2013 Apple Inc. All Rights Reserved.
 
 
 Copyright © 2013 Apple Inc. All rights reserved.
 WWDC 2013 License
 
 NOTE: This Apple Software was supplied by Apple as part of a WWDC 2013
 Session. Please refer to the applicable WWDC 2013 Session for further
 information.
 
 IMPORTANT: This Apple software is supplied to you by Apple Inc.
 ("Apple") in consideration of your agreement to the following terms, and
 your use, installation, modification or redistribution of this Apple
 software constitutes acceptance of these terms. If you do not agree with
 these terms, please do not use, install, modify or redistribute this
 Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a non-exclusive license, under
 Apple's copyrights in this original Apple software (the "Apple
 Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple. Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis. APPLE MAKES
 NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE
 IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR
 A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 EA1002
 5/3/2013
 */

#import <UIKit/UIKit.h>
#import <CoreImage/CoreImage.h>
#import "UIImage+ImageEffects.h"
#import <objc/runtime.h>

@import Accelerate;
#import <float.h>


static void * alphaValuePropertyKey = &alphaValuePropertyKey;
static void * radiusValuePropertyKey = &radiusValuePropertyKey;

@implementation UIImage (ImageEffects)
//
//@dynamic alphaValue;
//@dynamic radiusValue;

//- (void)setAlphaValue:(CGFloat)alphaValue {
//    self.alphaValue = alphaValue;
//    objc_setAssociatedObject(self, @selector(alphaValue), unicorns, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//}
//
//- (void)setRadiusValue:(CGFloat)radiusValue {
//    self.radiusValue = radiusValue;
//
//}
//
//- (CGFloat)alphaValue {
//    return objc_getAssociatedObject(self, @selector(alphaValue));
//}
//
//- (CGFloat)radiusValue {
//    return self.radiusValue;
//}

- (void)setAlphaObject:(id)newObject {
    objc_setAssociatedObject(self, @selector(alphaObject), newObject, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id)alphaObject {
    return objc_getAssociatedObject(self, @selector(alphaObject));
}

- (void)setRadiusObject:(id)newObject {
    objc_setAssociatedObject(self, @selector(radiusObject), newObject, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id)radiusObject {
    return objc_getAssociatedObject(self, @selector(radiusObject));
}

- (UIImage *)crop:(CGRect)rect {
    
    rect = CGRectMake(rect.origin.x*self.scale,
                      rect.origin.y*self.scale,
                      rect.size.width*self.scale,
                      rect.size.height*self.scale);
    
    CGImageRef imageRef = CGImageCreateWithImageInRect([self CGImage], rect);
    UIImage *result = [UIImage imageWithCGImage:imageRef
                                          scale:self.scale
                                    orientation:self.imageOrientation];
    CGImageRelease(imageRef);
    return result;
}


- (UIColor *)averageColor {
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char rgba[4];
    CGContextRef context = CGBitmapContextCreate(rgba, 1, 1, 8, 4, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    
    CGContextDrawImage(context, CGRectMake(0, 0, 1, 1), self.CGImage);
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    
    if(rgba[3] > 0) {
        CGFloat alpha = ((CGFloat)rgba[3])/255.0;
        CGFloat multiplier = alpha/255.0;
        return [UIColor colorWithRed:((CGFloat)rgba[0])*multiplier
                               green:((CGFloat)rgba[1])*multiplier
                                blue:((CGFloat)rgba[2])*multiplier
                               alpha:alpha];
    }
    else {
        return [UIColor colorWithRed:((CGFloat)rgba[0])/255.0
                               green:((CGFloat)rgba[1])/255.0
                                blue:((CGFloat)rgba[2])/255.0
                               alpha:((CGFloat)rgba[3])/255.0];
    }
}

- (UIImage*) blur
{
    // ***********If you need re-orienting (e.g. trying to blur a photo taken from the device camera front facing camera in portrait mode)
    // theImage = [self reOrientIfNeeded:theImage];
    
    // EAGL conext for real-time performance
    //EAGLContext *myEAGLContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    //NSDictionary *options = @{ kCIContextWorkingColorSpace : [NSNull null] };
    //CIContext *myContext = [CIContext contextWithEAGLContext:myEAGLContext options:options];
    
    
    // create our blurred image
    CIContext *context = [CIContext contextWithOptions:nil];
    CIImage *inputImage = [CIImage imageWithCGImage:self.CGImage];
    
    // setting up Gaussian Blur (we could use one of many filters offered by Core Image)
    CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur"];
    [filter setValue:inputImage forKey:kCIInputImageKey];
    [filter setValue:[NSNumber numberWithFloat:5.0f] forKey:@"inputRadius"];
    CIImage *result = [filter valueForKey:kCIOutputImageKey];
    
    // test
    
    CIFilter *filter1 = [CIFilter filterWithName:@"CIPhotoEffectNoir"];
    [filter1 setDefaults];
    
    [filter1 setValue:result forKey:@"inputImage"];
    //result = [filter1 valueForKey:@"outputImage"];
    
    //
    
    // CIGaussianBlur has a tendency to shrink the image a little,
    // this ensures it matches up exactly to the bounds of our original image
    CGImageRef cgImage = [context createCGImage:result fromRect:[inputImage extent]];
    
    UIImage *returnImage = [UIImage imageWithCGImage:cgImage];//create a UIImage for this function to "return" so that ARC can manage the memory of the blur... ARC can't manage CGImageRefs so we need to release it before this function "returns" and ends.
    CGImageRelease(cgImage);//release CGImageRef because ARC doesn't manage this on its own.
    
    // clear memory
    filter = nil;
    filter1 = nil;
    inputImage = nil;
    context = nil;
    
    return returnImage;
    
    // *************** if you need scaling
    // return [[self class] scaleIfNeeded:cgImage];
}


- (UIImage *)applyGaussianGradientBlur{
    
    EAGLContext *myEAGLContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    NSDictionary *options = @{ kCIContextWorkingColorSpace : [NSNull null] };
    CIContext *myContext = [CIContext contextWithEAGLContext:myEAGLContext options:options];
    
    CIImage *inputImage = [CIImage imageWithCGImage:self.CGImage];
    
    // setting up Gaussian Blur (we could use one of many filters offered by Core Image)
    CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur"];
    [filter setValue:inputImage forKey:kCIInputImageKey];
    [filter setValue:[NSNumber numberWithFloat:5.0f] forKey:@"inputRadius"];
    CIImage *resultBlur = [filter valueForKey:kCIOutputImageKey];
    
    filter = [CIFilter filterWithName:@"CIGaussianGradient"];
    [filter setValue:[CIVector vectorWithX:self.size.width/2 Y:self.size.height/2] forKey:@"inputCenter"];
    [filter setValue:[CIColor colorWithRed:0.0 green:1.0 blue:0.0 alpha:1.0] forKey:@"inputColor0"];
    [filter setValue:[CIColor colorWithRed:0.0 green:1.0 blue:0.0 alpha:0.0] forKey:@"inputColor1"];
    [filter setValue:[NSNumber numberWithFloat:self.size.width/3] forKey:@"inputRadius"];
    CIImage *resultGradient0 = [filter valueForKey:kCIOutputImageKey];
    
    filter = [CIFilter filterWithName:@"CILinearGradient"];
    [filter setValue:[CIVector vectorWithX:0 Y:0.75 * self.size.height] forKey:@"inputPoint0"];
    [filter setValue:[CIColor colorWithRed:0.0 green:1.0 blue:0.0 alpha:1.0] forKey:@"inputColor0"];
    [filter setValue:[CIVector vectorWithX:0 Y:0.5 * self.size.height] forKey:@"inputPoint1"];
    [filter setValue:[CIColor colorWithRed:0.0 green:1.0 blue:0.0 alpha:0.0] forKey:@"inputColor1"];
    CIImage *resultGradient1 = [filter valueForKey:kCIOutputImageKey];
    
    //CIFilter *filter2 = [CIFilter filterWithName:@"CILinearGradient"];
    [filter setValue:[CIVector vectorWithX:0 Y:0.25 * self.size.height] forKey:@"inputPoint0"];
    [filter setValue:[CIColor colorWithRed:0.0 green:1.0 blue:0.0 alpha:1.0] forKey:@"inputColor0"];
    [filter setValue:[CIVector vectorWithX:0 Y:0.5 * self.size.height] forKey:@"inputPoint1"];
    [filter setValue:[CIColor colorWithRed:0.0 green:1.0 blue:0.0 alpha:0.0] forKey:@"inputColor1"];
    CIImage *resultGradient2 = [filter valueForKey:kCIOutputImageKey];
    
    //CIFilter *filter3 = [CIFilter filterWithName:@"CIAdditionCompositing"];
    filter = [CIFilter filterWithName:@"CIAdditionCompositing"];
    [filter setValue:resultGradient1 forKey:kCIInputImageKey];
    [filter setValue:resultGradient2 forKey:@"inputBackgroundImage"];
    
    //CIFilter *filter4 = [CIFilter filterWithName:@"CIBlendWithMask"];
    filter = [CIFilter filterWithName:@"CIBlendWithMask"];
    [filter setValue:inputImage forKey:kCIInputImageKey];
    [filter setValue:resultBlur forKey:@"inputBackgroundImage"];
    [filter setValue:resultGradient0 forKey:@"inputMaskImage"];
    CIImage *resultTiltShift = [filter valueForKey:kCIOutputImageKey];
    
    // clear memory
    filter = nil;
    resultBlur = nil;
    resultGradient0 = nil;
    resultGradient1 = nil;
    resultGradient2 = nil;
    inputImage = nil;
    
    
    return [UIImage imageWithCGImage:[myContext createCGImage:resultTiltShift fromRect:CGRectMake(0, 0, self.size.width, self.size.height)]];
    
}

- (UIImage *)applyClamp
{
    CIImage *rawImageData;
    rawImageData =[[CIImage alloc] initWithImage:self];
    
    //    CIFilter *filter = [CIFilter filterWithName:@"CIPhotoEffectNoir"];
    //    [filter setDefaults];
    //
    //    [filter setValue:rawImageData forKey:@"inputImage"];
    //    CIImage *filteredImageData = [filter valueForKey:@"outputImage"];
    
    CIFilter *filter = [CIFilter filterWithName:@"CIColorClamp"];
    //[filter setDefaults];
    
    
    [filter setValue:rawImageData forKey:@"inputImage"];
    
    [filter setValue:[CIVector vectorWithCGRect:CGRectMake(0.1, 0.1, 0.1, 0)] forKey:@"inputMinComponents"];
    [filter setValue:[CIVector vectorWithCGRect:CGRectMake(0.86, 0.86, 0.86, 1)] forKey:@"inputMaxComponents"];
    CIImage *filteredImageData = [filter valueForKey:@"outputImage"];
    
    // clear memory
    filter = nil;
    rawImageData = nil;
    
    return [UIImage imageWithCGImage:[[CIContext contextWithOptions:nil] createCGImage:filteredImageData fromRect:CGRectMake(0, 0, self.size.width, self.size.height)]];
    
}

- (UIImage *)applyNoir
{
    CIImage *rawImageData;
    rawImageData =[[CIImage alloc] initWithImage:self];
    
    CIFilter *filter = [CIFilter filterWithName:@"CIPhotoEffectNoir"];
    //    [filter setDefaults];
    [filter setValue:rawImageData forKey:@"inputImage"];
    CIImage *filteredImageData = [filter valueForKey:@"outputImage"];
    
    // clear memory
    filter = nil;
    rawImageData = nil;
    
    return [UIImage imageWithCGImage:[[CIContext contextWithOptions:nil] createCGImage:filteredImageData fromRect:CGRectMake(0, 0, self.size.width, self.size.height)]];
    
}

- (UIImage *)applySepiaTone
{
    CIImage *rawImageData;
    rawImageData =[[CIImage alloc] initWithImage:self];
    
    CIFilter *filter = [CIFilter filterWithName:@"CISepiaTone"];
    //[filter setDefaults];
    [filter setValue:[NSNumber numberWithFloat:0.70]
              forKey:@"inputIntensity"];
    
    [filter setValue:rawImageData forKey:@"inputImage"];
    CIImage *filteredImageData = [filter valueForKey:@"outputImage"];
    
    CGImageRef result = [[CIContext contextWithOptions:nil] createCGImage:filteredImageData fromRect:CGRectMake(0, 0, self.size.width, self.size.height)];
    
    // clear memory
    filter = nil;
    rawImageData = nil;
    
    return [UIImage imageWithCGImage:result];
}

- (UIImage *)applyBlur {
    
    return [self blur];
    
    //return [self applyLightEffect];
}

- (UIImage *)applyChrome {
    CIImage *rawImageData;
    rawImageData =[[CIImage alloc] initWithImage:self];
    
    CIFilter *filter = [CIFilter filterWithName:@"CIPhotoEffectChrome"];
    //CIFilter *filter = [CIFilter filterWithName:@"CIPhotoEffectInstant"];
    //[filter setDefaults];
    
    [filter setValue:rawImageData forKey:@"inputImage"];
    CIImage *filteredImageData = [filter valueForKey:@"outputImage"];
    
    // clear memory
    filter = nil;
    rawImageData = nil;
    
    //UIImage *filteredImage = [UIImage imageWithCIImage:filteredImageData];
    return [UIImage imageWithCGImage:[[CIContext contextWithOptions:nil] createCGImage:filteredImageData fromRect:CGRectMake(0, 0, self.size.width, self.size.height)]];
}

- (UIImage *)applyInstant {
    CIImage *rawImageData;
    rawImageData =[[CIImage alloc] initWithImage:self];
    
    CIFilter *filter = [CIFilter filterWithName:@"CIPhotoEffectInstant"];
    //[filter setDefaults];
    
    [filter setValue:rawImageData forKey:@"inputImage"];
    CIImage *filteredImageData = [filter valueForKey:@"outputImage"];
    
    // clear memory
    filter = nil;
    rawImageData = nil;
    
    //UIImage *filteredImage = [UIImage imageWithCIImage:filteredImageData];
    return [UIImage imageWithCGImage:[[CIContext contextWithOptions:nil] createCGImage:filteredImageData fromRect:CGRectMake(0, 0, self.size.width, self.size.height)]];
}

- (UIImage *)applyCIExposure {
    CIImage *rawImageData;
    rawImageData =[[CIImage alloc] initWithImage:self];
    
    CIFilter *filter = [CIFilter filterWithName:@"CIExposureAdjust"];
    //[filter setDefaults];
    
    [filter setValue:rawImageData forKey:@"inputImage"];
    [filter setValue:[NSNumber numberWithFloat:0.5f] forKey:@"inputEV"];
    
    CIImage *filteredImageData = [filter valueForKey:@"outputImage"];
    
    CGImageRef result = [[CIContext contextWithOptions:nil] createCGImage:filteredImageData fromRect:CGRectMake(0, 0, self.size.width, self.size.height)];
    
    // clear memory
    filter = nil;
    rawImageData = nil;
    
    return [UIImage imageWithCGImage:result];
}

- (UIImage *)applyLinearGradient:(UIColor *)color {
    
    const CGFloat *_components = CGColorGetComponents(color.CGColor);
    CGFloat red     = _components[0];
    CGFloat green = _components[1];
    CGFloat blue   = _components[2];
    //CGFloat alpha = _components[3];
    
    //CIImage *inputImage = [CIImage imageWithCGImage:self.CGImage];
    EAGLContext *myEAGLContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    NSDictionary *options = @{ kCIContextWorkingColorSpace : [NSNull null] };
    CIContext *myContext = [CIContext contextWithEAGLContext:myEAGLContext options:options];
    //CIContext *context = [CIContext contextWithOptions:nil];
    
    CIFilter *filter = [CIFilter filterWithName:@"CILinearGradient"];
    [filter setValue:[CIVector vectorWithX:0 Y:0.5 * self.size.height] forKey:@"inputPoint0"];
    [filter setValue:[CIColor colorWithCGColor:color.CGColor] forKey:@"inputColor0"];
    [filter setValue:[CIVector vectorWithX:0 Y:0 * self.size.height] forKey:@"inputPoint1"];
    [filter setValue:[CIColor colorWithRed:red green:green blue:blue alpha:0.5] forKey:@"inputColor1"];
    CIImage *resultGradient1 = [filter valueForKey:kCIOutputImageKey];
    
    UIGraphicsBeginImageContext(self.size);
    [self drawInRect:CGRectMake(0, 0, self.size.width, self.size.height)];
    [[UIImage imageWithCGImage:[myContext createCGImage:resultGradient1 fromRect:CGRectMake(0, 0, self.size.width, self.size.height)]] drawInRect:CGRectMake(0, 0, self.size.width, self.size.height)];
    
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // clear memory
    filter = nil;
    myContext = nil;
    myEAGLContext = nil;
    options = nil;
    myContext = nil;
    
    return result;
    
    //    CIFilter *filter = [CIFilter filterWithName:@"CIVignetteEffect"];
    //    [filter setValue:inputImage forKey:kCIInputImageKey];
    //    [filter setValue:[CIVector vectorWithX:150 Y:150] forKey:@"inputCenter"];
    //    [filter setValue:[NSNumber numberWithFloat:0.4f]forKey:@"inputIntensity"];
    //    [filter setValue:[NSNumber numberWithFloat:0.2f] forKey:@"inputRadius"];
    //    CIImage *filteredImageData = [filter valueForKey:kCIOutputImageKey];
    //
    //    return [UIImage imageWithCGImage:[[CIContext contextWithOptions:nil] createCGImage:filteredImageData fromRect:CGRectMake(0, 0, self.size.width, self.size.height)]];
}

- (UIImage *)applyLightEffect
{
    UIColor *tintColor = [UIColor colorWithWhite:1.0 alpha:0.3];
    return [self applyBlurWithRadius:30 tintColor:tintColor saturationDeltaFactor:1.8 maskImage:nil];
}


- (UIImage *)applyExtraLightEffect
{
    UIColor *tintColor = [UIColor colorWithWhite:0.97 alpha:0.82];
    return [self applyBlurWithRadius:20 tintColor:tintColor saturationDeltaFactor:1.8 maskImage:nil];
}


- (UIImage *)applyDarkEffect
{
    UIColor *tintColor = [UIColor colorWithWhite:0.11 alpha:0.8];
    return [self applyBlurWithRadius:20 tintColor:tintColor saturationDeltaFactor:1.8 maskImage:nil];
}

- (UIImage *)applyLittleDarkEffect
{
    UIColor *tintColor = [UIColor colorWithWhite:0.5 alpha:0.73];
    return [self applyBlurWithRadius:20 tintColor:tintColor saturationDeltaFactor:1.8 maskImage:nil];
}


- (UIImage *)applyTintEffectWithColor:(UIColor *)tintColor
{
    const CGFloat EffectColorAlpha = 0.6;
    UIColor *effectColor = tintColor;
    int componentCount = CGColorGetNumberOfComponents(tintColor.CGColor);
    if (componentCount == 2) {
        CGFloat b;
        if ([tintColor getWhite:&b alpha:NULL]) {
            effectColor = [UIColor colorWithWhite:b alpha:EffectColorAlpha];
        }
    }
    else {
        CGFloat r, g, b;
        if ([tintColor getRed:&r green:&g blue:&b alpha:NULL]) {
            effectColor = [UIColor colorWithRed:r green:g blue:b alpha:EffectColorAlpha];
        }
    }
    return [self applyBlurWithRadius:10 tintColor:effectColor saturationDeltaFactor:-1.0 maskImage:nil];
}


- (UIImage *)applyBlurWithRadius:(CGFloat)blurRadius tintColor:(UIColor *)tintColor saturationDeltaFactor:(CGFloat)saturationDeltaFactor maskImage:(UIImage *)maskImage
{
    // Check pre-conditions.
//    if (self.size.width < 1 || self.size.height < 1) {
//        NSLog (@"*** error: invalid size: (%.2f x %.2f). Both dimensions must be >= 1: %@", self.size.width, self.size.height, self);
//        return nil;
//    }
//    if (!self.CGImage) {
//        NSLog (@"*** error: image must be backed by a CGImage: %@", self);
//        return nil;
//    }
//    if (maskImage && !maskImage.CGImage) {
//        NSLog (@"*** error: maskImage must be backed by a CGImage: %@", maskImage);
//        return nil;
//    }
    
    CGRect imageRect = { CGPointZero, self.size };
    UIImage *effectImage = self;
    
    BOOL hasBlur = blurRadius > __FLT_EPSILON__;
    BOOL hasSaturationChange = fabs(saturationDeltaFactor - 1.) > __FLT_EPSILON__;
    if (hasBlur || hasSaturationChange) {
        UIGraphicsBeginImageContextWithOptions(self.size, NO, [[UIScreen mainScreen] scale]);
        CGContextRef effectInContext = UIGraphicsGetCurrentContext();
        CGContextScaleCTM(effectInContext, 1.0, -1.0);
        CGContextTranslateCTM(effectInContext, 0, -self.size.height);
        CGContextDrawImage(effectInContext, imageRect, self.CGImage);
        
        vImage_Buffer effectInBuffer;
        effectInBuffer.data     = CGBitmapContextGetData(effectInContext);
        effectInBuffer.width    = CGBitmapContextGetWidth(effectInContext);
        effectInBuffer.height   = CGBitmapContextGetHeight(effectInContext);
        effectInBuffer.rowBytes = CGBitmapContextGetBytesPerRow(effectInContext);
        
        UIGraphicsBeginImageContextWithOptions(self.size, NO, [[UIScreen mainScreen] scale]);
        CGContextRef effectOutContext = UIGraphicsGetCurrentContext();
        vImage_Buffer effectOutBuffer;
        effectOutBuffer.data     = CGBitmapContextGetData(effectOutContext);
        effectOutBuffer.width    = CGBitmapContextGetWidth(effectOutContext);
        effectOutBuffer.height   = CGBitmapContextGetHeight(effectOutContext);
        effectOutBuffer.rowBytes = CGBitmapContextGetBytesPerRow(effectOutContext);
        
        if (hasBlur) {
            // A description of how to compute the box kernel width from the Gaussian
            // radius (aka standard deviation) appears in the SVG spec:
            // http://www.w3.org/TR/SVG/filters.html#feGaussianBlurElement
            //
            // For larger values of 's' (s >= 2.0), an approximation can be used: Three
            // successive box-blurs build a piece-wise quadratic convolution kernel, which
            // approximates the Gaussian kernel to within roughly 3%.
            //
            // let d = floor(s * 3*sqrt(2*pi)/4 + 0.5)
            //
            // ... if d is odd, use three box-blurs of size 'd', centered on the output pixel.
            //
            CGFloat inputRadius = blurRadius * [[UIScreen mainScreen] scale];
            NSUInteger radius = floor(inputRadius * 3. * sqrt(2 * M_PI) / 4 + 0.5);
            if (radius % 2 != 1) {
                radius += 1; // force radius to be odd so that the three box-blur methodology works.
            }
            vImageBoxConvolve_ARGB8888(&effectInBuffer, &effectOutBuffer, NULL, 0, 0, radius, radius, 0, kvImageEdgeExtend);
            vImageBoxConvolve_ARGB8888(&effectOutBuffer, &effectInBuffer, NULL, 0, 0, radius, radius, 0, kvImageEdgeExtend);
            vImageBoxConvolve_ARGB8888(&effectInBuffer, &effectOutBuffer, NULL, 0, 0, radius, radius, 0, kvImageEdgeExtend);
        }
        BOOL effectImageBuffersAreSwapped = NO;
        if (hasSaturationChange) {
            CGFloat s = saturationDeltaFactor;
            CGFloat floatingPointSaturationMatrix[] = {
                0.0722 + 0.9278 * s,  0.0722 - 0.0722 * s,  0.0722 - 0.0722 * s,  0,
                0.7152 - 0.7152 * s,  0.7152 + 0.2848 * s,  0.7152 - 0.7152 * s,  0,
                0.2126 - 0.2126 * s,  0.2126 - 0.2126 * s,  0.2126 + 0.7873 * s,  0,
                0,                    0,                    0,  1,
            };
            const int32_t divisor = 256;
            NSUInteger matrixSize = sizeof(floatingPointSaturationMatrix)/sizeof(floatingPointSaturationMatrix[0]);
            int16_t saturationMatrix[matrixSize];
            for (NSUInteger i = 0; i < matrixSize; ++i) {
                saturationMatrix[i] = (int16_t)roundf(floatingPointSaturationMatrix[i] * divisor);
            }
            if (hasBlur) {
                vImageMatrixMultiply_ARGB8888(&effectOutBuffer, &effectInBuffer, saturationMatrix, divisor, NULL, NULL, kvImageNoFlags);
                effectImageBuffersAreSwapped = YES;
            }
            else {
                vImageMatrixMultiply_ARGB8888(&effectInBuffer, &effectOutBuffer, saturationMatrix, divisor, NULL, NULL, kvImageNoFlags);
            }
        }
        if (!effectImageBuffersAreSwapped)
            effectImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        if (effectImageBuffersAreSwapped)
            effectImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    
    // Set up output context.
    UIGraphicsBeginImageContextWithOptions(self.size, NO, [[UIScreen mainScreen] scale]);
    CGContextRef outputContext = UIGraphicsGetCurrentContext();
    CGContextScaleCTM(outputContext, 1.0, -1.0);
    CGContextTranslateCTM(outputContext, 0, -self.size.height);
    
    // Draw base image.
    CGContextDrawImage(outputContext, imageRect, self.CGImage);
    
    // Draw effect image.
    if (hasBlur) {
        CGContextSaveGState(outputContext);
        if (maskImage) {
            CGContextClipToMask(outputContext, imageRect, maskImage.CGImage);
        }
        CGContextDrawImage(outputContext, imageRect, effectImage.CGImage);
        CGContextRestoreGState(outputContext);
    }
    
    // Add in color tint.
    if (tintColor) {
        CGContextSaveGState(outputContext);
        CGContextSetFillColorWithColor(outputContext, tintColor.CGColor);
        CGContextFillRect(outputContext, imageRect);
        CGContextRestoreGState(outputContext);
    }
    
    // Output image is ready.
    UIImage *outputImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return outputImage;
}


@end
