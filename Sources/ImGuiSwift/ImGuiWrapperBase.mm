//
//  ImGuiWrapperBase.m
//  Swift-imgui
//
//  Created by Hiroaki Yamane on 1/24/17.
//  Copyright © 2017 Hiroaki Yamane. All rights reserved.
//
// ImGui iOS+OpenGL+Synergy binding
// In this binding, ImTextureID is used to store an OpenGL 'GLuint' texture identifier. Read the FAQ about ImTextureID in imgui.cpp.
// Providing a standalone iOS application with Synergy integration makes this sample more verbose than others. It also hasn't been tested as much.
// Refer to other examples to get an easier understanding of how to integrate ImGui into your existing application.

#include <sys/time.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netdb.h>
#include "uSynergy.h"

#include "imgui.h"

#import "ImGuiWrapperBase.h"
#import "ImGuiIOBridge.h"
#import "ImGuiStyleBridge.h"
#import "ImGuiKeyMapping.h"

static char g_keycodeCharUnshifted[256] = {};
static char g_keycodeCharShifted[256] = {};

//static double       g_Time = 0.0f;
static bool         g_MousePressed[3] = { false, false, false };
static float        g_mouseWheelX = 0.0f;
static float        g_mouseWheelY = 0.0f;

static int          usynergy_sockfd;
static bool         g_synergyPtrActive = false;
static uint16_t     g_mousePosX = 0;
static uint16_t     g_mousePosY = 0;
static NSString*    g_serverName;

void uSynergySetupFunctions( uSynergyContext &ctx );

@interface ImGuiWrapperBase ()
{
    BOOL _mouseDown;
    BOOL _mouseTapped;
    CGPoint _touchPos;
    
    uSynergyContext _synergyCtx;
    dispatch_queue_t _synergyQueue;
    
}

@property (nonatomic, strong) NSString *serverName;

#if TARGET_OS_IPHONE
@property (nonatomic, weak) UIView *view;
#else
@property (nonatomic, weak) NSView *view;
#endif

@end

@implementation ImGuiWrapperBase

