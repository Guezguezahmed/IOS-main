// Fichier : ImagePicker.swift

import UIKit
import SwiftUI

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    // Utilise la méthode moderne pour fermer la vue
    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        // Assurez-vous que le délégué est défini pour recevoir la photo sélectionnée
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        init(_ parent: ImagePicker) { self.parent = parent }

        // Lorsque l'utilisateur sélectionne une image
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage // Stocke l'image dans le Binding
            }
            parent.dismiss() // Ferme le sélecteur
        }

        // Lorsque l'utilisateur annule
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss() // Ferme le sélecteur
        }
    }
}
