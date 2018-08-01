//
//  ImGuiEnums.swift
//  Swift-imgui
//
//  Created by Hiroaki Yamane on 10/12/16.
//  Copyright © 2016 Hiroaki Yamane. All rights reserved.
//

public enum ImGuiStyleVar: Int32
{
	case alpha               // float
	case windowPadding       // ImVec2
	case windowRounding      // float
	case windowMinSize       // ImVec2
	case childWindowRounding // float
	case framePadding        // ImVec2
	case frameRounding       // float
	case itemSpacing         // ImVec2
	case itemInnerSpacing    // ImVec2
	case indentSpacing       // float
	case grabMinSize          // float
}



public struct ImGuiWindowFlags: OptionSet {
	
	public let rawValue: Int32
    
    public init(rawValue: ImGuiWindowFlags.RawValue) {
        self.rawValue = rawValue
    }
	
	public static let noTitleBar					= ImGuiWindowFlags(rawValue: 1 << 0)		// Disable title-bar
	public static let noResize						= ImGuiWindowFlags(rawValue: 1 << 1)		// Disable user resizing with the lower-right grip
	public static let noMove						= ImGuiWindowFlags(rawValue: 1 << 2)		// Disable user moving the window
	public static let noScrollbar					= ImGuiWindowFlags(rawValue: 1 << 3)		// Disable scrollbars (window can still scroll with mouse or programatically)
	public static let noScrollWithMouse				= ImGuiWindowFlags(rawValue: 1 << 4)		// Disable user vertically scrolling with mouse wheel
	public static let noCollapse					= ImGuiWindowFlags(rawValue: 1 << 5)		// Disable user collapsing window by double-clicking on it
	public static let alwaysAutoResize				= ImGuiWindowFlags(rawValue: 1 << 6)		// Resize every window to its content every frame
	public static let showBorders					= ImGuiWindowFlags(rawValue: 1 << 7)		// Show borders around windows and items
	public static let noSavedSettings				= ImGuiWindowFlags(rawValue: 1 << 8)		// Never load/save settings in .ini file
	public static let noInputs						= ImGuiWindowFlags(rawValue: 1 << 9)		// Disable catching mouse or keyboard inputs
	public static let menuBar						= ImGuiWindowFlags(rawValue: 1 << 10)		// Has a menu-bar
	public static let horizontalScrollbar			= ImGuiWindowFlags(rawValue: 1 << 11)		// Allow horizontal scrollbar to appear (off by default). You may use SetNextWindowContentSize(ImVec2(width,0.0f)); prior to calling Begin() to specify width. Read code in imgui_demo in the "Horizontal Scrolling" section.
	public static let noFocusOnAppearing			= ImGuiWindowFlags(rawValue: 1 << 12)		// Disable taking focus when transitioning from hidden to visible state
	public static let noBringToFrontOnFocus			= ImGuiWindowFlags(rawValue: 1 << 13)		// Disable bringing window to front when taking focus (e.g. clicking on it or programatically giving it focus)
	public static let alwaysVerticalScrollbar		= ImGuiWindowFlags(rawValue: 1 << 14)		// Always show vertical scrollbar (even if ContentSize.y < Size.y)
	public static let alwaysHorizontalScrollbar 	= ImGuiWindowFlags(rawValue: 1 << 15)		// Always show horizontal scrollbar (even if ContentSize.x < Size.x)
	public static let alwaysUseWindowPadding 		= ImGuiWindowFlags(rawValue: 1 << 16)		// Ensure child windows without border uses style.WindowPadding (ignored by default for non-bordered child windows, because more convenient)
	
	public static let childWindow					= ImGuiWindowFlags(rawValue: 1 << 20)		// Don't use! For internal use by BeginChild()
	public static let childWindowAutoFitX			= ImGuiWindowFlags(rawValue: 1 << 21)		// Don't use! For internal use by BeginChild()
	public static let childWindowAutoFitY			= ImGuiWindowFlags(rawValue: 1 << 22)		// Don't use! For internal use by BeginChild()
	public static let comboBox						= ImGuiWindowFlags(rawValue: 1 << 23)		// Don't use! For internal use by ComboBox()
	public static let tooltip						= ImGuiWindowFlags(rawValue: 1 << 24)		// Don't use! For internal use by BeginTooltip()
	public static let popup							= ImGuiWindowFlags(rawValue: 1 << 25)		// Don't use! For internal use by BeginPopup()
	public static let modal							= ImGuiWindowFlags(rawValue: 1 << 26)		// Don't use! For internal use by BeginPopupModal()
	public static let childMenu						= ImGuiWindowFlags(rawValue: 1 << 27)		// Don't use! For internal use by BeginMenu()
}

public struct ImGuiSelectableFlags: OptionSet {
	
	public let rawValue: Int32
    
    public init(rawValue: ImGuiSelectableFlags.RawValue) {
        self.rawValue = rawValue
    }
	
	public static let dontClosePopups    = ImGuiSelectableFlags(rawValue: 1 << 0)   // Clicking this don't close parent popup window
	public static let spanAllColumns     = ImGuiSelectableFlags(rawValue: 1 << 1)   // Selectable frame can span all columns (text will still fit in current column)
	public static let allowDoubleClick   = ImGuiSelectableFlags(rawValue: 1 << 2)   // Generate press events on double clicks too
}

public struct ImGuiInputTextFlags: OptionSet {
	
