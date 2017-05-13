//
//  ImGuiIOBridge.m
//  Swift-imgui
//
//  Created by Hiroaki Yamane on 10/24/16.
//  Copyright © 2016 Hiroaki Yamane. All rights reserved.
//

#import "ImGuiIOBridge.h"

@implementation ImGuiIOBridge

- (instancetype)init
{
	self = [super init];
	if ( self ) {
		
		_displaySize = CGSizeZero;
		_deltaTime = 1.0 / 60.0;
		_iniSavingRate = 5.0;
		_iniFilename = @"imgui.ini";
		_logFilename = @"imgui_log.txt";
		_mouseDoubleClickTime = 0.30;
		_mouseDoubleClickMaxDist = 6.0;
		_mouseDragThreshold = 6.0;
		_keyRepeatDelay = 0.250;
		_keyRepeatRate = 0.020;
		
		_fontGlobalScale = 1.0;
		_FontAllowUserScaling = false;
		_displayFramebufferScale = CGSizeMake(1.0,  1.0);
		_displayVisibleMin = CGPointMake(0, 0);
		_displayVisibleMax = CGPointMake(0, 0);
		
		_wordMovementUsesAltKey = true;
		_shortcutsUseSuperKey = true;
		_doubleClickSelectsWord = true;
		_multiSelectUsesSuperKey = true;
		
		_mousePos = CGPointZero;
		// _keysDown = [NSArray arrayWithObjects:(id[5]){ FALSE } count:5];
		_mouseWheel = 1.0;
		_mouseDrawCursor = false;
		_keyCtrl = false;
		_keyShift = false;
		_keyAlt = false;
		_keySuper = false;
		// _keysDown = [NSArray arrayWithObjects:(id[512]){ FALSE } count:512];
		_wantCaptureMouse = false;
		_wantCaptureKeyboard = false;
		_wantTextInput = false;
		_framerate = 0.0;
		_metricsAllocs = 0;
		_metricsRenderVertices = 0;
		_metricsRenderIndices = 0;
		_metricsActiveWindows = 0;
		_mousePosPrev = CGPointZero;
		_mouseDelta = CGPointZero;
		// _mouseClicked = [NSArray arrayWithObjects:(id[5]){ FALSE } count:5];
		// _mouseClickedPos = [NSArray arrayWithObjects:(__bridge id _Nonnull)((CGPoint[5]){ CGPointZero }), nil];
//		_mouseClickedTime = [NSArray arrayWithObjects:(id[5]){ [NSNumber numberWithFloat:0.0] } count:5];
//		_mouseDoubleClicked = [NSArray arrayWithObjects:(id[5]){ FALSE } count:5];
//		_mouseReleased = [NSArray arrayWithObjects:(id[5]){ FALSE } count:5];
//		_mouseDownOwned = [NSArray arrayWithObjects:(id[5]){ FALSE } count:5];
//		_mouseDownDuration = [NSArray arrayWithObjects:(id[5]){ [NSNumber numberWithFloat:0.0] } count:5];
//		_mouseDownDurationPrev = [NSArray arrayWithObjects:(id[5]){ [NSNumber numberWithFloat:0.0] } count:5];
//		_mouseDragMaxDistanceSqr = [NSArray arrayWithObjects:(id[5]){ [NSNumber numberWithFloat:0.0] } count:5];
//		_keysDownDuration = [NSArray arrayWithObjects:(id[512]){ [NSNumber numberWithFloat:0.0] } count:512];
//		_keysDownDurationPrev = [NSArray arrayWithObjects:(id[512]){ [NSNumber numberWithFloat:0.0] } count:512];	

	}
	return self;
}
@end
