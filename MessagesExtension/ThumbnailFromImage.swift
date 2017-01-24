import UIKit

final class ThumbnailFromImage {
    
    static func create(with image: UIImage, requestedWidth: CGFloat = 100) -> UIImage {
        let scale = max(requestedWidth / image.size.width, requestedWidth / image.size.height)
        let width = image.size.width * scale
        let height = image.size.height * scale
        
        let rect = CGRect(x: (requestedWidth - width) / 2.0,
                          y: (requestedWidth - height) / 2.0,
                          width: width, height: height)
        
        UIGraphicsBeginImageContext(CGSize(width: requestedWidth, height: requestedWidth))
        image.draw(in: rect)
        let thumbnail = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return thumbnail
    }
}