- (void)setupKeymaps
{
    // The keyboard mapping is a big headache. I tried for a while to find a better way to do this,
    // but this was the best I could come up with. There are some device independent API's available
    // to convert scan codes to unicode characters, but these are only available on mac and not
    // on iOS as far as I can tell (it's part of Carbon). I didn't see any better way to do
    // this or  any way to get the character codes out of usynergy.
    g_keycodeCharUnshifted[ kVK_ANSI_A ]='a';
    g_keycodeCharUnshifted[ kVK_ANSI_S ]='s';
    g_keycodeCharUnshifted[ kVK_ANSI_D ]='d';
    g_keycodeCharUnshifted[ kVK_ANSI_F ]='f';
    g_keycodeCharUnshifted[ kVK_ANSI_H ]='h';
    g_keycodeCharUnshifted[ kVK_ANSI_G ]='g';
    g_keycodeCharUnshifted[ kVK_ANSI_Z ]='z';
    g_keycodeCharUnshifted[ kVK_ANSI_X ]='x';
    g_keycodeCharUnshifted[ kVK_ANSI_C ]='c';
    g_keycodeCharUnshifted[ kVK_ANSI_V ]='v';
    g_keycodeCharUnshifted[ kVK_ANSI_B ]='b';
    g_keycodeCharUnshifted[ kVK_ANSI_Q ]='q';
    g_keycodeCharUnshifted[ kVK_ANSI_W ]='w';
    g_keycodeCharUnshifted[ kVK_ANSI_E ]='e';
    g_keycodeCharUnshifted[ kVK_ANSI_R ]='r';
    g_keycodeCharUnshifted[ kVK_ANSI_Y ]='y';
    g_keycodeCharUnshifted[ kVK_ANSI_T ]='t';
    g_keycodeCharUnshifted[ kVK_ANSI_1 ]='1';
    g_keycodeCharUnshifted[ kVK_ANSI_2 ]='2';
    g_keycodeCharUnshifted[ kVK_ANSI_3 ]='3';
    g_keycodeCharUnshifted[ kVK_ANSI_4 ]='4';
    g_keycodeCharUnshifted[ kVK_ANSI_6 ]='6';
    g_keycodeCharUnshifted[ kVK_ANSI_5 ]='5';
    g_keycodeCharUnshifted[ kVK_ANSI_Equal ]='=';
    g_keycodeCharUnshifted[ kVK_ANSI_9 ]='9';
    g_keycodeCharUnshifted[ kVK_ANSI_7 ]='7';
    g_keycodeCharUnshifted[ kVK_ANSI_Minus ]='-';
    g_keycodeCharUnshifted[ kVK_ANSI_8 ]='8';
    g_keycodeCharUnshifted[ kVK_ANSI_0 ]='0';
    g_keycodeCharUnshifted[ kVK_ANSI_RightBracket ]=']';
    g_keycodeCharUnshifted[ kVK_ANSI_O ]='o';
    g_keycodeCharUnshifted[ kVK_ANSI_U ]='u';
    g_keycodeCharUnshifted[ kVK_ANSI_LeftBracket ]='[';
    g_keycodeCharUnshifted[ kVK_ANSI_I ]='i';
    g_keycodeCharUnshifted[ kVK_ANSI_P ]='p';
    g_keycodeCharUnshifted[ kVK_ANSI_L ]='l';
    g_keycodeCharUnshifted[ kVK_ANSI_J ]='j';
    g_keycodeCharUnshifted[ kVK_ANSI_Quote ]='\'';
    g_keycodeCharUnshifted[ kVK_ANSI_K ]='k';
    g_keycodeCharUnshifted[ kVK_ANSI_Semicolon ]=';';
    g_keycodeCharUnshifted[ kVK_ANSI_Backslash ]='\\';
    g_keycodeCharUnshifted[ kVK_ANSI_Comma ]=',';
    g_keycodeCharUnshifted[ kVK_ANSI_Slash ]='/';
    g_keycodeCharUnshifted[ kVK_ANSI_N ]='n';
    g_keycodeCharUnshifted[ kVK_ANSI_M ]='m';
    g_keycodeCharUnshifted[ kVK_ANSI_Period ]='.';
    g_keycodeCharUnshifted[ kVK_ANSI_Grave ]='`';
    g_keycodeCharUnshifted[ kVK_ANSI_KeypadDecimal ]='.';
    g_keycodeCharUnshifted[ kVK_ANSI_KeypadMultiply ]='*';
    g_keycodeCharUnshifted[ kVK_ANSI_KeypadPlus ]='+';
    g_keycodeCharUnshifted[ kVK_ANSI_KeypadDivide ]='/';
    g_keycodeCharUnshifted[ kVK_ANSI_KeypadEnter ]='\n';
    g_keycodeCharUnshifted[ kVK_ANSI_KeypadMinus ]='-';
    g_keycodeCharUnshifted[ kVK_ANSI_KeypadEquals ]='=';
    g_keycodeCharUnshifted[ kVK_ANSI_Keypad0 ]='0';
    g_keycodeCharUnshifted[ kVK_ANSI_Keypad1 ]='1';
    g_keycodeCharUnshifted[ kVK_ANSI_Keypad2 ]='2';
    g_keycodeCharUnshifted[ kVK_ANSI_Keypad3 ]='3';
    g_keycodeCharUnshifted[ kVK_ANSI_Keypad4 ]='4';
    g_keycodeCharUnshifted[ kVK_ANSI_Keypad5 ]='5';
    g_keycodeCharUnshifted[ kVK_ANSI_Keypad6 ]='6';
    g_keycodeCharUnshifted[ kVK_ANSI_Keypad7 ]='7';
    g_keycodeCharUnshifted[ kVK_ANSI_Keypad8 ]='8';
    g_keycodeCharUnshifted[ kVK_ANSI_Keypad9 ]='9';
    g_keycodeCharUnshifted[ kVK_Space ]=' ';
    
    g_keycodeCharShifted[ kVK_ANSI_A ]='A';
    g_keycodeCharShifted[ kVK_ANSI_S ]='S';
    g_keycodeCharShifted[ kVK_ANSI_D ]='D';
    g_keycodeCharShifted[ kVK_ANSI_F ]='F';
    g_keycodeCharShifted[ kVK_ANSI_H ]='H';
    g_keycodeCharShifted[ kVK_ANSI_G ]='G';
    g_keycodeCharShifted[ kVK_ANSI_Z ]='Z';
    g_keycodeCharShifted[ kVK_ANSI_X ]='X';
    g_keycodeCharShifted[ kVK_ANSI_C ]='C';
    g_keycodeCharShifted[ kVK_ANSI_V ]='V';
    g_keycodeCharShifted[ kVK_ANSI_B ]='B';
    g_keycodeCharShifted[ kVK_ANSI_Q ]='Q';
    g_keycodeCharShifted[ kVK_ANSI_W ]='W';
    g_keycodeCharShifted[ kVK_ANSI_E ]='E';
    g_keycodeCharShifted[ kVK_ANSI_R ]='R';
    g_keycodeCharShifted[ kVK_ANSI_Y ]='Y';
    g_keycodeCharShifted[ kVK_ANSI_T ]='T';
    g_keycodeCharShifted[ kVK_ANSI_1 ]='!';
    g_keycodeCharShifted[ kVK_ANSI_2 ]='@';
    g_keycodeCharShifted[ kVK_ANSI_3 ]='#';
    g_keycodeCharShifted[ kVK_ANSI_4 ]='$';
    g_keycodeCharShifted[ kVK_ANSI_6 ]='^';
    g_keycodeCharShifted[ kVK_ANSI_5 ]='%';
    g_keycodeCharShifted[ kVK_ANSI_Equal ]='+';
    g_keycodeCharShifted[ kVK_ANSI_9 ]='(';
    g_keycodeCharShifted[ kVK_ANSI_7 ]='&';
    g_keycodeCharShifted[ kVK_ANSI_Minus ]='_';
    g_keycodeCharShifted[ kVK_ANSI_8 ]='*';
    g_keycodeCharShifted[ kVK_ANSI_0 ]=')';
    g_keycodeCharShifted[ kVK_ANSI_RightBracket ]='}';
    g_keycodeCharShifted[ kVK_ANSI_O ]='O';
    g_keycodeCharShifted[ kVK_ANSI_U ]='U';
    g_keycodeCharShifted[ kVK_ANSI_LeftBracket ]='{';
    g_keycodeCharShifted[ kVK_ANSI_I ]='I';
    g_keycodeCharShifted[ kVK_ANSI_P ]='P';
    g_keycodeCharShifted[ kVK_ANSI_L ]='L';
    g_keycodeCharShifted[ kVK_ANSI_J ]='J';
    g_keycodeCharShifted[ kVK_ANSI_Quote ]='\"';
    g_keycodeCharShifted[ kVK_ANSI_K ]='K';
    g_keycodeCharShifted[ kVK_ANSI_Semicolon ]=':';
    g_keycodeCharShifted[ kVK_ANSI_Backslash ]='|';
    g_keycodeCharShifted[ kVK_ANSI_Comma ]='<';
    g_keycodeCharShifted[ kVK_ANSI_Slash ]='?';
    g_keycodeCharShifted[ kVK_ANSI_N ]='N';
    g_keycodeCharShifted[ kVK_ANSI_M ]='M';
    g_keycodeCharShifted[ kVK_ANSI_Period ]='>';
    g_keycodeCharShifted[ kVK_ANSI_Grave ]='~';
    g_keycodeCharShifted[ kVK_ANSI_KeypadDecimal ]='.';
    g_keycodeCharShifted[ kVK_ANSI_KeypadMultiply ]='*';
    g_keycodeCharShifted[ kVK_ANSI_KeypadPlus ]='+';
    g_keycodeCharShifted[ kVK_ANSI_KeypadDivide ]='/';
    g_keycodeCharShifted[ kVK_ANSI_KeypadEnter ]='\n';
    g_keycodeCharShifted[ kVK_ANSI_KeypadMinus ]='-';
    g_keycodeCharShifted[ kVK_ANSI_KeypadEquals ]='=';
    g_keycodeCharShifted[ kVK_ANSI_Keypad0 ]='0';
    g_keycodeCharShifted[ kVK_ANSI_Keypad1 ]='1';
    g_keycodeCharShifted[ kVK_ANSI_Keypad2 ]='2';
    g_keycodeCharShifted[ kVK_ANSI_Keypad3 ]='3';
    g_keycodeCharShifted[ kVK_ANSI_Keypad4 ]='4';
    g_keycodeCharShifted[ kVK_ANSI_Keypad5 ]='5';
    g_keycodeCharShifted[ kVK_ANSI_Keypad6 ]='6';
    g_keycodeCharShifted[ kVK_ANSI_Keypad7 ]='7';
    g_keycodeCharShifted[ kVK_ANSI_Keypad8 ]='8';
    g_keycodeCharShifted[ kVK_ANSI_Keypad9 ]='9';
    g_keycodeCharShifted[ kVK_Space ]=' ';
}

- (void)loadFontFile:(NSString*) path {
    ImGuiIO &io = ImGui::GetIO();
    io.Fonts->AddFontFromFileTTF(path.UTF8String, 28);
}

- (void)setupImGuiHooks
{
    [self setupImGuiHooks: nil];
}

- (void)setupImGuiHooks: (NSString *)fontPath
{
    ImGuiIO &io = ImGui::GetIO();
    if (fontPath) {
        [self loadFontFile:fontPath];
    }
    
    [self setupKeymaps];
    
    // Account for retina display for glScissor
    ImGuiStyle &style = ImGui::GetStyle();
    style.TouchExtraPadding = ImVec2( 4.0, 4.0 );
    [self setupRenderDrawLists];
    
    // Fill out the Synergy key map
    // (for some reason synergy scan codes are off by 1)
    io.KeyMap[ImGuiKey_Tab] = kVK_Tab+1;
    io.KeyMap[ImGuiKey_LeftArrow] = kVK_LeftArrow+1;
    io.KeyMap[ImGuiKey_RightArrow] = kVK_RightArrow+1;
    io.KeyMap[ImGuiKey_UpArrow] = kVK_UpArrow+1;
    io.KeyMap[ImGuiKey_DownArrow] = kVK_DownArrow+1;
    io.KeyMap[ImGuiKey_Home] = kVK_Home+1;
    io.KeyMap[ImGuiKey_End] = kVK_End+1;
    io.KeyMap[ImGuiKey_Delete] = kVK_ForwardDelete+1;
    io.KeyMap[ImGuiKey_Backspace] = kVK_Delete+1;
    io.KeyMap[ImGuiKey_Enter] = kVK_Return+1;
    io.KeyMap[ImGuiKey_Escape] = kVK_Escape+1;
    io.KeyMap[ImGuiKey_A] = kVK_ANSI_A+1;
    io.KeyMap[ImGuiKey_C] = kVK_ANSI_C+1;
    io.KeyMap[ImGuiKey_V] = kVK_ANSI_V+1;
    io.KeyMap[ImGuiKey_X] = kVK_ANSI_X+1;
    io.KeyMap[ImGuiKey_Y] = kVK_ANSI_Y+1;
    io.KeyMap[ImGuiKey_Z] = kVK_ANSI_Z+1;
}


