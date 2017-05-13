//
//  ImGuiUtils.h
//  Swift-imgui
//
//  Created by Hiroaki Yamane on 1/24/17.
//  Copyright © 2017 Hiroaki Yamane. All rights reserved.
//

#include <CoreGraphics/CoreGraphics.h>

#include "imgui/imgui.h"

class ImGuiUtils {
public:
    static ImVec2 fromCGPoint(CGPoint point);
    static ImVec2 fromCGSize(CGSize size);
    static ImColor fromCGColor(CGColorRef color);
    static CGPoint toCGPoint(ImVec2 point);
    static CGSize toCGSize(ImVec2 size);
};
