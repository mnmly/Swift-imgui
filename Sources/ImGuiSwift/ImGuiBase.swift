
//
//  ImGUIiOS.swift
//  Swift-imgui
//
//  Created by Hiroaki Yamane on 10/6/16.
//  Copyright © 2016 Hiroaki Yamane. All rights reserved.
//

import Foundation
import SceneKit

#if targetEnvironment(simulator)
import GLKit
#else
import MetalKit
#endif

//import SpriteKit

#if os(OSX)
import Cocoa
#else
import UIKit
#endif

import Darwin // FLT_MAX / FLT_MIN

public class ImGuiBase {
    
	var io: ImGuiIOBridge!
	var view: ViewAlias!
    var imguiWrapper: ImGuiWrapperBase!
    
    #if !os(OSX)
	var input: InputTextButton!
    #endif
    
    public func render() {
		imguiWrapper.render()
    }
    
	public func setup() {
        io = imguiWrapper.getIO() as? ImGuiIOBridge
		
		#if os(iOS)
		input = InputTextButton()
		view.addSubview(input.textField)
		#endif
	}
	
	public func setupGestures(view: ViewAlias) {
		imguiWrapper.setupGestures(view);
        if let v = view as? SCNView {
            if v.showsStatistics { print("You can't stats along with ImGui.") }
        }
	}
    
    public func loadFont(fontName: String) {
        let path = Bundle.main.path(forResource: fontName, ofType: "ttf")
        if path != nil {
            imguiWrapper.loadFontFile(path!)
        } else {
            print("'\(fontName).ttf' was not found in bundle.")
        }
    }
	
	public func getIO() -> ImGuiIOBridge {
		return io
	}
	
	public func setIO(){
		return imguiWrapper.setIO();
	}
	
	public func setIOReturn(){
		return imguiWrapper.setIOReturn();
	}
	
	public func setKeyboardPress(key: ImGuiKey) {
		imguiWrapper.setKeyboardDown(key.rawValue)
	}
    
	public func setViewport(size: CGSize, scale: CGFloat) {
		imguiWrapper.setViewport(size, scale)
	}
	
	
	// MARK: ImGUI API
	public func setNextWindowSize(_ size: CGSize, cond: ImGuiSetCond = .always) {
		imguiWrapper.setNextWindowSize(size, cond.rawValue)
	}
	
	public func setNextWindowPos(_ pos: CGPoint, cond: ImGuiSetCond = .always) {
		imguiWrapper.setNextWindowPos(pos, cond.rawValue)
	}
	
	public func setWindowSize(_ size: CGSize, cond: ImGuiSetCond = .always) {
		imguiWrapper.setWindowSize(size, cond.rawValue)
	}
	
	public func setWindowPos(_ pos: CGPoint, cond: ImGuiSetCond = .always) {
		imguiWrapper.setWindowPos(pos, cond.rawValue)
	}
	
    public func setWindowFontScale<T: Numeric>(_ scale: T) {
		imguiWrapper.setWindowFontScale(scale.f)
	}
	
	public func openPopup(_ id: String) {
		imguiWrapper.openPopup(id)
	}
	
	@discardableResult
	public func beginPopup(_ id: String) -> Bool {
		return imguiWrapper.beginPopup(id)
	}
	
	@discardableResult
	public func beginPopupModal(name: String, opened: UnsafeMutablePointer<Bool>? = nil) -> Bool {
		
		var pointer: UnsafeMutablePointer<ObjCBool>? = nil
		
		if opened != nil {
			var pointee = ObjCBool(opened!.pointee)
			pointer = UnsafeMutablePointer<ObjCBool>.init(mutating: &pointee)
		}
		
		let res = imguiWrapper.beginPopupModal(name, pointer)
		
		if opened != nil {
			opened?.pointee = (pointer?.pointee.boolValue)!
		}
		
		return res
	}
	
	@discardableResult
	public func beginPopupContextItem(strId: String, mouseButton: Int32 = 1) -> Bool {
		return imguiWrapper.beginPopupContextItem(strId, mouseButton)
	}
	
	@discardableResult
	public func beginPopupContextWindow(alsoOverItems: Bool = true, strId: String? = nil, mouseButton: Int32 = 1) -> Bool {
		return imguiWrapper.beginPopupContextWindow(alsoOverItems, strId, mouseButton)
	}
	
	@discardableResult
	public func beginPopupContextVoid(strId: String? = nil, mouseButton: Int32 = 1) -> Bool {
		return imguiWrapper.beginPopupContextVoid(strId, mouseButton)
	}
	
	public func endPopup() {
		imguiWrapper.endPopup()
	}
	
	public func getTime() -> Float {
		return imguiWrapper.getTime()
	}
	
	
	public func setKeyboardFocusHere() {
		print("setKeyboardFocusHere is not implemented")
	}
	
	
	public func showStyleEditor (){
		// imguiWrapper.showStyleEditor()
	}
	
	public func logButtons() {
		imguiWrapper.logButtons()
	}
	
	
	public func begin(_ name: String, show: UnsafeMutablePointer<Bool>? = nil, flags: ImGuiWindowFlags = ImGuiWindowFlags(rawValue: 0)) {
		
		var _showPointer: UnsafeMutablePointer<ObjCBool>? = nil
		if show != nil {
			var _show = ObjCBool(show!.pointee)
			_showPointer = UnsafeMutablePointer<ObjCBool>.init(mutating: &_show)
		}
		
		imguiWrapper.begin(name, _showPointer, flags.rawValue)
		
		if show != nil {
			show?.pointee = (_showPointer?.pointee.boolValue)!
		}
	}
	
	public func beginTooltip() {
		imguiWrapper.beginTooltip()
	}
	
	public func endTooltip() {
		imguiWrapper.endTooltip()
	}
	
	public func dummy(size: CGSize) {
		imguiWrapper.dummy(size)
	}
	
	public func indent() {
		imguiWrapper.indent()
	}
	
	public func unindent() {
		imguiWrapper.unindent()
	}
	
	public func getCursorPos() -> CGPoint {
		return imguiWrapper.getCursorPos()
	}
	
	public func getCursorPosX() -> Float {
		return Float(imguiWrapper.getCursorPos().x)
	}
	
