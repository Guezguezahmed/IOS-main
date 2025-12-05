import UIKit

extension UIImage {
    
    // Redimensionne l'image pour s'assurer qu'elle n'est pas trop lourde
    func resized(to maxDimension: CGFloat) -> UIImage? {
        let size = self.size
        
        // Si l'image est déjà petite, on la retourne telle quelle
        guard size.width > maxDimension || size.height > maxDimension else {
            return self
        }
        
        let ratio: CGFloat
        if size.width > size.height {
            ratio = maxDimension / size.width
        } else {
            ratio = maxDimension / size.height
        }
        
        let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        self.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
}