#if TARGET_OS_IPHONE
-(void)setupGestures:(UIView *)view {
    
    self.view = view;
    
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(viewDidPan:)];
    [self.view addGestureRecognizer:panRecognizer];
    
    UITapGestureRecognizer *tapRecoginzer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewDidTap:)];
    [self.view addGestureRecognizer:tapRecoginzer];
    
    panRecognizer.delegate = self;
    tapRecoginzer.delegate = self;
}

- (void)viewDidPan: (UIPanGestureRecognizer *)recognizer
{
    
    if ((recognizer.state == UIGestureRecognizerStateBegan) ||
        (recognizer.state == UIGestureRecognizerStateChanged))
    {
        _mouseDown = YES;
        _touchPos = [recognizer locationInView:self.view];
    }
    else
    {
        _mouseDown = NO;
        _touchPos = CGPointMake( -1, -1 );
    }
    
}

- (void)viewDidTap: (UITapGestureRecognizer*)recognizer
{
    _touchPos = [recognizer locationInView:self.view];
    _mouseTapped = YES;
}

#pragma - mark UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

#else

-(void)setupGestures:(NSView *)view {
    
    self.view = view;
    NSPanGestureRecognizer *panRecognizer = [[NSPanGestureRecognizer alloc] initWithTarget:self action:@selector(viewDidPan:)];
    [self.view addGestureRecognizer:panRecognizer];
    
    NSClickGestureRecognizer *tapRecoginzer = [[NSClickGestureRecognizer alloc] initWithTarget:self action:@selector(viewDidTap:)];
    [self.view addGestureRecognizer:tapRecoginzer];
    
}

- (void)viewDidPan: (NSPanGestureRecognizer *)recognizer
{
    
    if ((recognizer.state == NSGestureRecognizerStateBegan) ||
        (recognizer.state == NSGestureRecognizerStateChanged))
    {
        _mouseDown = YES;
        _touchPos = [recognizer locationInView:self.view];
        _touchPos = CGPointMake(_touchPos.x, self.view.bounds.size.height - _touchPos.y);
    }
    else
    {
        _mouseDown = NO;
        _touchPos = CGPointMake( -1, -1 );
    }
    
}

- (void)viewDidTap: (NSClickGestureRecognizer*)recognizer
{
    _touchPos = [recognizer locationInView:self.view];
    _touchPos = CGPointMake(_touchPos.x, self.view.bounds.size.height - _touchPos.y);
    _mouseTapped = YES;
}
#endif

- (void)connectServer: (NSString*)serverName
{
    self.serverName = serverName;
    g_serverName = serverName;
    
    // Init synergy
    NSString *bundleName = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString*)kCFBundleNameKey];
    
    uSynergyInit( &_synergyCtx );
    _synergyCtx.m_clientName = strdup( [bundleName UTF8String] );
    
    _synergyCtx.m_clientWidth = self.view.bounds.size.width;
    _synergyCtx.m_clientHeight = self.view.bounds.size.height;
    
    uSynergySetupFunctions(_synergyCtx);
    
    // Create a background thread for synergy
    _synergyQueue = dispatch_queue_create( "imgui-usynergy", NULL );
    dispatch_async( _synergyQueue, ^{
        while (1) {
            uSynergyUpdate( &_synergyCtx );
        }
    });
}

- (void) setViewport: (CGSize)size : (CGFloat)scale
{
    int w = size.width;
    int h = size.height;
    
    _synergyCtx.m_clientWidth = w;
    _synergyCtx.m_clientHeight = h;
    
    ImGuiIO& io = ImGui::GetIO();
    io.DisplaySize = ImVec2( w, h );
    io.DisplayFramebufferScale = ImVec2( scale, scale );
    io.FontGlobalScale = 1.0 / scale;
    
#pragma mark - @TODO: DO I NEED TO Handle this here?
    //	CGRect bounds = CGRectMake( 0, 0, w, h );
    //	CGRect nativeBounds = CGRectMake( 0, 0, _screenScale * w, _screenScale * h );
    //	[self.view.layer setFrame:bounds];
    //	[self.view.layer setContentsScale:nativeBounds.size.width / bounds.size.width];
    //	[self.view setDrawableSize:nativeBounds.size];
}

- (void) setupMouse
{
	ImGuiIO& io = ImGui::GetIO();
	ImGuiStyle &style = ImGui::GetStyle();
	
	io.MouseDrawCursor = g_synergyPtrActive;
	if (g_synergyPtrActive)
	{
		style.TouchExtraPadding = ImVec2( 0.0, 0.0 );
		io.MousePos = ImVec2( g_mousePosX, g_mousePosY );
		for (int i=0; i < 3; i++)
		{
			io.MouseDown[i] = g_MousePressed[i];
		}
		
		// This is an arbitrary scaling factor that works for me. Not sure what units these
		// mousewheel values from synergy are supposed to be in
		io.MouseWheel = g_mouseWheelY / 500.0;
	}
	else
	{
		// Synergy not active, use touch events
		style.TouchExtraPadding = ImVec2( 4.0, 4.0 );
		io.MousePos = ImVec2(_touchPos.x, _touchPos.y );
		if ((_mouseDown) || (_mouseTapped))
		{
			io.MouseDown[0] = true;
			_mouseTapped = NO;
		}
		else
		{
			io.MouseDown[0] = false;
		}
	}
}

- (void)render
{
    ImGui::Render();
}

#pragma mark - ImGUI API

- (void) setNextWindowSize: (CGSize)size : (int) cond
{
    ImGui::SetNextWindowSize(ImVec2(size.width,size.height), cond);
}

- (void)setNextWindowPos: (CGPoint)pos : (int) cond
{
    ImGui::SetNextWindowPos(ImVec2(pos.x,pos.y), cond);
}

- (void)setWindowSize:(CGSize)size :(int)cond
{
    ImVec2 _size = [self fromCGSize:size];
    ImGui::SetWindowSize(_size, cond);
}

- (void)setWindowPos:(CGPoint)pos :(int)cond
{
    ImVec2 _pos = [self fromCGPoint:pos];
    ImGui::SetWindowPos(_pos, cond);
}

- (void)setWindowFontScale: (float)scale
{
    ImGui::SetWindowFontScale(scale);
}

- (void)openPopup: (NSString *) strId
{
    ImGui::OpenPopup(strId.UTF8String);
}

- (BOOL) beginPopup: (NSString *)strId
{
    return ImGui::BeginPopup(strId.UTF8String);
}

- (void)endPopup
{
    ImGui::EndPopup();
}

- (float)getTime
{
    return ImGui::GetTime();
}

