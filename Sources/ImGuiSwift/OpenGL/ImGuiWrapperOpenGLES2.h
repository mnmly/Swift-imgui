//
//  ImGuiWrapperOpenGLES2.h
//  Swift-imgui
//
//  Created by Hiroaki Yamane on 1/24/17.
//  Copyright © 2017 Hiroaki Yamane. All rights reserved.
//

#import "ImGuiWrapperBase.h"
#include <MetalKit/MetalKit.h>

#if TARGET_OS_IPHONE
#define ViewAlias UIView
#else
#define ViewAlias NSView
#endif

@interface ImGuiWrapperOpenGLES2 : ImGuiWrapperBase

- (instancetype _Nonnull) initWithView: (ViewAlias * _Nonnull)view font: (NSString* _Nullable)fontPath;
- (void) newFrame;

- (void) image: (GLint) userTextureID : (CGSize)size : (CGPoint) uv0 : (CGPoint) uv1 : (CGColorRef _Nonnull) tintColor : (CGColorRef _Nonnull) borderColor;

@end
