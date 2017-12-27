#pragma once

#include <Foundation/Foundation.h>

#if TARGET_OS_IPHONE
#include <UIKit/UIKit.h>
#else
#include <AppKit/AppKit.h>
#endif

typedef BOOL (^ ComboItemGetter)(const void * _Nullable data, int idx, const char* _Nullable * _Nullable outText);
typedef float (*PlotValuesGetter)(void * _Nullable, int);
typedef unsigned int ImGuiID;
typedef void* ImTextureID;


#if TARGET_OS_IPHONE
@interface ImGuiWrapperBase : NSObject<UIGestureRecognizerDelegate>
- (instancetype _Nonnull)initWithView: (UIView * _Nonnull)view;
- (void) setupGestures: (UIView * _Nonnull) view;

#else
@interface ImGuiWrapperBase : NSObject
- (instancetype _Nonnull)initWithView: (NSView * _Nonnull)view;
- (void) setupGestures: (NSView * _Nonnull) view;
#endif

- (void) setupRenderDrawLists;
- (void) setupImGuiHooks;
- (void) setupImGuiHooks: (NSString * _Nullable)fontPath;
- (void) setupMouse;
- (void) loadFontFile: (NSString * _Nonnull)fontPath;
- (void) reloadFontTexture;

- (void) connectServer: (NSString * _Nonnull)serverName;
- (void) setViewport: (CGSize)size : (CGFloat)scale;
- (void) render;
- (void) begin: (NSString * _Nonnull)name : (BOOL* _Nullable)show : (int)flags;
- (void) end;
- (BOOL) beginChild: (NSString * _Nonnull)strId : (CGSize)sizeArg : (BOOL)border : (int)extraFlags; /*, ImGuiWindowFlags extra_flags)*/
- (void) endChild;

- (CGPoint) getContentRegionMax;
- (CGPoint) getContentRegionAvail;
- (float) getContentRegionAvailWidth;
- (CGPoint) getWindowContentRegionMin;
- (CGPoint) getWindowContentRegionMax;
- (float) getWindowContentRegionWidth;
- (CGPoint) getWindowPos;
- (CGSize) getWindowSize;
- (float) getWindowWidth;
- (float) getWindowHeight;
- (bool) isWindowCollapsed;
- (void) setWindowFontScale: (float)scale;

- (void) setNextWindowPos: (CGPoint)pos : (int) cond; /*ImGuiSetCond*/
- (void) setNextWindowPosCenter: (int) cond; /*ImGuiSetCond*/
- (void) setNextWindowSize: (CGSize)size : (int) cond; /*ImGuiSetCond*/
- (void) setNextWindowContentSize: (CGSize) size;
- (void) setNextWindowContentWidth: (float) width;
- (void) setNextWindowCollapsed: (BOOL) collapsed : (int) cond; /*ImGuiSetCond*/
- (void) setNextWindowFocus;
- (void) setWindowPos: (CGPoint)pos : (int) cond; /*ImGuiSetCond*/
- (void) setWindowSize: (CGSize) size : (int) cond; /*ImGuiSetCond*/
- (void) setWindowCollapsed: (BOOL) collapsed : (int) cond; /*ImGuiSetCond*/
- (void) setWindowFocus;
- (void) setWindowPos: (NSString * _Nonnull) name : (CGPoint)pos : (int) cond;  /*ImGuiSetCond*/
- (void) setWindowSize: (NSString* _Nonnull) name : (CGSize)size : (int) cond;
- (void) setWindowCollapsed: (NSString * _Nonnull)name : (BOOL)collapsed : (int)cond;
- (void) setWindowFocus: (NSString* _Nonnull) name;

- (float) getScrollX;
- (float) getScrollY;
- (float) getScrollMaxX;
- (float) getScrollMaxY;
- (void) setScrollX: (float) scrollX;
- (void) setScrollY: (float) scrollY;
- (void) setScrollHere: (float) centerYRatio; // = 0.5f);
- (void) setScrollFromPosY: (float) posY : (float) centerYRatio; // = 0.5f);
- (void) setKeyboardFocusHere: (int) offset; // = 0);
// - (void) setStateStorage(ImGuiStorage* tree);                                // replace tree state storage with our own (if you want to manipulate it yourself, typically clear subsection of it)
// - (ImGuiStorage* GetStateStorage();

