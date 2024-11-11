//
//  ToastView.swift
//  macos
//
//  Created by Christopher Macrae on 2024-11-11.
//

import SwiftUI

struct ToastView: View {
  
  var style: ToastStyle
  var message: String
  var width = CGFloat.infinity
  var onCancelTapped: (() -> Void)
  
  var body: some View {
    HStack(alignment: .center, spacing: 12) {
      Image(systemName: style.iconFileName)
        .foregroundColor(.gray)
      Text(message)
        .foregroundColor(.gray)
      
      Spacer(minLength: 10)
      
      Button {
        onCancelTapped()
      } label: {
        Image(systemName: "xmark")
      }
      .buttonStyle(ConnectButtonStyle())
    }
    .padding()
    .frame(minWidth: 0, maxWidth: width)
    .cornerRadius(8)
    .background(
      RoundedRectangle(cornerRadius: 8)
        .fill(.thinMaterial)
        .shadow(radius: 4)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(.black.opacity(0.1))
        )
    )
    .padding(.horizontal, 16)
  }
}

#Preview {
    ToastView(style: .error, message: "Error: Could not connect to server", onCancelTapped: {})
}
