//
//  ImGuiViewController.swift
//  Swift-imgui
//
//  Created by Hiroaki Yamane on 1/24/17.
//  Copyright © 2017 Hiroaki Yamane. All rights reserved.
//

import Foundation

#if os(OSX)
import Cocoa
#else
import UIKit
#endif


protocol ImGuiViewControllerBase {
    var drawBlocks: [ImGuiDrawCallback] { get set }
    func addDrawBlock(block: ImGuiDrawCallback)
}

extension ImGuiViewControllerBase {
    mutating func addDrawBlock(block: @escaping ImGuiDrawCallback) {
        drawBlocks.append(block)
    }
}
