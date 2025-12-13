//
//  View+Extensions.swift
//  nasa-apod
//
//  Created by Aviral Saxena on 12/13/25.
//

import SwiftUI

extension View {
    /// Adds a conditional modifier to a view
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
    
    /// Adds a drag gesture that only responds to vertical drags for dismissal
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
    
    /// Adds haptic feedback on tap
    func hapticFeedback(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) -> some View {
        self.onTapGesture {
            let impactFeedback = UIImpactFeedbackGenerator(style: style)
            impactFeedback.impactOccurred()
        }
    }
}

// MARK: - Gesture Extensions

extension DragGesture.Value {
    /// Returns true if the drag is primarily vertical
    var isVerticalDrag: Bool {
        abs(translation.height) > abs(translation.width)
    }
    
    /// Returns true if the drag is primarily horizontal
    var isHorizontalDrag: Bool {
        abs(translation.width) > abs(translation.height)
    }
}