- (void)plotLines: (NSString *)label :(const float *) values : (int) valueCount :(int)valuesOffset : (NSString *) overlayText :(float)minScale : (float)maxScale : (CGSize)graphSize : (int)stride;
{
    ImGui::PlotLines(label.UTF8String, values, valueCount, valuesOffset, overlayText.UTF8String, minScale, maxScale, ImVec2(graphSize.width, graphSize.height), stride);
}

- (void)plotLinesGetter:(NSString *)label :(PlotValuesGetter)valuesGetter :(void *)data :(int)valuesCount :(int)valuesOffset :(NSString *)overlayText :(float)minScale :(float)maxScale :(CGSize)graphSize
{
    ImGui::PlotLines(label.UTF8String, valuesGetter, data, valuesCount, valuesOffset, overlayText.UTF8String, minScale, maxScale, [self fromCGSize:graphSize]);
}

- (void)plotHistogram: (NSString *)label :(const float *) values : (int) valueCount : (int)valuesOffset  : (NSString *)overlayText : (float)scaleMin : (float) scaleMax : (CGSize)graphSize : (int)stride;
{
    ImGui::PlotHistogram(label.UTF8String, values, valueCount, valuesOffset, overlayText.UTF8String, scaleMin, scaleMax, [self fromCGSize: graphSize], stride);
}

- (void)plotHistogramGetter:(NSString *)label :(PlotValuesGetter)valuesGetter :(void *)data :(int)valuesCount :(int)valuesOffset :(NSString *)overlayText :(float)minScale :(float)maxScale :(CGSize)graphSize
{
    ImGui::PlotHistogram(label.UTF8String, valuesGetter, data, valuesCount, valuesOffset, overlayText.UTF8String, minScale, maxScale, [self fromCGSize:graphSize]);
}

- (BOOL)selectable: (NSString *)label :(BOOL) selected : (int)flags : (CGSize)size
{
    return ImGui::Selectable(label.UTF8String, selected, flags, [self fromCGSize:size]);
}

- (BOOL)selectablePointer: (NSString *)label :(BOOL*) selected : (int)flags : (CGSize) size
{
    return ImGui::Selectable(label.UTF8String, selected, flags, [self fromCGSize:size]);
    
}

- (void)begin: (NSString *)name : (BOOL*)show : (int)flags
{
    if (show != NULL) {
        bool _show = (*show == TRUE) ? true : false;
        ImGui::Begin(name.UTF8String, &_show, flags);
        *show = _show ? TRUE : FALSE;
    } else {
        ImGui::Begin(name.UTF8String, NULL, flags);
    }
}

- (BOOL) combo:(NSString *)label :(int *)currentItem :(NSArray<NSString *> *)items :(int)heightInItems
{
    const char* _items[items.count];
    NSUInteger count = 0;
    for (NSString* item in items) {
        _items[count] = (char *)item.UTF8String;
        count++;
    }
    
    return	ImGui::Combo(label.UTF8String, currentItem, _items, (int)items.count, heightInItems);
}

- (BOOL)beginMenu: (NSString *)label : (BOOL)enabled
{
    return ImGui::BeginMenu(label.UTF8String, enabled);
}

- (void)closeCurrentPopup
{
    ImGui::CloseCurrentPopup();
}


- (BOOL)menuItem: (NSString *)label : (NSString *)shortcut : (BOOL)selected : (BOOL)enabled {
    return ImGui::MenuItem(label.UTF8String, shortcut.UTF8String, selected, enabled);
}

- (BOOL)menuItemPointer: (NSString *)label : (NSString *)shortcut : (BOOL*)selected : (BOOL)enabled {
    return ImGui::MenuItem(label.UTF8String, shortcut.UTF8String, selected, enabled);
}

- (void)endMenu {
    ImGui::EndMenu();
}

- (BOOL)colorEdit: (NSString *)label :(float *)color {
    return ImGui::ColorEdit4(label.UTF8String, color);
}

- (BOOL)radioButton: (NSString *)label :(BOOL)active {
    return ImGui::RadioButton([label UTF8String], active);
}

- (BOOL)radioButtonVButton: (NSString *)label :(int *)v : (int)vButton{
    return ImGui::RadioButton(label.UTF8String, v, vButton);
}

- (void)bullet
{
    ImGui::Bullet();
}

- (void)bulletText: (NSString *)text
{
    ImGui::BulletText("%s", text.UTF8String);
}

- (void)bulletTextV: (NSString *)text
{
    
}

- (void)addText: (NSString *)text : (CGPoint)pos :(CGColorRef)color
{
    ImGui::GetWindowDrawList()->AddText([self fromCGPoint:pos], [self fromCGColor:color], text.UTF8String);
}

- (float)getScrollX
{
    return ImGui::GetScrollX();
}

- (float)getScrollY
{
    return ImGui::GetScrollY();
}

- (void)setScrollX: (float)scrollX
{
    ImGui::SetScrollX(scrollX);
}

- (void)setScrollY: (float)scrollY
{
    ImGui::SetScrollY(scrollY);
}

- (BOOL)isMouseDragging
{
    return ImGui::IsMouseDragging();
}

- (void)addText
{
    // ImGui::GetWindowDrawList()->AddText(<#const ImFont *font#>, <#float font_size#>, <#const ImVec2 &pos#>, <#ImU32 col#>, <#const char *text_begin#>)
}

- (void)addRect: (CGRect)rect : (CGColorRef)color : (float)rounding : (int)roundingCorners
{
    const ImVec2 a = [self fromCGPoint:rect.origin];
    const ImVec2 b = ImVec2(rect.origin.x + rect.size.width, rect.origin.y + rect.size.height);
    ImGui::GetWindowDrawList()->AddRect(a, b, [self fromCGColor:color]);
}

- (void)addRectFilled: (CGRect)rect : (CGColorRef)color : (float)rounding : (int)roundingCorners
{
    const ImVec2 a = [self fromCGPoint:rect.origin];
    const ImVec2 b = ImVec2(rect.origin.x + rect.size.width, rect.origin.y + rect.size.height);
    ImGui::GetWindowDrawList()->AddRectFilled(a, b, [self fromCGColor:color], rounding, roundingCorners);
}

- (void)addRectFilledMultiColor: (CGRect)rect : (CGColorRef) colorUpperLeft : (CGColorRef)colorUpperRight : (CGColorRef)colorBottomRight : (CGColorRef)colorBottomLeft
{
    const ImVec2 a = [self fromCGPoint:rect.origin];
    const ImVec2 b = ImVec2(rect.origin.x + rect.size.width, rect.origin.y + rect.size.height);
    ImGui::GetWindowDrawList()->AddRectFilledMultiColor(a, b, [self fromCGColor:colorUpperLeft], [self fromCGColor:colorUpperRight], [self fromCGColor:colorBottomRight], [self fromCGColor:colorBottomLeft]);
}

- (ImVec2)fromCGPoint: (CGPoint) point
{
    return ImVec2(point.x, point.y);
}

- (ImVec2)fromCGSize: (CGSize) size
{
    return ImVec2(size.width, size.height);
}

- (ImColor)fromCGColor: (CGColorRef) color
{
    const CGFloat* components = CGColorGetComponents(color);
    size_t numComponents = CGColorGetNumberOfComponents(color);
    if (numComponents == 2) {
        return ImVec4(components[0], components[0], components[0], components[1]);
    } else {
        return ImVec4(components[0], components[1], components[2], components[3]);
    }
}