	public func getCursorPosY() -> Float {
		return Float(imguiWrapper.getCursorPos().y)
	}
	
	public func setCursorPos(localPos: CGPoint) {
		imguiWrapper.setCursorPos(localPos)
	}
	
    func setCursorPosX<T: Numeric>(_ x: T) {
		imguiWrapper.setCursorPosX(x.f)
	}
	
    func setCursorPosY<T: Numeric>(_ y: T) {
		imguiWrapper.setCursorPosY(y.f)
	}
	
	public func getCursorStartPos() -> CGPoint {
		return imguiWrapper.getCursorStartPos()
	}
	
	public func getCursorScreenPos() -> CGPoint {
		return imguiWrapper.getCursorScreenPos()
	}
	
	public func setCursorScreenPos(_ pos: CGPoint) {
		return imguiWrapper.setCursorScreenPos(pos)
	}
	
	public func alignFirstTextHeightToWidgets() {
		return imguiWrapper.alignFirstTextHeightToWidgets()
	}
	
	public func getTextLineHeight() -> Float {
		return imguiWrapper.getTextLineHeight()
	}
	
	public func getTextLineHeightWithSpacing() -> Float {
		return imguiWrapper.getTextLineHeightWithSpacing()
	}
	
	public func getItemsLineHeightWithSpacing() -> Float {
		return imguiWrapper.getItemsLineHeightWithSpacing()
	}
	
	// MARK: Columns
	
	public func columns(count:Int, id: String = "", border: Bool = true) {
		imguiWrapper.columns(Int32(count), id, border)
	}
	
	public func nextColumn() {
		imguiWrapper.nextColumn()
	}
	
	public func getColumnIndex() -> Int {
		return Int(imguiWrapper.getColumnIndex())
	}
	
	public func getColumnOffset(columnIndex: Int = -1) -> Float {
		return imguiWrapper.getColumnOffset(Int32(columnIndex))
	}
	
    func setColumnOffset<T: Numeric>(columnIndex: Int, offsetX: T) {
		imguiWrapper.setColumnOffset(Int32(columnIndex), offsetX.f)
	}
	
	public func getColumnWidth(columnIndex: Int = -1) -> Float {
		return imguiWrapper.getColumnWidth(Int32(columnIndex))
	}
	
	public func getColumnsCount() -> Int {
		return Int(imguiWrapper.getColumnsCount())
	}
	
	// MARK: ID scopes
	
	public func pushID(_ id: Int) {
		imguiWrapper.pushID(with: Int32(id))
	}
	
	public func pushID(_ id: String) {
		imguiWrapper.pushID(with: id)
	}
	
	public func pushID(idBegin: String, idEnd: String) {
		imguiWrapper.pushID(withIdBegin: idBegin, idEnd: idEnd)
	}
	
	public func popID() {
		imguiWrapper.popID()
	}
	
	public func getID(_ id: String) -> ImGuiID {
		return imguiWrapper.getIDWithStrId(id)
	}
	
	public func getID(begin: String, end: String) -> ImGuiID {
		return imguiWrapper.getIDWithBeginAndEnd(begin, end)
	}
	
	public func getID(_ pointer: UnsafeRawPointer) -> ImGuiID {
		return imguiWrapper.getIDWithPointer(pointer)
	}
	
	// MARK: Widgets
	
	public func text(_ label: String) {
		imguiWrapper.text(label)
	}
	
	public func textV(_ label: String) {
		imguiWrapper.textV(label)
	}
    
	public func text(_ string: String, colored color: ColorAlias = ColorAlias.white) {
		imguiWrapper.textColored(string, color.cgColor)
	}
	
	public func textV(_ string: String, colored color: ColorAlias = ColorAlias.white) {
		imguiWrapper.textColoredV(string, color.cgColor)
	}
	
	public func textDisabled(_ label: String) {
		imguiWrapper.textDisabled(label)
	}
	
	public func textDisabledV(_ label: String) {
		imguiWrapper.textDisabledV(label)
	}
	
	public func textWrapped(_ text: String) {
		imguiWrapper.textWrapped(text)
	}
	
	public func textWrappedV(_ text: String) {
		imguiWrapper.textWrappedV(text)
	}
	
	public func textUnformatted(_ text: String, textEnd: String? = nil) {
		imguiWrapper.textUnformatted(text, textEnd)
	}
	
	public func labelText(_ label: String, format: String) {
		imguiWrapper.labelText(label, format)
	}
	
	public func labelTextV(_ label: String, format: String) {
		imguiWrapper.labelTextV(label, format)
	}
	
	public func bullet(){
		imguiWrapper.bullet()
	}
	
	public func bulletText(_ text: String){
		imguiWrapper.bulletText(text)
	}
	
	public func bulletTextV(_ text: String){
		imguiWrapper.bulletTextV(text)
	}
	
	@discardableResult
	public func button(_ label: String, size: CGSize = CGSize.zero) -> Bool {
		return imguiWrapper.button(label, size)
	}
	
	@discardableResult
	public func smallButton(_ label: String) -> Bool {
		return imguiWrapper.smallButton(label)
	}
	
	@discardableResult
	public func invisibleButton(_ label: String, size: CGSize = CGSize.zero) -> Bool {
		return imguiWrapper.invisibleButton(label, size)
	}
	
	@discardableResult
	public func collapsingHeader(_ label: String, strID: String? = nil, displayFrame: Bool = true, defaultOpen: Bool = false) -> Bool {
		return imguiWrapper.collapsingHeader(label, strID, displayFrame, defaultOpen)
	}
	
	@discardableResult
	public func checkbox(_ label: String, active: UnsafeMutablePointer<Bool>) -> Bool{
		var _active = ObjCBool(active.pointee)
		let res = imguiWrapper.checkbox(label, &_active)
		active.pointee = _active.boolValue
		return res
	}
	
	@discardableResult
	public func radioButton(_ label: String, active: Bool) -> Bool{
		return imguiWrapper.radioButton(label, active)
	}
	
	@discardableResult
	public func radioButton(_ label: String, v: UnsafeMutablePointer<Int32>, vButton: Int32) -> Bool{
		let res = imguiWrapper.radioButtonVButton(label, v, vButton)
		return res
	}
	
