// NutrivioAnimations.swift
// Nutrivio

import SwiftUI

struct NutrivioAnimations {
    // MARK: - Timing
    static let springBouncy = Animation.spring(response: 0.5, dampingFraction: 0.7, blendDuration: 0)
    static let springSmooth = Animation.spring(response: 0.6, dampingFraction: 0.85, blendDuration: 0)
    static let easeOutQuick = Animation.easeOut(duration: 0.3)
    static let easeInOutMedium = Animation.easeInOut(duration: 0.5)
    static let ringFill = Animation.easeInOut(duration: 1.2)
    static let staggerDelay: Double = 0.08

    // MARK: - Transitions
    static let slideUp = AnyTransition.asymmetric(
        insertion: .move(edge: .bottom).combined(with: .opacity),
        removal: .move(edge: .top).combined(with: .opacity)
    )

    static let scaleIn = AnyTransition.scale(scale: 0.8).combined(with: .opacity)
}

// MARK: - Shimmer Effect

struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geometry in
                    LinearGradient(
                        colors: [
                            .clear,
                            .white.opacity(0.3),
                            .clear
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: geometry.size.width * 0.5)
                    .offset(x: -geometry.size.width * 0.5 + phase * geometry.size.width * 1.5)
                }
            )
            .clipped()
            .onAppear {
                withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                    phase = 1
                }
            }
    }
}

// MARK: - Pulse Effect

struct PulseModifier: ViewModifier {
    @State private var isPulsing = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(isPulsing ? 1.05 : 1.0)
            .animation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true), value: isPulsing)
            .onAppear { isPulsing = true }
    }
}

extension View {
    func shimmer() -> some View {
        modifier(ShimmerModifier())
    }

    func pulse() -> some View {
        modifier(PulseModifier())
    }
}

// MARK: - Staggered Appearance

struct StaggeredAppearance: ViewModifier {
    let index: Int
    @State private var isVisible = false

    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .offset(y: isVisible ? 0 : 20)
            .onAppear {
                withAnimation(NutrivioAnimations.springSmooth.delay(Double(index) * NutrivioAnimations.staggerDelay)) {
                    isVisible = true
                }
            }
    }
}

extension View {
    func staggered(index: Int) -> some View {
        modifier(StaggeredAppearance(index: index))
    }
}