- (CGPoint)toCGPoint: (ImVec2) point
{
    return CGPointMake(point.x, point.y);
}

- (CGSize)toCGSize: (ImVec2) size
{
    return CGSizeMake(size.x, size.y);
}

- (BOOL)checkbox: (NSString *)label :(BOOL *)active {
    bool _active = (*active == TRUE) ? true : false;
    BOOL res = ImGui::Checkbox([label UTF8String], &_active);
    *active = _active ? TRUE : FALSE;
    return res;
}

- (BOOL)sliderInt: (NSString *)label : (int *) v : (int)numComponent : (int)vMin : (int)vMax : (NSString *)displayFormat
{
    switch (numComponent) {
        case 1: return ImGui::SliderInt(label.UTF8String, v, vMin, vMax, displayFormat.UTF8String);
        case 2: return ImGui::SliderInt2(label.UTF8String, v, vMin, vMax, displayFormat.UTF8String);
        case 3: return ImGui::SliderInt3(label.UTF8String, v, vMin, vMax, displayFormat.UTF8String);
        case 4: return ImGui::SliderInt4(label.UTF8String, v, vMin, vMax, displayFormat.UTF8String);
    }
    
    return FALSE;
}

- (BOOL)sliderFloat: (NSString *)label : (float *) v : (int)numComponent : (float)vMin : (float)vMax : (NSString *)displayFormat : (float)power
{
    switch (numComponent) {
        case 1: return ImGui::SliderFloat(label.UTF8String, v, vMin, vMax, displayFormat.UTF8String, power);
        case 2: return ImGui::SliderFloat2(label.UTF8String, v, vMin, vMax, displayFormat.UTF8String, power);
        case 3: return ImGui::SliderFloat3(label.UTF8String, v, vMin, vMax, displayFormat.UTF8String, power);
        case 4: return ImGui::SliderFloat4(label.UTF8String, v, vMin, vMax, displayFormat.UTF8String, power);
    }
    
    return FALSE;
}

- (BOOL) sliderAngle: (NSString *)label : (float *) rad : (float)vDegreeMin : (float)vDegreeMax
{
    return ImGui::SliderAngle(label.UTF8String, rad, vDegreeMin, vDegreeMax);
}

- (BOOL) vSliderInt: (NSString *)label : (CGSize)size : (int *) v : (int)vMin : (int)vMax : (NSString *)displayFormat
{
    return ImGui::VSliderInt(label.UTF8String, ImVec2(size.width, size.height), v, vMin, vMax, displayFormat.UTF8String);
}

- (BOOL) vSliderFloat: (NSString *)label : (CGSize)size : (float *) v : (float)vMin : (float)vMax : (NSString *)displayFormat : (float)power
{
    return ImGui::VSliderFloat(label.UTF8String, ImVec2(size.width, size.height), v, vMin, vMax, displayFormat.UTF8String, power);
}

- (BOOL)dragFloat: (NSString *)label : (float *) v : (int)numComponent : (float)vSpeed : (float)vMin : (float)vMax : (NSString *)displayFormat : (float)power
{
    switch (numComponent) {
        case 1: return ImGui::DragFloat(label.UTF8String, v, vSpeed, vMin, vMax, displayFormat.UTF8String, power);
        case 2: return ImGui::DragFloat2(label.UTF8String, v, vSpeed, vMin, vMax, displayFormat.UTF8String, power);
        case 3: return ImGui::DragFloat3(label.UTF8String, v, vSpeed, vMin, vMax, displayFormat.UTF8String, power);
        case 4: return ImGui::DragFloat4(label.UTF8String, v, vSpeed, vMin, vMax, displayFormat.UTF8String, power);
    }
    return FALSE;
}

- (BOOL)dragInt: (NSString *)label : (int *) v : (int)numComponent : (float)vSpeed : (int)vMin : (int)vMax : (NSString *)displayFormat
{
    switch (numComponent) {
        case 1: return ImGui::DragInt(label.UTF8String, v, vSpeed, vMin, vMax, displayFormat.UTF8String);
        case 2: return ImGui::DragInt2(label.UTF8String, v, vSpeed, vMin, vMax, displayFormat.UTF8String);
        case 3: return ImGui::DragInt3(label.UTF8String, v, vSpeed, vMin, vMax, displayFormat.UTF8String);
        case 4: return ImGui::DragInt4(label.UTF8String, v, vSpeed, vMin, vMax, displayFormat.UTF8String);
    }
    
    return FALSE;
}

- (BOOL) dragIntRange2: (NSString *)label : (int *)vCurrentMin : (int *)vCurrentMax : (float)vSpeed : (int)vMin : (int)vMax : (NSString *)displayFormat : (NSString *)displayFormatMax
{
    return ImGui::DragIntRange2(label.UTF8String, vCurrentMin, vCurrentMax, vSpeed, vMin, vMax, displayFormat.UTF8String, displayFormatMax.UTF8String);
}

- (float)getContentRegionAvailWidth
{
    return ImGui::GetContentRegionAvailWidth();
}

- (float)getWindowWidth
{
    return ImGui::GetWindowWidth();
}

- (void)pushIDWithInt: (int)_id
{
    ImGui::PushID(_id);
}

- (void)pushIDWithString: (NSString *)_id
{
    ImGui::PushID(_id.UTF8String);
}

- (void)popID
{
    ImGui::PopID();
}

- (void)dummy: (CGSize)size
{
    ImGui::Dummy(ImVec2(size.width, size.height));
}

-(BOOL)button: (NSString *) label : (CGSize)size {
    return ImGui::Button(label.UTF8String, ImVec2(size.width, size.height));
}

-(BOOL)colorButton:(CGColorRef) color : (BOOL)smallHeight : (BOOL) outlineBorder
{
    return ImGui::ColorButton([self fromCGColor:color], smallHeight, outlineBorder);
}

- (BOOL) beginPopupModal: (NSString *)name : (BOOL *)opened
{
    bool _opened = (*opened == TRUE) ? true : false;
    BOOL res = ImGui::BeginPopupModal(name.UTF8String, &_opened, 0);
    *opened = _opened ? TRUE : FALSE;
    return res;
}

- (BOOL)beginPopupContextItem: (NSString *)strId : (int)mouseButton/*=1*/
{
    return ImGui::BeginPopupContextItem(strId.UTF8String, mouseButton);
}

-(BOOL) beginPopupContextWindow : (BOOL) alsoOverItems/* = true*/ : (NSString *)strId : (int) mouseButton
{
    return ImGui::BeginPopupContextWindow(alsoOverItems, strId.UTF8String, mouseButton);
}

- (BOOL)beginPopupContextVoid: (NSString *)strId : (int)mouseButton
{
    return ImGui::BeginPopupContextVoid(strId.UTF8String, mouseButton);
}

- (void)spacing
{
    ImGui::Spacing();
}

- (CGPoint)getCursorScreenPos
{
    ImVec2 pos = ImGui::GetCursorScreenPos();
    return CGPointMake(pos.x, pos.y);
}

- (float) getTextLineHeight
{
    return ImGui::GetTextLineHeight();
}

- (CGPoint)getCursorPos
{
    ImVec2 pos = ImGui::GetCursorPos();
    return CGPointMake(pos.x, pos.y);
}