	@discardableResult
	public func combo<T: BinaryInteger>(_ label: String, currentItemIndex: UnsafeMutablePointer<T>, items: [String], heightInItems: Int = -1) -> Bool {
		
		var _currentItemIndex: Int32
		if ((currentItemIndex.pointee as? Int) != nil) {
			_currentItemIndex = Int32(currentItemIndex.pointee as! Int)
		} else {
			_currentItemIndex = currentItemIndex.pointee as! Int32
		}
		let res = imguiWrapper.combo(label, &_currentItemIndex, items, Int32(heightInItems))
		
		if currentItemIndex.pointee is Int {
			currentItemIndex.pointee = Int(_currentItemIndex) as! T
		} else {
			currentItemIndex.pointee = _currentItemIndex as! T
		}
		
		return res
	}
	
	@discardableResult
	public func combo(_ label: String, currentItemIndex: UnsafeMutablePointer<Int32>, items: [String], heightInItems: Int = -1) -> Bool {
		return imguiWrapper.combo(label, currentItemIndex, items, Int32(heightInItems))
	}
	
	public typealias ComboItemsGetter = (UnsafeRawPointer?, Int32, UnsafeMutablePointer<UnsafePointer<Int8>?>?)->Bool
	public func combo(_ label: String, currentItemIndex: UnsafeMutablePointer<Int32>, itemsGetter: @escaping ComboItemsGetter, data: UnsafeMutableRawPointer?, itemsCount: Int, heightInItems: Int = -1) {
		imguiWrapper.combo(label, currentItemIndex, itemsGetter, data, Int32(itemsCount), Int32(heightInItems))
	}
	
	@discardableResult
	public func colorButton(_ color: ColorAlias, smallHeight: Bool = false, outlineBorder: Bool = true) -> Bool {
		return imguiWrapper.colorButton(color.cgColor, smallHeight, outlineBorder)
	}
	
	@discardableResult
	public func colorEdit(_ label: String, color: UnsafeMutablePointer<ColorAlias?>) -> Bool{
        
        if var _ = color.pointee?.cgColor.components!.map({ (v) -> Float in return Float(v) }) {
            return colorEdit(label, color: &(color.pointee)!)
        } else {
            return false
        }
	}
	@discardableResult
	public func colorEdit(_ label: String, color: UnsafeMutablePointer<ColorAlias>) -> Bool{
        
        var _color = color.pointee.cgColor.components!.map({ (v) -> Float in return Float(v) })
        var numberOfComponents = color.pointee.cgColor.numberOfComponents
		if numberOfComponents < 4 {
			let alpha = _color[1]
			_color[0] = _color[0]
			_color[1] = _color[0]
			_color.append(_color[0])
			_color.append(alpha)
			numberOfComponents = 4
		}
		let res = imguiWrapper.colorEdit(label, &_color)
		color.pointee = ColorAlias(red: CGFloat(_color[0]), green: CGFloat(_color[1]), blue: CGFloat(_color[2]), alpha: CGFloat(_color[3]))
        return res
	}
	
    public func plotLines<T: Numeric>(_ label: String, values: [T], valuesOffset: Int = 0, overlayText: String = "", scaleMin: Float = .leastNormalMagnitude, scaleMax: Float = .greatestFiniteMagnitude, graphSize: CGSize = CGSize.zero, stride: Int = MemoryLayout<Float>.size) {
		imguiWrapper.plotLines(label, values.map({ return $0.f }), Int32(values.count), Int32(valuesOffset), overlayText, scaleMin, scaleMax, graphSize, Int32(stride))
	}
	
	public func plotLines(_ label: String, valuesGetter: (@escaping PlotValuesGetter), valuesCount: Int = 0, valuesOffset: Int = 0, overlayText: String? = nil, scaleMin: Float = .leastNormalMagnitude, scaleMax: Float = .greatestFiniteMagnitude, graphSize: CGSize = CGSize.zero) {
		imguiWrapper.plotLinesGetter(label, valuesGetter, nil, Int32(valuesCount), Int32(valuesOffset), overlayText, scaleMin, scaleMax, graphSize)
	}
	
	public func plotLines(_ label: String, valuesGetter: (@escaping PlotValuesGetter), values: [Any]? = nil, valuesOffset: Int = 0, overlayText: String? = nil, scaleMin: Float = .leastNormalMagnitude, scaleMax: Float = .greatestFiniteMagnitude, graphSize: CGSize = CGSize.zero) {
		let valuesCount = Int32(values == nil ? 0 : (values?.count)!)
		var _values = values
		imguiWrapper.plotLinesGetter(label, valuesGetter, &_values, valuesCount, Int32(valuesOffset), overlayText, scaleMin, scaleMax, graphSize)
	}
	
	public func plotHistogram(_ label: String, valuesGetter: (@escaping PlotValuesGetter), valuesCount: Int = 0, valuesOffset: Int = 0, overlayText: String? = nil, scaleMin: Float = .leastNormalMagnitude, scaleMax: Float = .greatestFiniteMagnitude, graphSize: CGSize = CGSize.zero) {
		imguiWrapper.plotHistogramGetter(label, valuesGetter, nil, Int32(valuesCount), Int32(valuesOffset), overlayText, scaleMin, scaleMax, graphSize)
	}
	
	public func plotHistogram(_ label: String, valuesGetter: (@escaping PlotValuesGetter), values: [Any]? = nil, valuesOffset: Int = 0, overlayText: String? = nil, scaleMin: Float = .leastNormalMagnitude, scaleMax: Float = .greatestFiniteMagnitude, graphSize: CGSize = CGSize.zero) {
		let valuesCount = Int32(values == nil ? 0 : (values?.count)!)
		var _values = values
		imguiWrapper.plotHistogramGetter(label, valuesGetter, &_values, valuesCount, Int32(valuesOffset), overlayText, scaleMin, scaleMax, graphSize)
	}
	
    func plotHistogram<T: Numeric>(_ label: String, values: [T], valuesOffset: Int = 0, overlayText: String? = nil, scaleMin: Float = .greatestFiniteMagnitude, scaleMax: Float = .greatestFiniteMagnitude, graphSize: CGSize = CGSize.zero, stride: Int = MemoryLayout<Float>.size) {
        imguiWrapper.plotHistogram(label, values.map({ return $0.f }), Int32(values.count), Int32(valuesOffset), overlayText, scaleMin, scaleMax, graphSize, Int32(stride))
	}
	
