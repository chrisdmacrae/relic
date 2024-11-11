//
//  View+toast.swift
//  macos
//
//  Created by Christopher Macrae on 2024-11-11.
//

import Foundation

import SwiftUI

extension View {
  func toast(toast: Binding<Toast?>) -> some View {
    self.modifier(ToastModifier(toast: toast))
  }
}