- (void) pushTextWrapPos: (float)wrapPos
{
    ImGui::PushTextWrapPos(wrapPos);
}

- (void)showStyleEditor
{
    // ImGui::ShowStyleEditor();
}

- (void)logButtons
{
    ImGui::LogButtons();
}

- (void) popTextWrapPos
{
    ImGui::PopTextWrapPos();
}

-(BOOL)invisibleButton: (NSString *) label : (CGSize)size {
    return ImGui::InvisibleButton(label.UTF8String, ImVec2(size.width, size.height));
}

-(BOOL)smallButton: (NSString *) label {
    return ImGui::SmallButton(label.UTF8String);
}

- (void) alignFirstTextHeightToWidgets
{
    ImGui::AlignFirstTextHeightToWidgets();
}

- (void)pushItemWidth: (float)width
{
    ImGui::PushItemWidth(width);
}

-(BOOL)isItemHovered
{
    return ImGui::IsItemHovered();
}

- (void)setTooltip: (NSString *)text
{
    return ImGui::SetTooltip("%s", text.UTF8String);
}

- (void)beginTooltip
{
    ImGui::BeginTooltip();
}

- (void)endTooltip
{
    ImGui::EndTooltip();
}

- (void)indent
{
    ImGui::Indent();
}

- (void)unindent
{
    ImGui::Unindent();
}


- (BOOL)listBoxHeader:(NSString *)label withSize:(CGSize)size
{
    return ImGui::ListBoxHeader(label.UTF8String, ImVec2(size.width, size.height));
}

- (BOOL)listBoxHeader: (NSString *)label withItemsCount:(int)itemsCount withHeightInItems: (int)heightInItems
{
    return ImGui::ListBoxHeader(label.UTF8String, itemsCount, heightInItems);
}

- (void)listBoxFooter
{
    ImGui::ListBoxFooter();
}


- (void)beginGroup
{
    ImGui::BeginGroup();
}

- (CGSize)getItemRectSize
{
    ImVec2 size = ImGui::GetItemRectSize();
    return CGSizeMake(size.x, size.y);
}

- (CGPoint)getItemRectMin
{
    auto p = ImGui::GetItemRectMin();
    return CGPointMake(p.x, p.y);
}

- (CGPoint)getItemRectMax
{
    auto p = ImGui::GetItemRectMax();
    return CGPointMake(p.x, p.y);
}

- (void)endGroup
{
    ImGui::EndGroup();
}


- (void)popItemWidth
{
    ImGui::PopItemWidth();
}

- (void)pushStyleVar: (int)idx withFloat:(float)val {
    ImGui::PushStyleVar(idx, val);
}

- (void)pushStyleVar: (int)idx withPoint: (CGPoint)val {
    ImGui::PushStyleVar(idx, ImVec2(val.x, val.y));
}

- (void)popStyleVar:(int)count
{
    ImGui::PopStyleVar(count);
}

- (void)pushStyleColor: (int)idx withColor:(CGColorRef)color
{
    ImGui::PushStyleColor(idx, [self fromCGColor:color]);
}

- (void)popStyleColor: (int)count
{
    ImGui::PopStyleColor(count);
}

- (void)popStyleVar
{
    ImGui::PopStyleVar();
}

- (BOOL) listBox: (NSString *)label :(int *)currentItem : (NSArray<NSString *> *)items : (int)heightInItems
{
    const char* _items[items.count];
    for (int i = 0; i < items.count; i++) {
        _items[ i ] = [items objectAtIndex:i].UTF8String;
    }
    return ImGui::ListBox(label.UTF8String, currentItem, _items, int(items.count), heightInItems);
}

- (BOOL) collapsingHeader: (NSString * _Nonnull) label : (NSString * _Nullable) strID : (BOOL) displayFrame : (BOOL)defaultOpen
{
    return ImGui::CollapsingHeader(label.UTF8String, strID.UTF8String, displayFrame, defaultOpen);
}

- (void) progressBar: (float)progress : (CGPoint)position : (NSString *)text
{
    ImGui::ProgressBar(progress, ImVec2(position.x, position.y), text.UTF8String);
}

- (float) deltaTime
{
    return ImGui::GetIO().DeltaTime;
}

-(void)text: (NSString *) label
{
    ImGui::Text("%s", label.UTF8String);
}

- (void)textDisabled:(NSString *)label
{
    ImGui::TextDisabled("%s", label.UTF8String);
}

- (BOOL)beginChild: (NSString *)strId : (CGSize)sizeArg : (BOOL)border : (int)extraFlags
{
    return ImGui::BeginChild(strId.UTF8String, ImVec2(sizeArg.width, sizeArg.height), border, extraFlags);
}

- (float)getWindowContentRegionWidth
{
    return ImGui::GetWindowContentRegionWidth();
}

- (void)endChild
{
    ImGui::EndChild();
}

- (ImGuiStyleBridge *)getStyle
{
    // ImGui::BeginChild(<#const char *str_id#>)
    // return ImGui::GetStyle();
    ImGuiStyleBridge* trans = [[ImGuiStyleBridge alloc] init];
    ImGuiStyle& style = ImGui::GetStyle();
    trans.alpha = style.Alpha;
    trans.windowPadding = CGPointMake(style.WindowPadding.x, style.WindowPadding.y);
    trans.windowMinSize = CGSizeMake(style.WindowMinSize.x, style.WindowMinSize.y);
    trans.windowRounding = style.WindowRounding;
    trans.childWindowRounding = style.ChildWindowRounding;
    
    trans.framePadding = CGPointMake(style.FramePadding.x, style.FramePadding.y);
    trans.frameRounding = style.FrameRounding;
    trans.itemSpacing = CGPointMake(style.ItemSpacing.x, style.ItemSpacing.y);
    trans.itemInnerSpacing = CGPointMake(style.ItemInnerSpacing.x, style.ItemInnerSpacing.y);
    trans.touchExtraPadding = CGPointMake(style.TouchExtraPadding.x, style.TouchExtraPadding.y);
    trans.indentSpacing = style.IndentSpacing;
    trans.columnsMinSpacing = style.ColumnsMinSpacing;
    trans.scrollbarSize = style.ScrollbarSize;
    trans.scrollbarRounding = style.ScrollbarRounding;
    trans.grabMinSize = style.GrabMinSize;
    trans.grabRounding = style.GrabRounding;
    trans.displayWindowPadding = CGPointMake(style.DisplayWindowPadding.x, style.DisplayWindowPadding.y);
    trans.displaySafeAreaPadding = CGPointMake(style.DisplaySafeAreaPadding.x, style.DisplaySafeAreaPadding.y);
    trans.antiAliasedLines = style.AntiAliasedLines;
    trans.antiAliasedShapes = style.AntiAliasedShapes;
    trans.curveTessellationTol = style.CurveTessellationTol;
    
    /* @TODO
    for (int i = 0; i < ImGuiCol_COUNT; i++) {
        ImVec4 _color = style.Colors[i];
        SKColor* color = [SKColor colorWithRed:_color.x green:_color.y blue:_color.z alpha:_color.w];
        [trans.colors addObject: color];
    }
     */
    
    return trans;
}