- (BOOL) inputText: (NSString * _Nonnull)label initialText:(char * _Nonnull) buf : (int)bufferSize : (int) flags;
- (BOOL) inputTextMultiline: (NSString* _Nonnull)label
               initialText : (char* _Nonnull)buf
                           : (int)bufferSize
                           : (CGSize)size
                           : (int) flags /*: ImGuiTextEditCallback callback = NULL, void* user_data = NULL*/;


// Parameters stacks (current window)
- (void) pushItemWidth: (float) itemWidth;
- (void) popItemWidth;
- (float) calcItemWidth;
- (void) pushTextWrapPos: (float) wrapPosX;
- (void) popTextWrapPos;
- (void) pushAllowKeyboardFocus: (BOOL)v;
- (void) popAllowKeyboardFocus;
- (void) pushButtonRepeat: (BOOL) repeat;
- (void) popButtonRepeat;

// Cursor / Layout
- (void) beginGroup;
- (void) endGroup;
- (void) separator;
- (void) sameLine: (float)pos_x : (float) spacing_w;
- (void) spacing;
- (void) dummy: (CGSize)size;
- (void) indent;
- (void) unindent;
- (CGPoint) getCursorPos;
- (float) getCursorPosX;
- (float) getCursorPosY;
- (void) setCursorPos: (CGPoint) localPos;
- (void) setCursorPosX: (float) x;
- (void) setCursorPosY: (float) y;
- (CGPoint) getCursorStartPos;
- (CGPoint) getCursorScreenPos;
- (void) setCursorScreenPos: (CGPoint) pos;
- (void) alignFirstTextHeightToWidgets;
- (float) getTextLineHeight;
- (float) getTextLineHeightWithSpacing;
- (float) getItemsLineHeightWithSpacing;

// Columns
// You can also use SameLine(pos_x) for simplified columning. The columns API is still work-in-progress.
- (void) columns: (int)count : (NSString * _Nullable)strId : (BOOL)border;
- (void) nextColumn;
- (int) getColumnIndex;
- (float) getColumnOffset: (int) columnIndex;
- (void) setColumnOffset: (int) columnIndex : (float) offsetX;                  // set position of column line (in pixels, from the left side of the contents region). pass -1 to use current column
- (float) getColumnWidth: (int) columnIndex;
- (int) getColumnsCount;

// ID scopes
// If you are creating widgets in a loop you most likely want to push a unique identifier so ImGui can differentiate them.
// You can also use the "##foobar" syntax within widget label to distinguish them from each others. Read "A primer on the use of labels/IDs" in the FAQ for more details.
- (void)pushIDWithInt: (int)_id;
- (void)pushIDWithString: (NSString * _Nonnull)_id;
- (void)pushIDWithIdBegin: (NSString * _Nonnull) idBegin idEnd: (NSString * _Nonnull)_idEnd;
- (void)popID;

- (ImGuiID) getIDWithStrId: (NSString * _Nonnull)strId;                                          // calculate unique ID (hash of whole ID stack + given parameter). useful if you want to query into ImGuiStorage yourself. otherwise rarely needed
- (ImGuiID) getIDWithBeginAndEnd: (NSString * _Nonnull) idDBegin : (NSString * _Nonnull) idEnd;
- (ImGuiID) getIDWithPointer: (const void* _Nonnull) ptrId;

