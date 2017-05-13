//
//  ImGuiStyleBridge.m
//  Swift-imgui
//
//  Created by Hiroaki Yamane on 10/24/16.
//  Copyright © 2016 Hiroaki Yamane. All rights reserved.
//

#import "ImGuiStyleBridge.h"

@implementation ImGuiStyleBridge

- (instancetype)init
{
	self = [super init];
	if ( self ) {
		_alpha = 0.0;
		_windowPadding = CGPointZero;
		_windowMinSize = CGSizeZero;
		_windowRounding = 0.0;
    	// mGuiAlign  WindowTitleAlign;           // Alignment for title bar text
		_childWindowRounding = 0.0;
		_framePadding = CGPointZero;
		_frameRounding = 0.0;
		_itemSpacing = CGPointZero;
		_itemInnerSpacing = CGPointZero;
		_touchExtraPadding = CGPointZero;
		_indentSpacing = 0.0;
		_columnsMinSpacing = 0.0;
		_scrollbarSize = 0.0;
		_scrollbarRounding = 0.0;
		_grabMinSize = 0.0;
		_grabRounding = 0.0;
		_displayWindowPadding  = CGPointZero;
		_displaySafeAreaPadding = CGPointZero;
		_antiAliasedLines  = true;
		_antiAliasedShapes = true;
		_curveTessellationTol = 0.0;
	}
	return self;
}
@end
