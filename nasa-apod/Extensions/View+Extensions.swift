//
//  View+Extensions.swift
//  nasa-apod
//
//  Created by Aviral Saxena on 12/13/25.
//

import SwiftUI

extension View {
    
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
    
    
    func dismissOnVerticalDrag(threshold: CGFloat = 100, onDismiss: @escaping () -> Void) -> some View {
        self.gesture(
            DragGesture()
                .onEnded { value in
                    if abs(value.translation.height) > threshold && abs(value.translation.height) > abs(value.translation.width) {
                        onDismiss()
                    }
                }
        )
    }
    
    
    func hapticFeedback(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) -> some View {
        self.onTapGesture {
            let impactFeedback = UIImpactFeedbackGenerator(style: style)
            impactFeedback.impactOccurred()
        }
    }
}

// MARK: - Gesture Extensions

extension DragGesture.Value {
    
    var isVerticalDrag: Bool {
        abs(translation.height) > abs(translation.width)
    }
    
    
    var isHorizontalDrag: Bool {
        abs(translation.width) > abs(translation.height)
    }
}