// Widgets
- (void) text: (NSString * _Nonnull) label;
- (void) textV: (NSString * _Nonnull) label;
- (void) textColored: (NSString * _Nonnull)text : (CGColorRef _Nonnull)color;
- (void) textColoredV: (NSString * _Nonnull)text : (CGColorRef _Nonnull)color;
- (void) textDisabled: (NSString * _Nonnull) label;
- (void) textDisabledV: (NSString * _Nonnull) label;
- (void) textWrapped: (NSString * _Nonnull)text;
- (void) textWrappedV: (NSString * _Nonnull)text;
- (void) textUnformatted: (NSString* _Nonnull)text : (NSString * _Nullable)textEnd;
- (void) labelText: (NSString * _Nonnull) label : (NSString * _Nonnull)format;
- (void) labelTextV: (NSString * _Nonnull) label : (NSString * _Nonnull)format;
- (void) bullet;                                                               // draw a small circle and keep the cursor on the same line. advance you by the same distance as an empty TreeNode() call.
- (void) bulletText: (NSString * _Nonnull)text;
- (void) bulletTextV: (NSString * _Nonnull)text;
- (BOOL) button: (NSString * _Nonnull) label : (CGSize)size;
- (BOOL) smallButton: (NSString * _Nonnull) label;
- (BOOL) invisibleButton: (NSString * _Nonnull) label : (CGSize)size;

//#if TARGET_IPHONE_SIMULATOR
//- (void) image: (GLuint) userTextureID : (CGSize)size : (CGPoint) uv0 : (CGPoint) uv1 : (CGColorRef _Nonnull) tintColor : (CGColorRef _Nonnull) borderColor;
//#else
//- (void) image: (id<MTLTexture> _Nonnull) userTextureID : (CGSize)size : (CGPoint) uv0 : (CGPoint) uv1 : (CGColorRef _Nonnull) tintColor : (CGColorRef _Nonnull) borderColor;
//#endif

// - (bool) imageButton(ImTextureID user_texture_id, const ImVec2& size, const ImVec2& uv0 = ImVec2(0,0),  const ImVec2& uv1 = ImVec2(1,1), int frame_padding = -1, const ImVec4& bg_col = ImVec4(0,0,0,0), const ImVec4& tint_col = ImVec4(1,1,1,1));    // <0 frame_padding uses default frame padding settings. 0 for no padding
- (BOOL) collapsingHeader: (NSString * _Nonnull) label : (NSString * _Nullable) strID : (BOOL) displayFrame : (BOOL)defaultOpen;
- (BOOL) checkbox: (NSString * _Nonnull) label :(BOOL * _Nonnull)active;
// - (BOOL) checkboxFlags: (NSString * _Nonnull) label : unsigned int* flags, unsigned int flags_value);
- (BOOL) radioButton: (NSString * _Nonnull) label :(BOOL)active;
- (BOOL) radioButtonVButton: (NSString * _Nonnull) label : (int* _Nonnull) v : (int)vButton;


- (BOOL) combo: (NSString * _Nonnull) label :(int * _Nonnull)currentItem : (NSArray<NSString *> * _Nonnull)items : (int)heightInItems /*=-1*/;
- (BOOL) combo: (NSString * _Nonnull) label : (int * _Nonnull) currentItem : (ComboItemGetter _Nonnull)itemGetter : (void * _Nullable) data : (int) items_count : (int) height_in_items;
- (BOOL) colorButton:(CGColorRef _Nonnull) color : (BOOL)smallHeight : (BOOL) outlineBorder;
- (BOOL) colorEdit: (NSString * _Nonnull)label :(float * _Nonnull)color;
- (void) plotLines: (NSString * _Nonnull) label :(const float * _Nonnull) values : (int) valueCount :(int)valuesOffset : (NSString * _Nullable) overlayText :(float)minScale : (float)maxScale : (CGSize)graphSize : (int)stride;
- (void) plotLinesGetter: (NSString * _Nonnull) label :(PlotValuesGetter _Nonnull) valuesGetter : (void* _Nullable) data : (int) valuesCount :(int)valuesOffset : (NSString * _Nullable) overlayText :(float)minScale : (float)maxScale : (CGSize)graphSize;
// - (void) plotHistogram(const char* label, const float* values, int values_count, int values_offset = 0, const char* overlay_text = NULL, float scale_min = FLT_MAX, float scale_max = FLT_MAX, ImVec2 graph_size = ImVec2(0,0), int stride = sizeof(float));
- (void) plotHistogram: (NSString * _Nonnull) label :(const float * _Nonnull) values : (int) valueCount : (int)valuesOffset /*=0*/ : (NSString * _Nullable)overlayText : (float)scaleMin : (float) scaleMax : (CGSize)graphSize : (int)stride;
- (void) plotHistogramGetter: (NSString * _Nonnull) label :(PlotValuesGetter _Nonnull) valuesGetter : (void* _Nullable) data : (int) valuesCount :(int)valuesOffset : (NSString * _Nullable) overlayText :(float)minScale : (float)maxScale : (CGSize)graphSize;
- (void) progressBar: (float)progress : (CGPoint)position : (NSString * _Nullable)overlay;

