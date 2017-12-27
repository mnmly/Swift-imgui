//
//  ImGuiWrapperMetal.h
//  Swift-imgui
//
//  Created by Hiroaki Yamane on 1/24/17.
//  Copyright © 2017 Hiroaki Yamane. All rights reserved.
//

#import "ImGuiWrapperBase.h"

#if !(TARGET_IPHONE_SIMULATOR)
#include <MetalKit/MetalKit.h>

@interface ImGuiWrapperMetal : ImGuiWrapperBase

- (instancetype _Nonnull) initWithDevice: (id<MTLDevice> _Nonnull)device;
- (instancetype _Nonnull) initWithDevice: (id<MTLDevice> _Nonnull)device font: (NSString* _Nonnull)fontPath;
- (void) newFrame:(id<CAMetalDrawable> _Nonnull) drawable;
- (void) newFrameWithCommandEncoder:(id<MTLRenderCommandEncoder> _Nonnull)commandEncoder;
- (void) setPixelFormat: (MTLPixelFormat)format;
- (void) setDepthPixelFormat: (MTLPixelFormat)format;

- (void) image: (id<MTLTexture> _Nonnull) userTextureID : (CGSize)size : (CGPoint) uv0 : (CGPoint) uv1 : (CGColorRef _Nonnull) tintColor : (CGColorRef _Nonnull) borderColor;

@end

#endif