    func progressBar<T: Numeric>(_ progress: T, position: CGPoint = CGPoint.zero, text: String = "") {
		imguiWrapper.progressBar(progress.f, position, text)
	}
	
	// MARK: Widgets: Drags
    
    @discardableResult
    public func dragFloat<T: Numeric>(_ label: String, v: UnsafeMutablePointer<T>, vSpeed:Float = 1.0, minV: Float = 0.0, maxV: Float = 0.0, displayFormat: String = "%.3f", power: Float = 1.0, itemCount: Int = 1) -> Bool{
		
		if itemCount > 4 { return false }
		
		var _v: [Float] = []
		
		for i in 0..<itemCount { _v.append(v[i].f) }
		
		let res = imguiWrapper.dragFloat(label, &_v, Int32(itemCount), vSpeed, minV, maxV, displayFormat, power)
		
		for i in 0..<itemCount {
			v[i] = _v[i] as! T
		}
		
		return res
	}
	
	@discardableResult
	public func dragFloat(_ label: String, v: UnsafeMutablePointer<Float>, vSpeed:Float = 1.0, minV: Float = 0.0, maxV: Float = 0.0, displayFormat: String = "%.3f", power: Float = 1.0, itemCount: Int = 1) -> Bool{
		
		if itemCount > 4 { return false }
		
		var _v: [Float] = []
		
		for i in 0..<itemCount {
			_v.append(v[i])
		}
		
		let res = imguiWrapper.dragFloat(label, &_v, Int32(itemCount), vSpeed, minV, maxV, displayFormat, power)
		
		for i in 0..<itemCount {
			v[i] = _v[i]
		}
		
		return res
	}
	
	@discardableResult
	public func dragFloat2(_ label: String, v: UnsafeMutablePointer<Float>, vSpeed: Float = 1.0, minV: Float, maxV: Float, displayFormat: String = "%.3f") -> Bool{
		return dragFloat(label, v: v, minV: minV, maxV: maxV, displayFormat: displayFormat, itemCount: 2)
	}
	
	@discardableResult
	public func dragFloat2(_ label: String, v: UnsafeMutablePointer<CGSize>, vSpeed: Float = 1.0, minV: Float, maxV: Float, displayFormat: String = "%.3") -> Bool{
		var _v: [Float] = [Float(v.pointee.width), Float(v.pointee.height)]
		let res = dragFloat(label, v: &_v, minV: minV, maxV: maxV, displayFormat: displayFormat, itemCount: 2)
		v.pointee = CGSize(width: CGFloat(_v[0]), height: CGFloat(_v[1]))
		return res
	}
	
	@discardableResult
	public func dragFloat2(_ label: String, v: UnsafeMutablePointer<CGPoint>, vSpeed: Float = 1.0, minV: Float, maxV: Float, displayFormat: String = "%.3f") -> Bool{
		var _v: [Float] = [Float(v.pointee.x), Float(v.pointee.y)]
		let res = dragFloat(label, v: &_v, minV: minV, maxV: maxV, displayFormat: displayFormat, itemCount: 2)
		v.pointee = CGPoint(x: CGFloat(_v[0]), y: CGFloat(_v[1]))
		return res
	}
	
	@discardableResult
	public func dragFloat3(_ label: String, v: UnsafeMutablePointer<Float>, vSpeed: Float = 1.0, minV: Float, maxV: Float, displayFormat: String = "%.3f") -> Bool{
		return dragFloat(label, v: v, vSpeed: vSpeed, minV: minV, maxV: maxV, displayFormat: displayFormat, itemCount: 3)
	}
	
	@discardableResult
	public func dragFloat4(_ label: String, v: UnsafeMutablePointer<Float>, vSpeed: Float, minV: Float, maxV: Float, displayFormat: String = "%.3f") -> Bool{
		return dragFloat(label, v: v, vSpeed: vSpeed, minV: minV, maxV: maxV, displayFormat: displayFormat, itemCount: 4)
	}
	
	@discardableResult
	public func dragFloatRange2(_ label: String, vCurrentMin: UnsafeMutablePointer<Float>, vCurrentMax: UnsafeMutablePointer<Float>, vSpeed: Float = 1.0, minV: Float = 0.0, maxV: Float = 0.0, displayFormat: String = "%.3f", displayFormatMax: String? = nil, power: Float = 1.0) -> Bool{
		return imguiWrapper.dragFloatRange2(label, vCurrentMin, vCurrentMax, vSpeed, minV, maxV, displayFormat, displayFormatMax, power)
	}
	
	@discardableResult
	public func dragInt<T: BinaryInteger>(_ label: String, v: UnsafeMutablePointer<T>, vSpeed: Float = 1.0, minV: Int32, maxV: Int32, displayFormat: String = "%.0f", itemCount: Int = 1) -> Bool{
		
		if itemCount > 4 { return false }
		
		var _v: [Int32] = []
		
		for i in 0..<itemCount {
			if let value = v[i] as? Int {
				_v.append(Int32(value))
			} else {
				_v.append((v[i] as? Int32)!)
			}
		}
		
		let res = imguiWrapper.dragInt(label, &_v, Int32(itemCount), vSpeed, minV, maxV, displayFormat)
		
		for i in 0..<itemCount {
			if let value = _v[i] as? T {
				v[i] = value
			} else {
				v[i] = Int(_v[i]) as! T
			}
		}
		
		return res
	}
	
	@discardableResult
	public func dragInt2<T: BinaryInteger>(_ label: String, v: UnsafeMutablePointer<T>, vSpeed: Float = 1.0, minV: Int32, maxV: Int32, displayFormat: String = "%.0f") -> Bool{
		return dragInt(label, v: v, minV: minV, maxV: maxV, displayFormat: displayFormat, itemCount: 2)
	}
	
