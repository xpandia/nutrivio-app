// PhotoCaptureView.swift
// Nutrivio

import SwiftUI

struct PhotoCaptureView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var isAnalyzing = false
    @State private var showResult = false
    @State private var flashOn = false
    @State private var capturedImage = false

    var body: some View {
        NavigationStack {
            ZStack {
                // Camera preview placeholder
                Color.black
                    .ignoresSafeArea()

                if isAnalyzing {
                    analyzingOverlay
                } else if showResult {
                    resultOverlay
                } else {
                    cameraUI
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.title3)
                            .foregroundStyle(.white)
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        flashOn.toggle()
                    } label: {
                        Image(systemName: flashOn ? "bolt.fill" : "bolt.slash.fill")
                            .font(.title3)
                            .foregroundStyle(.white)
                    }
                }
            }
        }
    }

    // MARK: - Camera UI

    private var cameraUI: some View {
        VStack {
            Spacer()

            // Viewfinder frame
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .strokeBorder(.white.opacity(0.4), lineWidth: 2)
                    .frame(width: 300, height: 300)

                // Corner accents
                ForEach(0..<4, id: \.self) { corner in
                    CornerAccent()
                        .rotationEffect(.degrees(Double(corner) * 90))
                }

                VStack(spacing: 8) {
                    Image(systemName: "viewfinder")
                        .font(.system(size: 40))
                        .foregroundStyle(.white.opacity(0.5))

                    Text("Centra tu comida aqui")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.7))
                }
            }

            Spacer()

            // Tip
            HStack(spacing: 8) {
                Image(systemName: "sparkles")
                    .foregroundStyle(NutrivioTheme.primaryGreen)
                Text("La IA identificara los alimentos y calculara los macros")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.7))
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)

            // Capture controls
            HStack(spacing: 40) {
                // Gallery button
                Button {
                    // Open gallery
                } label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(.white.opacity(0.15))
                            .frame(width: 48, height: 48)
                        Image(systemName: "photo.on.rectangle")
                            .font(.title3)
                            .foregroundStyle(.white)
                    }
                }

                // Shutter button
                Button {
                    capturePhoto()
                } label: {
                    ZStack {
                        Circle()
                            .stroke(.white, lineWidth: 4)
                            .frame(width: 72, height: 72)

                        Circle()
                            .fill(.white)
                            .frame(width: 60, height: 60)
                    }
                }

                // Manual entry
                Button {
                    // Text search
                } label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(.white.opacity(0.15))
                            .frame(width: 48, height: 48)
                        Image(systemName: "text.magnifyingglass")
                            .font(.title3)
                            .foregroundStyle(.white)
                    }
                }
            }
            .padding(.bottom, 40)
        }
    }

    // MARK: - Analyzing Overlay

    private var analyzingOverlay: some View {
        VStack(spacing: 24) {
            Spacer()

            ZStack {
                // Scanning animation
                Circle()
                    .stroke(NutrivioTheme.primaryGreen.opacity(0.3), lineWidth: 3)
                    .frame(width: 120, height: 120)

                Circle()
                    .trim(from: 0, to: 0.3)
                    .stroke(NutrivioTheme.primaryGreen, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                    .frame(width: 120, height: 120)
                    .rotationEffect(.degrees(isAnalyzing ? 360 : 0))
                    .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: isAnalyzing)

                Image(systemName: "sparkles")
                    .font(.system(size: 36))
                    .foregroundStyle(NutrivioTheme.primaryGreen)
                    .pulse()
            }

            VStack(spacing: 8) {
                Text("Analizando tu comida...")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)

                Text("Identificando alimentos y calculando macros")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.6))
            }

            Spacer()
        }
    }

    // MARK: - Result Overlay

    private var resultOverlay: some View {
        VStack {
            Spacer()

            VStack(spacing: 16) {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundStyle(NutrivioTheme.emeraldGreen)

                    Text("Comida identificada")
                        .font(.headline)
                        .foregroundStyle(.white)

                    Spacer()
                }

                MealCardView(meal: .sampleLunch)
                    .padding(.horizontal, -16)

                HStack(spacing: 12) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Ajustar")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(.white.opacity(0.2))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }

                    Button {
                        dismiss()
                    } label: {
                        Text("Guardar")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(NutrivioTheme.primaryGreen)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
            }
            .padding(20)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .padding(16)
        }
    }

    // MARK: - Actions

    private func capturePhoto() {
        withAnimation {
            capturedImage = true
            isAnalyzing = true
        }

        // Simulate AI analysis
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation {
                isAnalyzing = false
                showResult = true
            }
        }
    }
}

// MARK: - Corner Accent

struct CornerAccent: View {
    var body: some View {
        VStack {
            HStack {
                Path { path in
                    path.move(to: CGPoint(x: 0, y: 20))
                    path.addLine(to: CGPoint(x: 0, y: 0))
                    path.addLine(to: CGPoint(x: 20, y: 0))
                }
                .stroke(NutrivioTheme.primaryGreen, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                .frame(width: 20, height: 20)

                Spacer()
            }
            Spacer()
        }
        .frame(width: 300, height: 300)
    }
}

#Preview {
    PhotoCaptureView()
}
