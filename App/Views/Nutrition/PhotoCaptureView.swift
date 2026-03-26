// PhotoCaptureView.swift
// Nutrivio

import SwiftUI
import SwiftData

struct PhotoCaptureView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var nutritionVM: NutritionViewModel
    @Environment(\.modelContext) private var modelContext

    @StateObject private var cameraService = CameraService()
    @State private var isAnalyzing = false
    @State private var showResult = false
    @State private var flashOn = false
    @State private var cameraPermissionGranted = false
    @State private var scanningRotation: Double = 0

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                // Live camera preview (fills background)
                if cameraPermissionGranted {
                    CameraPreview(session: cameraService.session)
                        .ignoresSafeArea()
                }

                // Overlaid states
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
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .font(.title3)
                            .foregroundStyle(.white)
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        flashOn.toggle()
                        cameraService.flashMode = flashOn ? .on : .auto
                    } label: {
                        Image(systemName: flashOn ? "bolt.fill" : "bolt.slash.fill")
                            .font(.title3)
                            .foregroundStyle(.white)
                    }
                }
            }
        }
        .task {
            nutritionVM.configure(modelContext: modelContext)
            cameraPermissionGranted = await cameraService.requestPermission()
            if cameraPermissionGranted {
                cameraService.setupSession()
                cameraService.startSession()
            }
        }
        .onDisappear {
            cameraService.stopSession()
        }
    }

    // MARK: - Camera UI

    private var cameraUI: some View {
        VStack {
            Spacer()

            if cameraPermissionGranted {
                // Viewfinder frame with corner accents
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .strokeBorder(.white.opacity(0.35), lineWidth: 1.5)
                        .frame(width: 280, height: 280)

                    ForEach(0..<4, id: \.self) { corner in
                        CornerAccent()
                            .rotationEffect(.degrees(Double(corner) * 90))
                    }

                    VStack(spacing: 8) {
                        Image(systemName: "viewfinder")
                            .font(.system(size: 36))
                            .foregroundStyle(.white.opacity(0.4))

                        Text("Centra tu comida aqui")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.6))
                    }
                }
            } else {
                // Permission denied — show a clear message
                VStack(spacing: 20) {
                    Image(systemName: "camera.fill")
                        .font(.system(size: 52))
                        .foregroundStyle(.white.opacity(0.4))

                    Text("Se necesita acceso a la camara")
                        .font(.headline)
                        .foregroundStyle(.white)

                    Text("Ve a Ajustes → Privacidad → Camara y activa el permiso para Nutrivio.")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.65))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)

                    Button {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    } label: {
                        Text("Abrir Ajustes")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(NutrivioTheme.primaryGreen)
                            .clipShape(Capsule())
                    }
                }
            }

            Spacer()

            HStack(spacing: 8) {
                Image(systemName: "sparkles")
                    .foregroundStyle(NutrivioTheme.primaryGreen)
                Text("La IA identificara los alimentos y calculara los macros")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.7))
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)

            // Controls — only shown when permission is granted
            if cameraPermissionGranted {
                HStack(spacing: 40) {
                    // Gallery placeholder
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(.white.opacity(0.15))
                            .frame(width: 48, height: 48)
                        Image(systemName: "photo.on.rectangle")
                            .font(.title3)
                            .foregroundStyle(.white)
                    }

                    // Shutter button
                    Button {
                        Task { await captureAndAnalyze() }
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
                    .scaleEffect(isAnalyzing ? 0.9 : 1.0)
                    .animation(NutrivioAnimations.springSmooth, value: isAnalyzing)

                    // Manual entry
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(.white.opacity(0.15))
                            .frame(width: 48, height: 48)
                        Image(systemName: "text.magnifyingglass")
                            .font(.title3)
                            .foregroundStyle(.white)
                    }
                }
                .padding(.bottom, 40)
            } else {
                Spacer().frame(height: 112)
            }
        }
    }

    // MARK: - Analyzing Overlay

    private var analyzingOverlay: some View {
        VStack(spacing: 24) {
            Spacer()

            ZStack {
                // Outer static ring
                Circle()
                    .stroke(NutrivioTheme.primaryGreen.opacity(0.15), lineWidth: 3)
                    .frame(width: 160, height: 160)

                // Middle pulsing ring
                Circle()
                    .stroke(NutrivioTheme.primaryGreen.opacity(0.25), lineWidth: 2)
                    .frame(width: 120, height: 120)
                    .pulse()

                // Inner spinning arc
                Circle()
                    .trim(from: 0, to: 0.3)
                    .stroke(NutrivioTheme.primaryGreen, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                    .frame(width: 120, height: 120)
                    .rotationEffect(.degrees(scanningRotation))
                    .onAppear {
                        withAnimation(.linear(duration: 1).repeatForever(autoreverses: false)) {
                            scanningRotation = 360
                        }
                    }

                // Center icon
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
                    .multilineTextAlignment(.center)
            }

            Spacer()
        }
        .transition(.opacity.combined(with: .scale))
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

                    Button {
                        withAnimation {
                            showResult = false
                            nutritionVM.analysisResult = nil
                        }
                    } label: {
                        Image(systemName: "arrow.counterclockwise")
                            .foregroundStyle(.white.opacity(0.7))
                    }
                }

                if let meal = nutritionVM.analysisResult {
                    MealCardView(meal: meal)
                }

                HStack(spacing: 12) {
                    Button {
                        withAnimation {
                            showResult = false
                            nutritionVM.analysisResult = nil
                        }
                    } label: {
                        Text("Reintentar")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(.white.opacity(0.18))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }

                    Button {
                        saveMealAndDismiss()
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
        .transition(NutrivioAnimations.slideUp)
    }

    // MARK: - Actions

    private func captureAndAnalyze() async {
        // Try real camera capture; fall back to a sample data blob for simulator
        let imageData: Data
        if let captured = await cameraService.capturePhoto() {
            imageData = captured
        } else {
            imageData = Data()
        }

        withAnimation { isAnalyzing = true }
        await nutritionVM.analyzePhoto(imageData: imageData)
        withAnimation {
            isAnalyzing = false
            showResult = true
        }
    }

    private func saveMealAndDismiss() {
        if let meal = nutritionVM.analysisResult {
            nutritionVM.addMeal(meal)
            nutritionVM.analysisResult = nil
        }
        dismiss()
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
        .frame(width: 280, height: 280)
    }
}

#Preview {
    PhotoCaptureView()
        .environmentObject(NutritionViewModel())
}
