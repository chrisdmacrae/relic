//
//  GifImageView.swift
//  macos
//
//  Created by Christopher Macrae on 2024-11-11.
//

import SwiftUI

struct GifImageView: NSViewRepresentable {
    let url: URL
    
    func makeNSView(context: Context) -> NSImageView {
        let imageView = NSImageView()
        imageView.imageScaling = .scaleProportionallyUpOrDown
        loadGIF(url: url, into: imageView)
        return imageView
    }

    func updateNSView(_ nsView: NSImageView, context: Context) {}
    
    private func loadGIF(url: URL, into imageView: NSImageView) {
        guard let imageData = try? Data(contentsOf: url),
              let image = NSImage(data: imageData) else { return }
        
        imageView.image = image
        imageView.animates = true
    }
}

#Preview {
    GifImageView(url: URL(string: "https://i.giphy.com/media/v1.Y2lkPTc5MGI3NjExYnluNWIxOTVnNDV3cjZ5NTZ3ZDQ4N2o0Mmlnem85Nm55MTU4dWpzeCZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/KdC9XVrVYOVu6zZiMH/giphy.gif")!)
}
