import SwiftUI

// MARK: - Pressable Button Style

/// A button style that provides press feedback with scale animation and optional icon bounce.
struct PressableButtonStyle: ButtonStyle {
  let color: Color
  let isHovering: Bool
  
  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .scaleEffect(configuration.isPressed ? 0.97 : (isHovering ? 1.01 : 1.0))
      .animation(.spring(response: 0.2, dampingFraction: 0.6), value: configuration.isPressed)
  }
}

// MARK: - Pointer Hover Modifier

/// A view modifier that changes the cursor to pointing hand on hover.
struct PointerHoverModifier: ViewModifier {
  @State private var isHovering = false
  let onHover: ((Bool) -> Void)?
  
  init(onHover: ((Bool) -> Void)? = nil) {
    self.onHover = onHover
  }
  
  func body(content: Content) -> some View {
    content
      .onHover { hovering in
        isHovering = hovering
        onHover?(hovering)
        if hovering {
          NSCursor.pointingHand.push()
        } else {
          NSCursor.pop()
        }
      }
  }
}

extension View {
  /// Adds pointer cursor on hover with optional callback.
  func pointerOnHover(onHover: ((Bool) -> Void)? = nil) -> some View {
    modifier(PointerHoverModifier(onHover: onHover))
  }
}

// MARK: - Staggered Appear Modifier

/// A view modifier for staggered fade-in animations.
struct StaggeredAppearModifier: ViewModifier {
  let index: Int
  let baseDelay: Double
  let duration: Double
  
  @State private var isVisible = false
  
  init(index: Int, baseDelay: Double = 0.08, duration: Double = 0.35) {
    self.index = index
    self.baseDelay = baseDelay
    self.duration = duration
  }
  
  func body(content: Content) -> some View {
    content
      .opacity(isVisible ? 1 : 0)
      .offset(y: isVisible ? 0 : 10)
      .onAppear {
        let delay = Double(index) * baseDelay
        withAnimation(.easeOut(duration: duration).delay(delay)) {
          isVisible = true
        }
      }
  }
}

extension View {
  /// Applies a staggered appear animation based on index.
  func staggeredAppear(index: Int, baseDelay: Double = 0.08, duration: Double = 0.35) -> some View {
    modifier(StaggeredAppearModifier(index: index, baseDelay: baseDelay, duration: duration))
  }
}

// MARK: - Interactive Card Modifier

/// A view modifier for interactive cards with hover and press states.
struct InteractiveCardModifier: ViewModifier {
  let color: Color
  let cornerRadius: CGFloat
  
  @State private var isHovering = false
  
  func body(content: Content) -> some View {
    content
      .background(
        RoundedRectangle(cornerRadius: cornerRadius)
          .fill(color.opacity(isHovering ? 0.12 : 0.08))
          .overlay(
            RoundedRectangle(cornerRadius: cornerRadius)
              .stroke(color.opacity(isHovering ? 0.3 : 0.15), lineWidth: 1)
          )
      )
      .scaleEffect(isHovering ? 1.02 : 1.0)
      .shadow(color: isHovering ? color.opacity(0.15) : .clear, radius: 8)
      .animation(.easeOut(duration: 0.2), value: isHovering)
      .onHover { isHovering = $0 }
  }
}

extension View {
  /// Applies interactive card styling with hover effects.
  func interactiveCard(color: Color, cornerRadius: CGFloat = UIConstants.CornerRadius.medium) -> some View {
    modifier(InteractiveCardModifier(color: color, cornerRadius: cornerRadius))
  }
}

// MARK: - Animated Binding Extension

extension Binding where Value == Bool {
  /// Creates an animated binding that wraps state changes in animation.
  func animated(_ animation: Animation = .spring(response: 0.3, dampingFraction: 0.7)) -> Binding<Value> {
    Binding(
      get: { self.wrappedValue },
      set: { newValue in
        withAnimation(animation) {
          self.wrappedValue = newValue
        }
      }
    )
  }
}