	@discardableResult
	public func dragInt3<T: BinaryInteger>(_ label: String, v: UnsafeMutablePointer<T>, vSpeed: Float = 1.0,  minV: Int32, maxV: Int32, displayFormat: String = "%.0f") -> Bool{
		return dragInt(label, v: v, minV: minV, maxV: maxV, displayFormat: displayFormat, itemCount: 3)
	}
	
	@discardableResult
	public func dragInt4<T: BinaryInteger>(_ label: String, v: UnsafeMutablePointer<T>, vSpeed: Float = 1.0, minV: Int32, maxV: Int32, displayFormat: String = "%.0f") -> Bool{
		return dragInt(label, v: v, minV: minV, maxV: maxV, displayFormat: displayFormat, itemCount: 4)
	}
	
	@discardableResult
	public func dragIntRange2<T: BinaryInteger>(_ label: String, vCurrentMin: UnsafeMutablePointer<T>, vCurrentMax: UnsafeMutablePointer<T>, vSpeed: Float = 1.0, minV: Int32 = 0, maxV: Int32 = 0, displayFormat: String = "%.3f", displayFormatMax: String? = nil) -> Bool{
		var _vCurMin: Int32
		var _vCurMax: Int32
		if let value = vCurrentMin.pointee as? Int {
			_vCurMin = Int32(value)
			_vCurMax = Int32(vCurrentMax.pointee as! Int)
		} else {
			_vCurMin = vCurrentMin.pointee as! Int32
			_vCurMax = vCurrentMax.pointee as! Int32
		}
		
		let res = imguiWrapper.dragIntRange2(label, &_vCurMin, &_vCurMax, vSpeed, minV, maxV, displayFormat, displayFormatMax)
		
		if vCurrentMin.pointee is Int {
			vCurrentMin.pointee = Int(_vCurMin) as! T
			vCurrentMax.pointee = Int(_vCurMax) as! T
		} else {
			vCurrentMin.pointee = _vCurMin as! T
			vCurrentMax.pointee = _vCurMax as! T
		}
		
		return res
	}
	
	@discardableResult
	public func inputInt<T: BinaryInteger>(_ label: String, v: UnsafeMutablePointer<T>, itemCount: Int = 1, step: Int32 = 1, stepFast: Int32 = 100, extraFlags: ImGuiInputTextFlags = ImGuiInputTextFlags(rawValue: 0)) -> Bool{
		
		if itemCount > 4 { return false }
		
		var _v: [Int32] = []
		
		for i in 0..<itemCount {
			if let value = v[i] as? Int {
				_v.append(Int32(value))
			} else {
				_v.append((v[i] as? Int32)!)
			}
		}
		
		let res = imguiWrapper.inputInt(label, &_v, Int32(itemCount), step, stepFast, extraFlags.rawValue)
		
		for i in 0..<itemCount {
			if let value = _v[i] as? T {
				v[i] = value
			} else {
				v[i] = Int(_v[i]) as! T
			}
		}
		
		return res
	}
	
	@discardableResult
	public func inputInt2<T: BinaryInteger>(_ label: String, v: UnsafeMutablePointer<T>, step: Int32 = 1, stepFast: Int32 = 100, extraFlags: ImGuiInputTextFlags = ImGuiInputTextFlags(rawValue: 0)) -> Bool {
		return inputInt(label, v: v, itemCount: 2, step: step, stepFast: stepFast, extraFlags: extraFlags)
	}
	
	@discardableResult
	public func inputInt3<T: BinaryInteger>(_ label: String, v: UnsafeMutablePointer<T>, step: Int32 = 1, stepFast: Int32 = 100, extraFlags: ImGuiInputTextFlags = ImGuiInputTextFlags(rawValue: 0)) -> Bool {
		return inputInt(label, v: v, itemCount: 3, step: step, stepFast: stepFast, extraFlags: extraFlags)
	}
	
	@discardableResult
	public func inputInt4<T: BinaryInteger>(_ label: String, v: UnsafeMutablePointer<T>, step: Int32 = 1, stepFast: Int32 = 100, extraFlags: ImGuiInputTextFlags = ImGuiInputTextFlags(rawValue: 0)) -> Bool {
		return inputInt(label, v: v, itemCount: 4, step: step, stepFast: stepFast, extraFlags: extraFlags)
	}
	
	@discardableResult
    public func inputFloat<T: Numeric>(_ label: String, v: UnsafeMutablePointer<T>, itemCount: Int = 1, step: Float = 0.0, stepFast: Float = 0.0, decimalPrecision: Int32 = -1, extraFlags: ImGuiInputTextFlags = ImGuiInputTextFlags(rawValue: 0)) -> Bool{
		if itemCount > 4 { return false }
        
		var _v: [Float] = []
		
		for i in 0..<itemCount { _v.append(v[i].f) }
		
		let res = imguiWrapper.inputFloat(label, &_v, Int32(itemCount), step, stepFast, decimalPrecision, extraFlags.rawValue)
		for i in 0..<itemCount {
			v[i] = T(_v[i])
		}
        
		return res
	}
	
	@discardableResult
    public func inputFloat2<T: Numeric>(_ label: String, v: UnsafeMutablePointer<T>, step: Float = 0.0, stepFast: Float = 0.0, decimalPrecision: Int32 = -1, extraFlags: ImGuiInputTextFlags = ImGuiInputTextFlags(rawValue: 0)) -> Bool {
		return inputFloat(label, v: v, itemCount: 2, step: step, stepFast: stepFast, extraFlags: extraFlags)
	}
	
	@discardableResult
    public func inputFloat3<T: Numeric>(_ label: String, v: UnsafeMutablePointer<T>, step: Float = 0.0, stepFast: Float = 0.0, decimalPrecision: Int32 = -1, extraFlags: ImGuiInputTextFlags = ImGuiInputTextFlags(rawValue: 0)) -> Bool {
		return inputFloat(label, v: v, itemCount: 3, step: step, stepFast: stepFast, extraFlags: extraFlags)
	}
	
	@discardableResult
    public func inputFloat4<T: Numeric>(_ label: String, v: UnsafeMutablePointer<T>, step: Float = 0.0, stepFast: Float = 0.0, decimalPrecision: Int32 = -1, extraFlags: ImGuiInputTextFlags = ImGuiInputTextFlags(rawValue: 0)) -> Bool {
		return inputFloat(label, v: v, itemCount: 4, step: step, stepFast: stepFast, extraFlags: extraFlags)
	}
	
