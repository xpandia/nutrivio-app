// CameraService.swift
// Nutrivio — AVFoundation camera wrapper for food photo capture

import Foundation
import AVFoundation
import SwiftUI

class CameraService: NSObject, ObservableObject {
    @Published var capturedImage: Data?
    @Published var isSessionRunning = false
    @Published var error: CameraError?
    @Published var flashMode: AVCaptureDevice.FlashMode = .auto

    let session = AVCaptureSession()
    private var photoOutput = AVCapturePhotoOutput()
    private var captureCompletion: ((Data?) -> Void)?

    // MARK: - Setup

    func setupSession() {
        guard AVCaptureDevice.authorizationStatus(for: .video) == .authorized ||
              AVCaptureDevice.authorizationStatus(for: .video) == .notDetermined else {
            error = .notAuthorized
            return
        }

        session.beginConfiguration()
        session.sessionPreset = .photo

        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let input = try? AVCaptureDeviceInput(device: camera) else {
            error = .cameraUnavailable
            session.commitConfiguration()
            return
        }

        if session.canAddInput(input) {
            session.addInput(input)
        }

        if session.canAddOutput(photoOutput) {
            session.addOutput(photoOutput)
        }

        session.commitConfiguration()
    }

    func startSession() {
        guard !session.isRunning else { return }
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.session.startRunning()
            DispatchQueue.main.async {
                self?.isSessionRunning = true
            }
        }
    }

    func stopSession() {
        guard session.isRunning else { return }
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.session.stopRunning()
            DispatchQueue.main.async {
                self?.isSessionRunning = false
            }
        }
    }

    // MARK: - Capture

    func capturePhoto() async -> Data? {
        return await withCheckedContinuation { continuation in
            captureCompletion = { data in
                continuation.resume(returning: data)
            }

            let settings = AVCapturePhotoSettings()
            settings.flashMode = flashMode
            photoOutput.capturePhoto(with: settings, delegate: self)
        }
    }

    // MARK: - Permissions

    func requestPermission() async -> Bool {
        let status = AVCaptureDevice.authorizationStatus(for: .video)

        switch status {
        case .authorized:
            return true
        case .notDetermined:
            return await AVCaptureDevice.requestAccess(for: .video)
        default:
            return false
        }
    }
}

// MARK: - AVCapturePhotoCaptureDelegate

extension CameraService: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard error == nil, let imageData = photo.fileDataRepresentation() else {
            captureCompletion?(nil)
            captureCompletion = nil
            return
        }

        DispatchQueue.main.async { [weak self] in
            self?.capturedImage = imageData
            self?.captureCompletion?(imageData)
            self?.captureCompletion = nil
        }
    }
}

// MARK: - Camera Preview (UIViewRepresentable)

struct CameraPreview: UIViewRepresentable {
    let session: AVCaptureSession

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        context.coordinator.previewLayer = previewLayer
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        context.coordinator.previewLayer?.frame = uiView.bounds
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator {
        var previewLayer: AVCaptureVideoPreviewLayer?
    }
}

// MARK: - Camera Error

enum CameraError: LocalizedError {
    case notAuthorized
    case cameraUnavailable
    case captureError

    var errorDescription: String? {
        switch self {
        case .notAuthorized: return "Se necesita permiso para acceder a la camara"
        case .cameraUnavailable: return "La camara no esta disponible"
        case .captureError: return "Error al capturar la foto"
        }
    }
}
