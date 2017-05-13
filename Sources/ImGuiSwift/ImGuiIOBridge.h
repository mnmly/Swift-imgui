//
//  ImGuiIOBridge.h
//  Swift-imgui
//
//  Created by Hiroaki Yamane on 10/24/16.
//  Copyright © 2016 Hiroaki Yamane. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

@interface ImGuiIOBridge : NSObject

@property CGSize displaySize;
@property float deltaTime;
@property float iniSavingRate;
@property NSString* iniFilename;
@property NSString* logFilename;
@property float mouseDoubleClickTime;
@property float mouseDoubleClickMaxDist;
@property float mouseDragThreshold;
// int           KeyMap[ImGuiKey_COUNT];   // <unset>              // Map of indices into the KeysDown[512] entries array
@property float keyRepeatDelay;
@property float keyRepeatRate;
@property float fontGlobalScale;
@property bool FontAllowUserScaling;
@property CGSize displayFramebufferScale;
@property CGPoint displayVisibleMin;
@property CGPoint displayVisibleMax;

	// Advanced/subtle behaviors
@property bool wordMovementUsesAltKey;
@property bool shortcutsUseSuperKey;
@property bool doubleClickSelectsWord;
@property bool multiSelectUsesSuperKey;

	//------------------------------------------------------------------
	// User Functions
	//------------------------------------------------------------------

	// Rendering function, will be called in Render().
	// Alternatively you can keep this to NULL and call GetDrawData() after Render() to get the same pointer.
	// See example applications if you are unsure of how to implement this.
	//	void        (*RenderDrawListsFn)(ImDrawData* data);
	
	// Optional: access OS clipboard
	// (default to use native Win32 clipboard on Windows, otherwise uses a private clipboard. Override to access OS clipboard on other architectures)
	//	const char* (*GetClipboardTextFn)();
	//	void        (*SetClipboardTextFn)(const char* text);
	
	// Optional: override memory allocations. MemFreeFn() may be called with a NULL pointer.
	// (default to posix malloc/free)
	//	void*       (*MemAllocFn)(size_t sz);
	//	void        (*MemFreeFn)(void* ptr);
	
	// Optional: notify OS Input Method Editor of the screen position of your cursor for text input position (e.g. when using Japanese/Chinese IME in Windows)
	// (default to use native imm32 api on Windows)
	//	void        (*ImeSetInputScreenPosFn)(int x, int y);
	//	void*       ImeWindowHandle;            // (Windows) Set this to your HWND to get automatic IME cursor positioning.
	
	//------------------------------------------------------------------
	// Input - Fill before calling NewFrame()
	//------------------------------------------------------------------
	
@property CGPoint mousePos;
@property NSArray* mouseDown;
@property float mouseWheel;
@property bool mouseDrawCursor;
@property bool keyCtrl;
@property bool keyShift;
@property bool keyAlt;
@property bool keySuper;
@property NSArray* keysDown;
	// ImWchar     inputCharacters[16+1];      // List of characters input (translated by user from keypress+keyboard state). Fill using AddInputCharacter() helper.

	// Functions
	//	IMGUI_API void AddInputCharacter(ImWchar c);                        // Helper to add a new character into InputCharacters[]
	//	IMGUI_API void AddInputCharactersUTF8(const char* utf8_chars);      // Helper to add new characters into InputCharacters[] from an UTF-8 string
	//	IMGUI_API void ClearInputCharacters() { InputCharacters[0] = 0; }   // Helper to clear the text input buffer
	
	//------------------------------------------------------------------
	// Output - Retrieve after calling NewFrame(), you can use them to discard inputs or hide them from the rest of your application
	//------------------------------------------------------------------
	
@property bool wantCaptureMouse;
@property bool wantCaptureKeyboard;
@property bool wantTextInput;
@property float framerate;
@property int metricsAllocs;
@property int metricsRenderVertices;
@property int metricsRenderIndices;
@property int metricsActiveWindows;

@property CGPoint mousePosPrev;
@property CGPoint mouseDelta;
@property NSArray* mouseClicked;
@property NSArray* mouseClickedPos;
@property NSArray* mouseClickedTime;
@property NSArray* mouseDoubleClicked;
@property NSArray* mouseReleased;
@property NSArray* mouseDownOwned;
@property NSArray* mouseDownDuration;
@property NSArray* mouseDownDurationPrev;
@property NSArray* mouseDragMaxDistanceSqr;
@property NSArray* keysDownDuration;
@property NSArray* keysDownDurationPrev;

@end
