//
//  ImGuiUtils.m
//  Swift-imgui
//
//  Created by Hiroaki Yamane on 1/24/17.
//  Copyright © 2017 Hiroaki Yamane. All rights reserved.
//

#import "ImGuiUtils.h"

ImVec2 ImGuiUtils::fromCGPoint(CGPoint point)
{
    return ImVec2(point.x, point.y);
}

ImVec2 ImGuiUtils::fromCGSize(CGSize size)
{
    return ImVec2(size.width, size.height);
    
}

ImColor ImGuiUtils::fromCGColor(CGColorRef color)
{
    const CGFloat* components = CGColorGetComponents(color);
    size_t numComponents = CGColorGetNumberOfComponents(color);
    if (numComponents == 2) {
        return ImVec4(components[0], components[0], components[0], components[1]);
    } else {
        return ImVec4(components[0], components[1], components[2], components[3]);
    }
    
}

CGPoint ImGuiUtils::toCGPoint(ImVec2 point)
{
    return CGPointMake(point.x, point.y);
}

CGSize ImGuiUtils::toCGSize(ImVec2 size)
{
    return CGSizeMake(size.x, size.y);
    
}
