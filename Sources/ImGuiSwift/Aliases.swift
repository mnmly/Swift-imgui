//
//  Aliases.swift
//  Swift-imgui
//
//  Created by Hiroaki Yamane on 1/25/17.
//  Copyright © 2017 Hiroaki Yamane. All rights reserved.
//


#if os(OSX)
import Cocoa
    
public typealias ViewAlias = NSView
public typealias ImageAlias = NSImage
public typealias ColorAlias = NSColor
public typealias ViewControllerAlias = NSViewController
    
#else
    
import UIKit
public typealias ViewAlias = UIView
public typealias ImageAlias = UIImage
public typealias ColorAlias = UIColor
public typealias ViewControllerAlias = UIViewController
    
#endif

public typealias ImGuiDrawCallback = (ImGuiBase) -> Void
