#  Swift-Imgui

*WIP*

```Swift
ImGui.initialize(.metal)

if let vc = ImGui.vc {
    addChildViewController(vc)
    vc.view.frame = view.frame
    view.addSubview(vc.view)
}

ImGui.draw { (imgui) in
    imgui.begin(name: "Hello ImGui")
    if imgui.button(label: "Click me") {
        Swift.print("you clicked me.")
    }
    imgui.end()
}
```