	// MARK: Sliders
	@discardableResult
    public func sliderFloat<T: Numeric>(_ label: String, v: UnsafeMutablePointer<T>, minV: Float, maxV: Float, displayFormat: String = "%.3f", power: Float = 1.0, itemCount: Int = 1) -> Bool{
		
		var _v: [Float] = []
		
		for i in 0..<itemCount {
            _v.append(v[i].f)
		}
		
		let res = imguiWrapper.sliderFloat(label, &_v, Int32(itemCount), minV, maxV, displayFormat, power)
		
		for i in 0..<itemCount {
			v[i] = T(_v[i])
		}
		
		return res
	}
	
	@discardableResult
    func sliderFloat2<T: Numeric>(_ label: String, v: UnsafeMutablePointer<T>, minV: Float, maxV: Float, displayFormat: String = "%.3f") -> Bool{
		return sliderFloat(label, v: v, minV: minV, maxV: maxV, displayFormat: displayFormat, itemCount: 2)
	}
	
	@discardableResult
	public func sliderFloat2(_ label: String, v: UnsafeMutablePointer<CGSize>, minV: Float, maxV: Float, displayFormat: String = "%.3f") -> Bool{
		
		var _v: [Float] = [Float(v.pointee.width), Float(v.pointee.height)]
		let res = sliderFloat(label, v: &_v, minV: minV, maxV: maxV, displayFormat: displayFormat, itemCount: 2)
		v.pointee = CGSize(width: CGFloat(_v[0]), height: CGFloat(_v[1]))
		return res
		
	}
	
	@discardableResult
	public func sliderFloat2(_ label: String, v: UnsafeMutablePointer<CGPoint>, minV: Float, maxV: Float, displayFormat: String = "%.3f") -> Bool{
		
		var _v: [Float] = [Float(v.pointee.x), Float(v.pointee.y)]
		let res = sliderFloat(label, v: &_v, minV: minV, maxV: maxV, displayFormat: displayFormat, itemCount: 2)
		v.pointee = CGPoint(x: CGFloat(_v[0]), y: CGFloat(_v[1]))
		return res
		
	}
	
	@discardableResult
    func sliderFloat3<T: Numeric>(_ label: String, v: UnsafeMutablePointer<T>, minV: Float, maxV: Float, displayFormat: String = "%.3f") -> Bool{
		return sliderFloat(label, v: v, minV: minV, maxV: maxV, displayFormat: displayFormat, itemCount: 3)
	}
	
	@discardableResult
	public func sliderFloat4(_ label: String, v: UnsafeMutablePointer<Float>, minV: Float, maxV: Float, displayFormat: String = "%.3f") -> Bool{
		return sliderFloat(label, v: v, minV: minV, maxV: maxV, displayFormat: displayFormat, itemCount: 4)
	}
	
	@discardableResult
    func sliderAngle<T: Numeric>(_ label: String, rad: UnsafeMutablePointer<T>, vDegreesMin: Float = -360.0, vDegreesMax: Float = 360.0) -> Bool {
        var v: Float = 0.0
        if let tmp = rad.pointee as? CGFloat {
            v = Float(tmp)
        }
        let res = imguiWrapper.sliderAngle(label, &v, vDegreesMin, vDegreesMax)
        rad.pointee = T(v)
		return res
	}
    
	@discardableResult
	public func sliderInt<T: BinaryInteger>(_ label: String, v: UnsafeMutablePointer<T>, minV: Int32, maxV: Int32, displayFormat: String = "%.0f", itemCount: Int = 1) -> Bool{
		
		var _v: [Int32] = []
		
		for i in 0..<itemCount {
			if let value = v[i] as? Int {
				_v.append(Int32(value))
			} else {
				_v.append((v[i] as? Int32)!)
			}
		}
		
		let res = imguiWrapper.sliderInt(label, &_v, Int32(itemCount), minV, maxV, displayFormat)
		
		for i in 0..<itemCount {
			if let value = _v[i] as? T {
				v[i] = value
			} else {
				v[i] = Int(_v[i]) as! T
			}
		}
		
		return res
	}
	
	@discardableResult
	public func sliderInt2<T: BinaryInteger>(_ label: String, v: UnsafeMutablePointer<T>, minV: Int32, maxV: Int32, displayFormat: String = "%.0f") -> Bool{
		return sliderInt(label, v: v, minV: minV, maxV: maxV, displayFormat: displayFormat, itemCount: 2)
	}
	
	@discardableResult
	public func sliderInt3<T: BinaryInteger>(_ label: String, v: UnsafeMutablePointer<T>, minV: Int32, maxV: Int32, displayFormat: String = "%.0f") -> Bool{
		return sliderInt(label, v: v, minV: minV, maxV: maxV, displayFormat: displayFormat, itemCount: 3)
	}
	
	@discardableResult
	public func sliderInt4<T: BinaryInteger>(_ label: String, v: UnsafeMutablePointer<T>, minV: Int32, maxV: Int32, displayFormat: String = "%.0f") -> Bool{
		return sliderInt(label, v: v, minV: minV, maxV: maxV, displayFormat: displayFormat, itemCount: 4)
	}
	
	@discardableResult
	public func vSliderFloat(_ label: String, size:CGSize, v: UnsafeMutablePointer<Float>, vMin: Float, vMax: Float, displayFormat: String = "%.3f", power: Float = 1.0) -> Bool {
		
		let res = imguiWrapper.vSliderFloat(label, size, v, vMin, vMax, displayFormat, power);
		return res
	}
	
	@discardableResult
	public func vSliderInt<T: BinaryInteger>(_ label: String, size:CGSize, v: UnsafeMutablePointer<T>, vMin: Int, vMax: Int, displayFormat: String = "%.0f") -> Bool {
		
		var _v: Int32
		if let value = v.pointee as? Int {
			_v = Int32(value)
		} else {
			_v = v.pointee as! Int32
		}
		
		let res = imguiWrapper.vSliderInt(label, size, &_v, Int32(vMin), Int32(vMax), displayFormat)
		
		if v.pointee is Int {
			v.pointee = Int(_v) as! T
		} else {
			v.pointee = _v as! T
		}
		
		return res
	}
	
