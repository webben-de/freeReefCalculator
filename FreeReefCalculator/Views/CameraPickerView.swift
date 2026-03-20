import SwiftUI
import UIKit

/// Wraps UIImagePickerController for in-app camera capture.
/// Uses @Binding for dismissal to avoid Swift 6 @MainActor isolation issues.
struct CameraPickerView: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    let onImagePicked: (Data) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(isPresented: $isPresented, onImagePicked: onImagePicked)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.cameraCaptureMode = .photo
        picker.allowsEditing = false
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    @MainActor
    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        @Binding var isPresented: Bool
        let onImagePicked: (Data) -> Void

        init(isPresented: Binding<Bool>, onImagePicked: @escaping (Data) -> Void) {
            _isPresented = isPresented
            self.onImagePicked = onImagePicked
        }

        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage,
               let data = image.jpegData(compressionQuality: 0.8) {
                onImagePicked(data)
            }
            isPresented = false
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            isPresented = false
        }
    }
}

/// Returns true if the device has a rear or front camera.
var isCameraAvailable: Bool {
    UIImagePickerController.isSourceTypeAvailable(.camera)
}
