//
//  ImGuiStyleBridge.h
//  Swift-imgui
//
//  Created by Hiroaki Yamane on 10/24/16.
//  Copyright © 2016 Hiroaki Yamane. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

@interface ImGuiStyleBridge : NSObject

    @property float alpha;
    @property CGPoint windowPadding;
	@property CGSize windowMinSize;
    @property float windowRounding;            // Radius of window corners rounding. Set to 0.0f to have rectangular windows
    // @property float mGuiAlign  WindowTitleAlign;           // Alignment for title bar text
    @property float childWindowRounding;
    @property CGPoint framePadding;
    @property float frameRounding;
    @property CGPoint itemSpacing;
    @property CGPoint itemInnerSpacing;
    @property CGPoint touchExtraPadding;
    @property float indentSpacing;
    @property float columnsMinSpacing;
    @property float scrollbarSize;
    @property float scrollbarRounding;
    @property float grabMinSize;
    @property float grabRounding;
    @property CGPoint displayWindowPadding;
    @property CGPoint displaySafeAreaPadding;
    @property bool antiAliasedLines;
    @property bool antiAliasedShapes;
    @property float curveTessellationTol;
    @property NSMutableArray* colors;
@end
