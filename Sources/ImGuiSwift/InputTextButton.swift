//
//  InputTextButton.swift
//  Swift-imgui
//
//  Created by Hiroaki Yamane on 10/17/16.
//  Copyright © 2016 Hiroaki Yamane. All rights reserved.
//

import Foundation

#if os(iOS)

class TextFieldDelegate : NSObject, UITextFieldDelegate
{
	var inputTextButton: InputTextButton!
	var isBackSpaced = false
	var isReturn = false
	var lastChar = ""
	
	override init() {
		super.init()
	}
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		isReturn = true
		textField.resignFirstResponder()
		return false
	}
	
	func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
		
		lastChar = string
		if range.length == 1 && string.count == 0 {
			isBackSpaced = true
		}
		
		return false
	}
	
	func resetInput() {
		lastChar = ""
		isReturn = false
		isBackSpaced = false
	}
}

class KeyNotifyTextField : UITextField {
	override func deleteBackward() {
		super.deleteBackward()
		if let delegate = self.delegate as? TextFieldDelegate {
			delegate.isBackSpaced = true
		}
	}
}

class InputTextButton {
	
	var textField: KeyNotifyTextField
	var textFieldDelegate: TextFieldDelegate
	var text: String = ""
	
	init(){
		textFieldDelegate = TextFieldDelegate()
		textField = KeyNotifyTextField(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 100, height: 20)))
		textField.text = text
		textField.placeholder = textField.text
		textField.isHidden = true
		textField.delegate = textFieldDelegate
		textFieldDelegate.inputTextButton = self
	}
	
	func draw(imgui: ImGuiBase) {
		
		imgui.ioAddInputCharacter(textFieldDelegate.lastChar)
		
		if textFieldDelegate.isBackSpaced {
			imgui.setKeyboardPress(key: .backspace)
		}
		
		if textFieldDelegate.isReturn {
			imgui.setKeyboardPress(key: .enter)
		}
		
		// TODO: Pick appropriate keyboard type according to input type.
		if imgui.io.wantTextInput {
			if !textField.isFirstResponder {
				textField.becomeFirstResponder()
			}
		} else {
			if textField.isFirstResponder {
				textField.resignFirstResponder()
			}
		}
		
		textFieldDelegate.resetInput()
	}
}
#endif
