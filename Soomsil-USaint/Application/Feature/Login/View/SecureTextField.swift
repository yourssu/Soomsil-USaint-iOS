//
//  SecureUITextField.swift
//  Soomsil-USaint
//
//  Created by 정지혁 on 1/20/25.
//

import UIKit
import SwiftUI

import YDS
import YDS_SwiftUI

struct SecureTextField: View {
    @Binding var text: String
    
    @State private var isSecured = true
    
    var body: some View {
        HStack {
            SecureUITextField(text: $text, isSecure: isSecured, textContentType: .newPassword)
            Button(action: {
                isSecured.toggle()
            }) {
                Image(systemName: isSecured ? "eye.slash" : "eye")
                    .accentColor(.grayText)
                    .frame(width: 24, height: 24)
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(.lightGray)
        )
        .frame(height: 48)
    }
}

struct SecureUITextField: UIViewRepresentable {
    @Binding var text: String
    
    var isSecure: Bool
    var textContentType: UITextContentType?
    
    class Coordinator: NSObject, UITextFieldDelegate {
        var parent: SecureUITextField
        
        init(parent: SecureUITextField) {
            self.parent = parent
        }
        
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            textField.resignFirstResponder()
            return true
        }
        
        func textFieldDidChangeSelection(_ textField: UITextField) {
            parent.text = textField.text ?? ""
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField()
        textField.delegate = context.coordinator
        textField.isSecureTextEntry = isSecure
        textField.textContentType = textContentType
        textField.backgroundColor = .clear
        textField.returnKeyType = .done
        textField.borderStyle = .none
        textField.tintColor = .vPrimary
        return textField
    }
    
    func updateUIView(_ uiView: UITextField, context: Context) {
        uiView.text = text
        uiView.isSecureTextEntry = isSecure
        uiView.textContentType = textContentType
    }
}