- (ImGuiIOBridge *)getIO
{
    ImGuiIOBridge* io = [[ImGuiIOBridge alloc] init];
    ImGuiIO& _io = ImGui::GetIO();
    
    io.displaySize = [self toCGSize: _io.DisplaySize];
    io.deltaTime = _io.DeltaTime;
    io.iniSavingRate = _io.IniSavingRate;
    io.iniFilename = [NSString stringWithUTF8String:_io.IniFilename];
    io.logFilename = [NSString stringWithUTF8String:_io.LogFilename];
    io.mouseDoubleClickTime = _io.MouseDoubleClickTime;
    io.mouseDoubleClickMaxDist = _io.MouseDoubleClickMaxDist;
    io.mouseDragThreshold = _io.MouseDragThreshold;
    io.keyRepeatDelay = _io.KeyRepeatDelay;
    io.keyRepeatRate = _io.KeyRepeatRate;
    
    io.fontGlobalScale = _io.FontGlobalScale;
    io.FontAllowUserScaling = _io.FontAllowUserScaling;
    io.displayFramebufferScale = [self toCGSize:_io.DisplayFramebufferScale];
    io.displayVisibleMin = [self toCGPoint: _io.DisplayVisibleMin];
    io.displayVisibleMax = [self toCGPoint: _io.DisplayVisibleMax];
    
//    io.wordMovementUsesAltKey = _io.WordMovementUsesAltKey;
//    io.shortcutsUseSuperKey = _io.ShortcutsUseSuperKey;
//    io.doubleClickSelectsWord = _io.DoubleClickSelectsWord;
//    io.multiSelectUsesSuperKey = _io.MultiSelectUsesSuperKey;
    
    io.mousePos = [self toCGPoint:_io.MousePos];
    // io.mouseDown = _io.MouseDown
    io.mouseWheel = _io.MouseWheel;
    io.mouseDrawCursor = _io.MouseDrawCursor;
    io.keyCtrl = _io.KeyCtrl;
    io.keyShift = _io.KeyShift;
    io.keyAlt = _io.KeyAlt;
    io.keySuper = _io.KeySuper;
    // io.keysDown = _io.KeysDown;
    io.wantCaptureMouse = _io.WantCaptureMouse;
    io.wantCaptureKeyboard = _io.WantCaptureKeyboard;
    io.wantTextInput = _io.WantTextInput;
    io.framerate = _io.Framerate;
    io.metricsAllocs = _io.MetricsAllocs;
    io.metricsRenderVertices = _io.MetricsRenderVertices;
    io.metricsRenderIndices = _io.MetricsRenderIndices;
    io.metricsActiveWindows = _io.MetricsActiveWindows;
    
    //------------------------------------------------------------------
    // [Internal] ImGui will maintain those fields for you
    //------------------------------------------------------------------
    
    io.mousePosPrev = [self toCGPoint: _io.MousePosPrev];
    io.mouseDelta = [self toCGPoint:_io.MouseDelta];
    
    // io.mouseClicked = _io.MouseClicked;
    // io.mouseClickedPos = _io.MouseClickedPos;
    // io.mouseClickedTime = _io.MouseClickedTime;
    // io.mouseDoubleClicked = _io.MouseDoubleClicked;
    // io.mouseReleased = _io.MouseReleased;
    // io.mouseDownOwned = _io.MouseDownOwned;
    // io.mouseDownDuration = _io.MouseDownDuration;
    // io.mouseDownDurationPrev = _io.MouseDownDurationPrev;
    // io.mouseDragMaxDistanceSqr = _io.MouseDragMaxDistanceSqr;
    // io.keysDownDuration = _io.KeysDownDuration;
    // io.keysDownDurationPrev = _io.KeysDownDurationPrev;
    return io;
}

- (BOOL)inputText: (NSString *)label initialText:(char * _Nonnull) buf : (int)bufferSize : (int) flags {
    
    BOOL res = ImGui::InputText(label.UTF8String, buf, bufferSize, flags);
    // *buf = [NSString stringWithUTF8String:_buf];
    return res;
}

- (BOOL) inputTextMultiline: (NSString* _Nonnull)label initialText:(char* _Nonnull)buf : (int)bufferSize : (CGSize)size : (int) flags /*: ImGuiTextEditCallback callback = NULL, void* user_data = NULL*/
{
    BOOL res = ImGui::InputTextMultiline(label.UTF8String, buf, bufferSize, [self fromCGSize:size], flags);
    return res;
}

- (BOOL)inputInt: (NSString *)label : (int*) v : (int) step : (int)stepFast : (int)extraFlags {
    return ImGui::InputInt(label.UTF8String, v, step, stepFast, extraFlags);
}

- (BOOL)inputInt: (NSString *)label : (int *) v : (int)numComponent : (int)step : (int)stepFast : (int)extraFlags
{
    switch (numComponent) {
        case 1: return ImGui::InputInt(label.UTF8String, v, step, stepFast, extraFlags);
        case 2: return ImGui::InputInt2(label.UTF8String, v);
        case 3: return ImGui::InputInt3(label.UTF8String, v);
        case 4: return ImGui::InputInt4(label.UTF8String, v);
    }
    
    return FALSE;
}

- (BOOL)inputFloat: (NSString * _Nonnull)label : (float *_Nonnull) v : (int)numComponent : (float)step : (float)stepFast : (int)decimalPrecision : (int)extraFlags
{
    switch (numComponent) {
        case 1: return ImGui::InputFloat(label.UTF8String, v, step, stepFast, decimalPrecision, extraFlags);
        case 2: return ImGui::InputFloat2(label.UTF8String, v, extraFlags);
        case 3: return ImGui::InputFloat4(label.UTF8String, v, extraFlags);
        case 4: return ImGui::InputFloat4(label.UTF8String, v, extraFlags);
    }
    
    return FALSE;
}


// MARK: Widges

- (BOOL)dragFloat: (NSString *)label :(float *) v :(float)vMin : (float)vMax {
    return ImGui::DragFloat(label.UTF8String, v, vMin, vMax);
}

- (BOOL)dragFloat2: (NSString *)label :(float *) v :(float)vMin : (float)vMax {
    return ImGui::DragFloat(label.UTF8String, v, vMin, vMax);
}

- (void)sameLine: (float)pos_x : (float) spacing_w
{
    ImGui::SameLine(pos_x, spacing_w);
}

- (void)separator
{
    ImGui::Separator();
}

- (void)textWrapped: (NSString *)text
{
    ImGui::TextWrapped("%s", text.UTF8String);
}

- (BOOL)isMouseDoubleClicked: (int)button {
    return ImGui::IsMouseDoubleClicked(button);
}

- (void)textColored:(NSString *)text :(CGColorRef)color
{
    ImGui::TextColored([self fromCGColor: color], "%s", text.UTF8String);
}

- (void)labelText: (NSString *)label : (NSString *)format {
    ImGui::LabelText(label.UTF8String, "%s", format.UTF8String);
}

- (void)setScrollHere
{
    ImGui::SetScrollHere();
}

- (void)columns: (int)count : (NSString *)strId : (BOOL)border {
    ImGui::Columns(count, strId.UTF8String, border);
}

- (void) nextColumn
{
    ImGui::NextColumn();
}

- (void)treePush: (NSString *)_id
{
    ImGui::TreePush(_id.UTF8String);
}

//- (void)treePush: (NSString *)_id
//{
//    ImGui::TreePush(_id.UTF8String);
//}

- (BOOL)treeNode: (NSString *)label
{
    return ImGui::TreeNode(label.UTF8String);
}

