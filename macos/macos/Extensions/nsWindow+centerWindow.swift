//
//  nsWindow+centerWindow.swift
//  macos
//
//  Created by Christopher Macrae on 2024-11-09.
//

import SwiftUI

extension NSApplication {
    func centerWindow() {
        if let window = NSApplication.shared.keyWindow {
            window.center()
        }
    }
}