// Widgets: Drags (tip: ctrl+click on a drag box to input with keyboard. manually input values aren't clamped, can go off-bounds)
- (BOOL) dragFloat: (NSString * _Nonnull) label : (float * _Nonnull)v : (int)numComponent : (float)vSpeed : (float)vMin : (float)vMax : (NSString * _Nonnull)displayFormat : (float)power;
- (BOOL) dragFloatRange2: (NSString * _Nonnull) label : (float * _Nonnull)vCurrentMin : (float * _Nonnull)vCurrentMax : (float)vSpeed : (float)vMin : (float)vMax : (NSString * _Nonnull) displayFormat : (NSString * _Nullable)displayFormatMax : (float)power;
- (BOOL) dragInt: (NSString * _Nonnull) label : (int * _Nonnull)v : (int)numComponent : (float)vSpeed : (int)vMin : (int)vMax : (NSString * _Nonnull)displayFormat;
- (BOOL) dragIntRange2: (NSString * _Nonnull) label : (int * _Nonnull)vCurrentMin : (int * _Nonnull)vCurrentMax : (float)vSpeed : (int)vMin : (int)vMax : (NSString * _Nonnull)displayFormat : (NSString * _Nullable)displayFormatMax;

- (BOOL)inputInt: (NSString * _Nonnull)label : (int * _Nonnull) v : (int)numComponent : (int)step : (int)stepFast : (int)extraFlags;
- (BOOL)inputFloat: (NSString * _Nonnull)label : (float *_Nonnull) v : (int)numComponent : (float)step : (float)stepFast : (int)decimalPrecision : (int)extraFlags;

// Widgets: Sliders (tip: ctrl+click on a slider to input with keyboard. manually input values aren't clamped, can go off-bounds)
- (BOOL) sliderFloat: (NSString * _Nonnull) label : (float * _Nonnull) v : (int)numComponent : (float)vMin : (float)vMax : (NSString * _Nonnull)displayFormat : (float)power;
- (BOOL) sliderAngle: (NSString * _Nonnull) label : (float * _Nonnull) rad : (float)vDegreeMin : (float)vDegreeMax;
- (BOOL) sliderInt: (NSString * _Nonnull) label : (int * _Nonnull) v : (int)numComponent : (int)vMin : (int)vMax : (NSString * _Nonnull)displayFormat;
- (BOOL) vSliderFloat: (NSString * _Nonnull) label : (CGSize)size : (float * _Nonnull) v : (float)vMin : (float)vMax : (NSString * _Nonnull)displayFormat : (float)power;
- (BOOL) vSliderInt: (NSString * _Nonnull) label : (CGSize)size : (int * _Nonnull) v : (int)vMin : (int)vMax : (NSString * _Nonnull)displayFormat;

// Widgets: Trees
- (BOOL) treeNode: (NSString * _Nonnull) label;
- (BOOL) treeNodeWithId: (const void * _Nonnull)_id : (NSString * _Nonnull) label;
// - (bool) treeNode(const void* ptr_id, const char* fmt, ...) IM_PRINTFARGS(2);    // "
- (bool) treeNodeV: (NSString * _Nonnull) label;
- (void) treePush: (NSString * _Nonnull)strId;
- (void) treePushWithPointer: (const void* _Nullable)pointer;
- (void) treePop;
- (void) setNextTreeNodeOpened: (BOOL) opened : (int)cond /*ImGuiSetCond */;