- (BOOL) treeNodeWithId: (const void *)_id : (NSString * _Nonnull) label
{
    return ImGui::TreeNode(_id, "%s", label.UTF8String);
}

- (void)treePop
{
    return ImGui::TreePop();
}

- (void)end
{
    ImGui::End();
}

- (BOOL)isItemActive
{
    return ImGui::IsItemActive();
}

- (BOOL)isItemClicked
{
    return ImGui::IsItemClicked();
}

- (void)ioAddInputCharacter:(NSString *)character
{
    ImGui::GetIO().AddInputCharactersUTF8(character.UTF8String);
}

- (void)setIO
{
    ImGui::GetIO().KeysDown[ImGuiKey_Backspace] = true;
    ImGui::GetIO().KeysDownDuration[ImGui::GetIO().KeyMap[ImGuiKey_Backspace]] = 0.0f;
}

- (void)setIOReturn
{
    ImGui::GetIO().KeysDown[ImGuiKey_Enter] = true;
    ImGui::GetIO().KeysDownDuration[ImGui::GetIO().KeyMap[ImGuiKey_Enter]] = 0.0f;
}

- (void)setKeyboardDown: (int)key
{
    ImGuiIO& io = ImGui::GetIO();
    io.KeysDown[key] = true;
    io.KeysDownDuration[io.KeyMap[key]] = 0.0f;
}


@end


#pragma mark - ImGUI uSynergy Hooks

uSynergyBool ImGui_ConnectFunc(uSynergyCookie cookie)
{
    // NOTE: You need to turn off "Use SSL Encryption" in Synergy preferences, since
    // uSynergy does not support SSL.
    
    NSLog( @"Connect Func!");
    struct addrinfo hints, *res;
    
    // first, load up address structs with getaddrinfo():
    memset(&hints, 0, sizeof hints);
    hints.ai_family = AF_UNSPEC;  // use IPv4 or IPv6, whichever
    hints.ai_socktype = SOCK_STREAM;
    
    // get server address
    getaddrinfo([g_serverName UTF8String], "24800", &hints, &res);
    
    if (!res)
    {
        NSLog( @"Could not find server: %@", g_serverName );
        return USYNERGY_FALSE;
    }
    
    // make a socket:
    usynergy_sockfd = socket(res->ai_family, res->ai_socktype, res->ai_protocol);
    
    // connect it to the address and port we passed in to getaddrinfo():
    int ret = connect(usynergy_sockfd, res->ai_addr, res->ai_addrlen);
    if (!ret) {
        NSLog( @"Connect suceeded...");
    } else {
        NSLog( @"Connect failed, %d", ret );
    }
    
    
    return USYNERGY_TRUE;
}

uSynergyBool ImGui_SendFunc(uSynergyCookie cookie, const uint8_t *buffer, int length)
{
    //    NSLog( @"Send Func" );
    send( usynergy_sockfd, buffer, length, 0 );
    
    return USYNERGY_TRUE;
}

uSynergyBool ImGui_RecvFunc(uSynergyCookie cookie, uint8_t *buffer, int maxLength, int* outLength)
{
    *outLength = (int)recv( usynergy_sockfd, buffer, maxLength, 0 );
    
    return USYNERGY_TRUE;
}

void ImGui_SleepFunc(uSynergyCookie cookie, int timeMs)
{
    usleep( timeMs * 1000 );
}

uint32_t ImGui_GetTimeFunc()
{
    struct timeval  tv;
    gettimeofday(&tv, NULL);
    
    return (int32_t)((tv.tv_sec) * 1000 + (tv.tv_usec) / 1000);
}

void ImGui_TraceFunc(uSynergyCookie cookie, const char *text)
{
    puts(text);
}

void ImGui_ScreenActiveCallback(uSynergyCookie cookie, uSynergyBool active)
{
    g_synergyPtrActive = active;
    //    printf( "Synergy: screen activate %s\n", active?"YES":"NO" );
}

void ImGui_MouseCallback(uSynergyCookie cookie, uint16_t x, uint16_t y, int16_t wheelX, int16_t wheelY,
                         uSynergyBool buttonLeft, uSynergyBool buttonRight, uSynergyBool buttonMiddle)
{
    //    printf("Synergy: mouse callback %d %d -- wheel %d %d\n", x, y,  wheelX, wheelY );
    uSynergyContext *ctx = (uSynergyContext*)cookie;
    g_mousePosX = x;
    g_mousePosY = y;
    g_mouseWheelX = wheelX;
    g_mouseWheelY = wheelY;
    g_MousePressed[0] = buttonLeft;
    g_MousePressed[1] = buttonMiddle;
    g_MousePressed[2] = buttonRight;
    
    ctx->m_mouseWheelX = 0;
    ctx->m_mouseWheelY = 0;
}

void ImGui_KeyboardCallback(uSynergyCookie cookie, uint16_t key,
                            uint16_t modifiers, uSynergyBool down, uSynergyBool repeat)
{
    int scanCode = key-1;
    //    printf("Synergy: keyboard callback: 0x%02X (%s)", scanCode, down?"true":"false");
    ImGuiIO& io = ImGui::GetIO();
    io.KeysDown[key] = down;
    io.KeyShift = (modifiers & USYNERGY_MODIFIER_SHIFT);
    io.KeyCtrl = (modifiers & USYNERGY_MODIFIER_CTRL);
    io.KeyAlt = (modifiers & USYNERGY_MODIFIER_ALT);
    io.KeySuper = (modifiers & USYNERGY_MODIFIER_WIN);
    
    // Add this as keyboard input
    if ((down) && (key) && (scanCode<256) && !(modifiers & USYNERGY_MODIFIER_CTRL))
    {
        // If this key maps to a character input, apply it
        int charForKeycode = (modifiers & USYNERGY_MODIFIER_SHIFT) ? g_keycodeCharShifted[scanCode] : g_keycodeCharUnshifted[scanCode];
        io.AddInputCharacter((unsigned short)charForKeycode);
    }
    
}

void ImGui_JoystickCallback(uSynergyCookie cookie, uint8_t joyNum, uint16_t buttons, int8_t leftStickX, int8_t leftStickY, int8_t rightStickX, int8_t rightStickY)
{
    printf("Synergy: joystick callback TODO\n");
}

void ImGui_ClipboardCallback(uSynergyCookie cookie, enum uSynergyClipboardFormat format, const uint8_t *data, uint32_t size)
{
    printf("Synergy: clipboard callback TODO\n" );
}


void uSynergySetupFunctions( uSynergyContext &ctx ) {
    ctx.m_connectFunc = ImGui_ConnectFunc;
    ctx.m_sendFunc = ImGui_SendFunc;
    ctx.m_receiveFunc = ImGui_RecvFunc;
    ctx.m_sleepFunc = ImGui_SleepFunc;
    ctx.m_traceFunc = ImGui_TraceFunc;
    ctx.m_getTimeFunc = ImGui_GetTimeFunc;
    
    ctx.m_traceFunc = ImGui_TraceFunc;
    ctx.m_screenActiveCallback = ImGui_ScreenActiveCallback;
    ctx.m_mouseCallback = ImGui_MouseCallback;
    ctx.m_keyboardCallback = ImGui_KeyboardCallback;
    ctx.m_cookie = (uSynergyCookie)&ctx;
}