	// MARK: Widgets: Trees
	
	@discardableResult
	public func treeNode(_ label: String) -> Bool {
		return imguiWrapper.treeNode(label)
	}
	
	@discardableResult
	public func treeNode(id: UnsafeMutableRawPointer, label: String) -> Bool {
		return imguiWrapper.treeNode(withId: id, label)
	}
	
	@discardableResult
	public func treeNodeV(_ label: String) -> Bool {
		return imguiWrapper.treeNodeV(label)
	}
	
	public func treePush(_ id: String) {
		imguiWrapper.treePush(id)
	}
	
	public func treePush(pointer: UnsafeRawPointer?){
		imguiWrapper.treePush(withPointer: pointer)
	}
	
	public func treePop() {
		imguiWrapper.treePop()
	}
	
	// MARK: Widgets: Selectable / Lits
	
	@discardableResult
	public func selectable(_ label: String, selected: Bool = false, flags: ImGuiSelectableFlags = ImGuiSelectableFlags(rawValue: 0), size: CGSize = CGSize.zero) -> Bool {
		return imguiWrapper.selectable(label, selected, flags.rawValue, size)
	}
	
	@discardableResult
	public func selectable(_ label: String, selected: UnsafeMutablePointer<Bool>, flags: ImGuiSelectableFlags = ImGuiSelectableFlags(rawValue: 0), size: CGSize = .zero) -> Bool {
		var _selected = ObjCBool(selected.pointee)
		let res = imguiWrapper.selectablePointer(label, &_selected, flags.rawValue, size)
		selected.pointee = _selected.boolValue
		return res
	}
	
	@discardableResult
	public func listBox(_ label: String, currentItemIndex: UnsafeMutablePointer<Int32>, items: [String], heightInItem: Int = -1) -> Bool {
		return imguiWrapper.listBox(label, currentItemIndex, items, Int32(heightInItem))
	}
	
	@discardableResult
	public func listBox(_ label: String, currentItemIndex: UnsafeMutablePointer<Int>, items: [String], heightInItem: Int = -1) -> Bool {
		var _currentItemIndex = Int32(currentItemIndex.pointee)
		let res = imguiWrapper.listBox(label, &_currentItemIndex, items, Int32(heightInItem))
		currentItemIndex.pointee = Int(_currentItemIndex)
		return res
	}
	
	@discardableResult
	public func listBoxHeader(_ label: String, itemsCount: Int = 0, heightInItems: Int = -1) -> Bool {
		// Cleaner api
		return imguiWrapper.listBoxHeader(label, withItemsCount: Int32(itemsCount), withHeightInItems: Int32(heightInItems))
	}
	
	@discardableResult
	public func listBoxHeader(_ label: String, size: CGSize = CGSize.zero) -> Bool {
		return imguiWrapper.listBoxHeader(label, with: size)
	}
	
	public func listBoxFooter() {
		imguiWrapper.listBoxFooter()
	}
	
	// MARK: Widgets: Value
	
	public func valueBool(_ prefix: String, v: Bool) {
		imguiWrapper.valueBool(prefix, v)
	}
	
	public func valueInt(_ prefix: String, v: Int) {
		imguiWrapper.valueInt(prefix, Int32(v))
	}
	
	public func valueUInt(_ prefix: String, v: UInt) {
		imguiWrapper.valueUInt(prefix, UInt32(v))
	}
	
	public func valueFloat(_ prefix: String, v: Float, floatFormat: String? = nil) {
		imguiWrapper.valueFloat(prefix, v, floatFormat)
	}
	
	public func valueColor(_ prefix: String, v: CGColor) {
		imguiWrapper.valueColor(prefix, v)
	}
	
	public func beginChild(_ id: String, sizeArg: CGSize = CGSize.zero, border: Bool = false, flags: ImGuiWindowFlags = .noTitleBar ) {
		imguiWrapper.beginChild(id, sizeArg, border, flags.rawValue)
	}
	
	public func endChild() {
		imguiWrapper.endChild()
	}
	
	
	public func setScrollX(_ scrollX: Float) {
		imguiWrapper.setScrollX(scrollX)
	}
	
	public func getScrollX() -> Float {
		return imguiWrapper.getScrollX()
	}
	
	@discardableResult
	public func isMouseDragging() -> Bool {
		return imguiWrapper.isMouseDragging()
	}
	
	public func addRectFilled(_ rect: CGRect, color: ColorAlias = ColorAlias.white, rounding: Float = 0.0, roundingCorners: Int = 0x0F) {
		return imguiWrapper.addRectFilled(rect, color.cgColor, rounding, Int32(roundingCorners))
	}
	
	public func addText(_ text: String, pos: CGPoint, color: ColorAlias = ColorAlias.white) {
		return imguiWrapper.addText(text, pos, color.cgColor)
	}
	
	public func addRectFilledMultiColor(_ rect: CGRect, colorUpperLeft: ColorAlias = ColorAlias.red, colorUpperRight: ColorAlias = ColorAlias.green, colorBottomRight: ColorAlias = ColorAlias.blue, colorBottomLeft: ColorAlias = ColorAlias.magenta) {
		return imguiWrapper.addRectFilledMultiColor(rect, colorUpperLeft.cgColor, colorUpperRight.cgColor, colorBottomRight.cgColor, colorBottomLeft.cgColor)
	}
	
	public func addRect(_ rect: CGRect, color: ColorAlias = ColorAlias.white, rounding: Float = 0.0, roundingCorners: Int = 0x0F) {
		return imguiWrapper.add(rect, color.cgColor, rounding, Int32(roundingCorners))
	}
	
	public func ioAddInputCharacter(_ char: String) {
		return imguiWrapper.ioAddInputCharacter(char)
	}
	
	public func setScrollHere() {
		imguiWrapper.setScrollHere()
	}
	
	public func getWindowContentRegionWidth() -> Float {
		return imguiWrapper.getWindowContentRegionWidth()
	}
	
	public func pushStyleVar(_ type: ImGuiStyleVar, value: Float) {
		return imguiWrapper.pushStyleVar(type.rawValue, with: value)
	}
	