// Widgets: Selectable / Lists
- (BOOL) selectable: (NSString * _Nonnull) label :(BOOL) selected : (int)flags : (CGSize)size;
- (BOOL) selectablePointer: (NSString * _Nonnull) label :(BOOL * _Nonnull) selected : (int)flags : (CGSize)size;
- (BOOL) listBox: (NSString * _Nonnull) label :(int * _Nonnull)currentItem : (NSArray<NSString *> *_Nonnull)items : (int)heightInItems;
// - (bool) listBox(const char* label, int* current_item, bool (*items_getter)(void* data, int idx, const char** out_text), void* data, int items_count, int height_in_items = -1);
- (BOOL) listBoxHeader: (NSString * _Nonnull) label withItemsCount:(int)itemsCount withHeightInItems: (int)heightInItems;
- (BOOL) listBoxHeader: (NSString * _Nonnull) label withSize:(CGSize)size;
- (void) listBoxFooter;

// Widgets: Value() Helpers. Output single value in "name: value" format (tip: freely declare more in your code to handle your types. you can add functions to the ImGui namespace)
- (void) valueBool: (NSString * _Nonnull)prefix : (BOOL) b;
- (void) valueInt: (NSString * _Nonnull)prefix : (int) v;
- (void) valueUInt: (NSString * _Nonnull)prefix : (unsigned int) v;
- (void) valueFloat: (NSString * _Nonnull)prefix : (float) v : (NSString * _Nullable)floatFormat;
- (void) valueColor: (NSString * _Nonnull)prefix : (CGColorRef _Nonnull) color;

- (void) showStyleEditor;

- (void) logButtons;

// Tooltips
- (void)setTooltip: (NSString * _Nonnull)text;
- (void)setTooltipV: (NSString * _Nonnull)text;
- (void)beginTooltip;
- (void)endTooltip;


// Menus
-(BOOL) beginMainMenuBar;
-(void) endMainMenuBar;
-(BOOL) beginMenuBar;
-(void) endMenuBar;
-(BOOL) beginMenu: (NSString * _Nonnull) label : (BOOL)enabled/* = true */;
-(void) endMenu;
-(BOOL) menuItem: (NSString * _Nonnull) label : (NSString * _Nullable)shortcut : (BOOL) selected/* = false*/ : (BOOL)enabled/* = true*/;
-(BOOL) menuItemPointer: (NSString * _Nonnull) label : (NSString * _Nonnull)shortcut : (BOOL* _Nonnull) pSelected : (BOOL)enabled/*= true*/;              // return true when activated + toggle (*p_selected) if p_selected != NULL

// Popups
-(void) openPopup: (NSString * _Nonnull) strId;
-(BOOL) beginPopup: (NSString * _Nonnull)strId;
-(BOOL) beginPopupModal: (NSString * _Nonnull)name : (BOOL * _Nullable)opened;
-(BOOL) beginPopupContextItem: (NSString * _Nonnull)strId : (int)mouseButton;
-(BOOL) beginPopupContextWindow : (BOOL) alsoOverItems : (NSString * _Nullable)strId : (int) mouseButton;
-(BOOL) beginPopupContextVoid: (NSString * _Nullable)strId : (int)mouseButton;
-(void) endPopup;
-(void) closeCurrentPopup;

// Logging

// Utilities

- (BOOL) isItemHovered;
- (BOOL) isItemHoveredRect;
- (BOOL) isItemClicked;
- (BOOL) isItemActive;
- (BOOL) isItemVisible;
- (BOOL) isAnyItemHovered;
- (BOOL) isAnyItemActive;
- (CGPoint) getItemRectMin;
- (CGPoint) getItemRectMax;
- (CGSize) getItemRectSize;
- (void) setItemAllowOverlap;
- (BOOL) isWindowHovered;
- (BOOL) isWindowFocused;
- (BOOL) isRootWindowFocused;
- (BOOL) isRootWindowOrAnyChildFocused;
- (BOOL) isRectVisible: (CGSize)size;
- (BOOL) isPosHoveringAnyWindow: (CGPoint)pos;
- (float) getTime;
- (int) getFrameCount;
- (NSString* _Nonnull) getStyleColName: (int /*(ImGuiCol*/) idx;
- (CGPoint) calcItemRectClosestPoint: (CGPoint)pos : (bool) onEdge : (float)outward;
- (CGSize) calcTextSize: (NSString* _Nonnull) text : (NSString* _Nullable) textEnd : (BOOL) hideTextAfterDoubleHash/* = false*/ : (float) wrapWidth/* = -1.0f)*/;
- (void) calcListClipping: (int)itemsCount : (float) itemsHeight :(int* _Nonnull) outItemsDisplayStart : (int* _Nonnull) outItemsDisplayEnd;