	public let rawValue: Int32
    
    public init(rawValue: ImGuiInputTextFlags.RawValue) {
        self.rawValue = rawValue
    }
	
	public static let charsDecimal        = ImGuiInputTextFlags(rawValue: 1 << 0)   // Allow 0123456789.+-*/
	public static let charsHexadecimal    = ImGuiInputTextFlags(rawValue: 1 << 1)   // Allow 0123456789ABCDEFabcdef
	public static let charsUppercase      = ImGuiInputTextFlags(rawValue: 1 << 2)   // Turn a..z into A..Z
	public static let charsNoBlank        = ImGuiInputTextFlags(rawValue: 1 << 3)   // Filter out spaces, tabs
	public static let autoSelectAll       = ImGuiInputTextFlags(rawValue: 1 << 4)   // Select entire text when first taking mouse focus
	public static let enterReturnsTrue    = ImGuiInputTextFlags(rawValue: 1 << 5)   // Return 'true' when Enter is pressed (as opposed to when the value was modified)
	public static let callbackCompletion  = ImGuiInputTextFlags(rawValue: 1 << 6)   // Call user function on pressing TAB (for completion handling)
	public static let callbackHistory     = ImGuiInputTextFlags(rawValue: 1 << 7)   // Call user function on pressing Up/Down arrows (for history handling)
	public static let callbackAlways      = ImGuiInputTextFlags(rawValue: 1 << 8)   // Call user function every time. User code may query cursor position, modify text buffer.
	public static let callbackCharFilter  = ImGuiInputTextFlags(rawValue: 1 << 9)   // Call user function to filter character. Modify data->EventChar to replace/filter input, or return 1 to discard character.
	public static let allowTabInput       = ImGuiInputTextFlags(rawValue: 1 << 10)  // Pressing TAB input a '\t' character into the text field
	public static let ctrlEnterForNewLine = ImGuiInputTextFlags(rawValue: 1 << 11)  // In multi-line mode, allow exiting edition by pressing Enter. Ctrl+Enter to add new line (by default adds new lines with Enter).
	public static let noHorizontalScroll  = ImGuiInputTextFlags(rawValue: 1 << 12)  // Disable following the cursor horizontally
	public static let alwaysInsertMode    = ImGuiInputTextFlags(rawValue: 1 << 13)  // Insert mode
	public static let readOnly            = ImGuiInputTextFlags(rawValue: 1 << 14)  // Read-only mode
	public static let password            = ImGuiInputTextFlags(rawValue: 1 << 15)  // Password mode, display all characters as '*'
	// [Internal]
	static let multiline           = ImGuiInputTextFlags(rawValue: 1 << 20)   // For internal use by InputTextMultiline()
}


public struct ImGuiSetCond: OptionSet
{
	
	public let rawValue: Int32
    
    public init(rawValue: ImGuiSetCond.RawValue) {
        self.rawValue = rawValue
    }
	
	public static let always        = ImGuiSetCond(rawValue: 1 << 0) // Set the variable
	public static let once          = ImGuiSetCond(rawValue: 1 << 1) // Only set the variable on the first call per runtime session
	public static let firstUseEver  = ImGuiSetCond(rawValue: 1 << 2) // Only set the variable if the window doesn't exist in the .ini file
	public static let appearing     = ImGuiSetCond(rawValue: 1 << 3) // Only set the variable if the window is appearing after being inactive (or the first time)
};


public enum ImGuiColor: Int32
{
	case text
	case textDisabled
	case windowBg              // Background of normal windows
	case childWindowBg         // Background of child windows
	case popupBg               // Background of popups menus tooltips windows
	case border
	case borderShadow
	case frameBg               // Background of checkbox radio button plot slider text input
	case frameBgHovered
	case frameBgActive
	case titleBg
	case titleBgCollapsed
	case titleBgActive
	case menuBarBg
	case scrollbarBg
	case scrollbarGrab
	case scrollbarGrabHovered
	case scrollbarGrabActive
	case comboBg
	case checkMark
	case sliderGrab
	case sliderGrabActive
	case button
	case buttonHovered
	case buttonActive
	case header
	case headerHovered
	case headerActive
	case column
	case columnHovered
	case columnActive
	case resizeGrip
	case resizeGripHovered
	case resizeGripActive
	case closeButton
	case closeButtonHovered
	case closeButtonActive
	case plotLines
	case plotLinesHovered
	case plotHistogram
	case plotHistogramHovered
	case textSelectedBg
	case modalWindowDarkening  // darken entire screen when a modal window is active
}


public enum ImGuiColorEditMode: Int32
{
	case userSelect = -2
	case userSelectShowButton = -1
	case rgb = 0
	case hsv = 1
	case hex = 2
};

public enum ImGuiKey: Int32
{
	case tab       // for tabbing through fields
	case leftArrow // for text edit
	case rightArrow// for text edit
	case upArrow   // for text edit
	case downArrow // for text edit
	case pageUp
	case pageDown
	case home      // for text edit
	case end       // for text edit
	case delete    // for text edit
	case backspace // for text edit
	case enter     // for text edit
	case escape    // for text edit
	case a         // for text edit CTRL+A: select all
	case c         // for text edit CTRL+C: copy
	case v         // for text edit CTRL+V: paste
	case x         // for text edit CTRL+X: cut
	case y         // for text edit CTRL+Y: redo
	case z         // for text edit CTRL+Z: undo
	case count
};