	public func pushStyleVar(_ type: ImGuiStyleVar, value: CGPoint) {
		return imguiWrapper.pushStyleVar(type.rawValue, with: value)
	}
	
	public func pushStyleVar(_ type: ImGuiStyleVar, value: CGSize) {
		return imguiWrapper.pushStyleVar(type.rawValue, with: CGPoint(x: value.width, y: value.height))
	}
	
	public func pushStyleColor(_ type: ImGuiColor, color: ColorAlias) {
		imguiWrapper.pushStyleColor(type.rawValue, with: color.cgColor)
	}
	
	public func popStyleColor(_ count: Int = 1) {
		imguiWrapper.popStyleColor(Int32(count))
	}
	
	public func popStyleVar(_ count: Int = 1) {
		imguiWrapper.popStyleVar(Int32(count))
	}
	
	public func pushItemWidth(_ width: Float) {
		imguiWrapper.pushItemWidth(width)
	}
	
	public func popItemWidth() {
		imguiWrapper.popItemWidth()
	}
	
	public func calcItemWidth() -> Float {
		return imguiWrapper.calcItemWidth()
	}
	
	public func pushTextWrapPos(_ pos: Float = 0.0) {
		imguiWrapper.pushTextWrapPos(pos)
	}
	
	public func popTextWrapPos() {
		imguiWrapper.popTextWrapPos()
	}
	
	
	public func pushAllowKeyboardFocus(_ v: Bool) {
		imguiWrapper.pushAllowKeyboardFocus(v)
	}
	
	public func popAllowKeyboardFocus() {
		imguiWrapper.popAllowKeyboardFocus()
	}
	
	public func pushButtonRepeat(_ repeat_: Bool) {
		imguiWrapper.pushButtonRepeat(repeat_)
	}
	
	public func popButtonRepeat() {
		imguiWrapper.popButtonRepeat()
	}
	
	// MARK: Cursor / Layout
	
	public func beginGroup() {
		imguiWrapper.beginGroup()
	}
	
	public func endGroup() {
		imguiWrapper.endGroup()
	}
	
	public func separator() {
		imguiWrapper.separator()
	}
	
	public func sameLine(_ posX: Float = 0.0, spacingW: Float = 1.0) {
		imguiWrapper.sameLine(posX, spacingW)
	}
	
	public func spacing() {
		imguiWrapper.spacing()
	}
	
	public func getContentRegionAvailWidth() -> Float {
		return imguiWrapper.getContentRegionAvailWidth()
	}
	
	
	public func getWindowWidth() -> Float {
		return imguiWrapper.getWindowWidth()
	}
	
	
	
	@discardableResult
	public func beginMenu(_ label: String, enabled: Bool = true ) -> Bool {
		return imguiWrapper.beginMenu(label, enabled)
	}
	
	public func endMenu() {
		imguiWrapper.endMenu()
	}
	
	@discardableResult
	public func menuItem(_ label: String, shortcut: String = "", selected: Bool = true, enabled: Bool = true) -> Bool {
		return imguiWrapper.menuItem(label, shortcut, selected, enabled)
	}
	
	@discardableResult
	public func menuItem(_ label: String, shortcut: String = "", selected: UnsafeMutablePointer<Bool>, enabled: Bool = true) -> Bool {
		var _selected = ObjCBool(selected.pointee)
		let res = imguiWrapper.menuItemPointer(label, shortcut, &_selected, enabled)
		selected.pointee = _selected.boolValue
		return res
	}
	
	public func closeCurrentPopup() {
		imguiWrapper.closeCurrentPopup()
	}
	
	@discardableResult
	public func inputText(_ label: String, initialText string: UnsafeMutablePointer<String>, bufferSize: Int32 = 256, flags: ImGuiInputTextFlags = ImGuiInputTextFlags(rawValue: 0)) -> Bool {
		var chars = Array(string.pointee.utf8CString)
		let ret = imguiWrapper.inputText(label, initialText: &chars, bufferSize, flags.rawValue)
		string.pointee = String(cString: &chars)
		// input.textField.keyboardType = .default
		return ret
	}
	
	@discardableResult
	public func inputTextMultiline(_ label: String, initialText string: UnsafeMutablePointer<String>, bufferSize: Int32 = 1024, size: CGSize = CGSize.zero, flags: ImGuiInputTextFlags = ImGuiInputTextFlags(rawValue: 0)) -> Bool {
		
		var chars = Array(string.pointee.utf8CString)
		let ret = imguiWrapper.inputTextMultiline(label, initialText: &chars, bufferSize, size, flags.rawValue)
		string.pointee = String(cString: &chars)
		return ret
	}
	
	public func getItemRectSize() -> CGSize {
		return imguiWrapper.getItemRectSize()
	}
	
	public func getItemRectMin() -> CGPoint {
		return imguiWrapper.getItemRectMin()
	}
	
	public func getItemRectMax() -> CGPoint {
		return imguiWrapper.getItemRectMax()
	}
	
	@discardableResult
	public func isItemHovered() -> Bool {
		return imguiWrapper.isItemHovered()
	}
	
	public func isItemActive() -> Bool {
		return imguiWrapper.isItemActive()
	}
    public func isItemClicked() -> Bool {
        return imguiWrapper.isItemClicked()
    }
	
	@discardableResult
	public func isMouseDoubleClicked(_ button: Int32) -> Bool {
		return imguiWrapper.isMouseDoubleClicked(button)
	}
	
	public func setTooltip(_ text: String) {
		imguiWrapper.setTooltip(text);
	}
	
	public func getStyle() -> ImGuiStyleBridge {
		return imguiWrapper.getStyle() as! ImGuiStyleBridge
	}
	
	public func deltaTime() -> Float {
		return imguiWrapper.deltaTime()
	}
	
	public func end() {
		imguiWrapper.end()
	}
}

// MARK: Protocols
public protocol Numeric:Equatable {
    var f: Float { get }
    init(_ v:Float)
    init(_ v:Double)
    init(_ v:CGFloat)
}

extension Float: Numeric {
    public var f: Float { return self }
}
extension Double: Numeric {
    public var f: Float { return Float(self) }
}
extension CGFloat: Numeric {
    public var f: Float { return Float(self)}
}