// Inputs

-(int) getKeyIndex: (int /*ImGuiKey*/)key;
-(BOOL) isKeyDown: (int) keyIndex;                                           // key_index into the keys_down[] array, imgui doesn't know the semantic of each entry, uses your own indices!
-(BOOL) isKeyPressed: (int) key_index : (BOOL) repeat/* = true*/;                    // uses user's key indices as stored in the keys_down[] array. if repeat=true. uses io.KeyRepeatDelay / KeyRepeatRate
-(BOOL) isKeyReleased: (int) key_index;
-(BOOL) isMouseDown: (int) button;
-(BOOL) isMouseClicked: (int) button : (BOOL) repeat/* = false)*/;                    // did mouse button clicked (went from !Down to Down)
-(BOOL) isMouseDoubleClicked: (int) button;                                   // did mouse button double-clicked. a double-click returns false in IsMouseClicked(). uses io.MouseDoubleClickTime.
-(BOOL) isMouseReleased: (int) button;
-(BOOL) isMouseHoveringWindow;
-(BOOL) isMouseHoveringAnyWindow;
-(BOOL) isMouseHoveringRect: (CGRect)rect : (BOOL) clip/* = true)*/;  // is mouse hovering given bounding rect (in screen space). clipped by current clipping settings. disregarding of consideration of focus/window ordering/blocked by a popup.
-(BOOL) isMouseDragging: (int) button/* = 0,*/ : (float) lock_threshold/* = -1.0f)*/;      // is mouse dragging. if lock_threshold < -1.0f uses io.MouseDraggingThreshold
-(CGPoint) getMousePos;
-(CGPoint) getMousePosOnOpeningCurrentPopup;
-(CGPoint) getMouseDragDelta: (int) button/* = 0*/ : (float) lockThreshold/*= -1.0f)*/;    // dragging amount since clicking. if lock_threshold < -1.0f uses io.MouseDraggingThreshold
-(void) resetMouseDragDelta: (int) button;/* = 0)*/                                //
-(int/*ImGuiMouseCursor*/) getMouseCursor;
-(void) setMouseCursor: (int/*ImGuiMouseCursor*/) type;
-(void) captureKeyboardFromApp: (BOOL)capture/* = true*/;                        // manually override io.WantCaptureKeyboard flag next frame (said flag is entirely left for your application handle). e.g. force capture keyboard when your widget is being hovered.
-(void) captureMouseFromApp: (BOOL)capture/* = true)*/;                           // manually override io.WantCaptureMouse flag next frame (said flag is entirely left for your application handle).

- (BOOL) isMouseDragging;

- (float) deltaTime;

- (id _Nonnull) getStyle;
- (id _Nonnull) getIO;

- (void) setScrollHere;

- (void) addRect: (CGRect)rect : (CGColorRef _Nonnull)color : (float)rounding : (int)roundingCorners;
- (void) addRectFilled: (CGRect)rect : (CGColorRef _Nonnull)color : (float)rounding : (int)roundingCorners;
- (void) addRectFilledMultiColor: (CGRect)rect : (CGColorRef _Nonnull) colorUpperLeft : (CGColorRef _Nonnull)colorUpperRight : (CGColorRef _Nonnull)colorBottomRight : (CGColorRef _Nonnull)colorBottomLeft;
- (void) addText: (NSString * _Nonnull)text : (CGPoint)pos :(CGColorRef _Nonnull)color;

- (void) pushStyleVar: (int)idx withFloat:(float)val;
- (void) pushStyleVar: (int)idx withPoint: (CGPoint)val;
- (void) popStyleVar: (int)count;

- (void) pushStyleColor: (int)idx withColor:(CGColorRef _Nonnull)color;
- (void) popStyleColor: (int)count;

- (void) ioAddInputCharacter: (NSString * _Nonnull)character;
- (void) setIO;
- (void) setKeyboardDown: (int)key;

- (void) setIOReturn;

@end
