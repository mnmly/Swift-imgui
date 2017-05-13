//
//  ImGuiViewControllerProtocol.swift
//  Swift-imgui
//
//  Created by Hiroaki Yamane on 5/13/17.
//  Copyright © 2017 Hiroaki Yamane. All rights reserved.
//

import Foundation


public protocol ImGuiViewControllerProtocol {
    var drawBlocks: [ImGuiDrawCallback] { get set }
}
