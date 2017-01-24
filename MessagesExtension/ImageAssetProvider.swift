import UIKit

final class ImageAssetProviderRequest {
    
    let remoteURL: URL
    let filename: String
    
    init(remoteURL: URL, filename: String) {
        self.remoteURL = remoteURL
        self.filename = filename
    }
}

final class ImageAssetProvider {
    
    static func requestImage(request: ImageAssetProviderRequest, completion: @escaping (_ data: Data, _ localURL: URL) -> Void) {
        // Is the asset available locally?
        let localURL = getStorageURL().appendingPathComponent(request.filename)!
        do {
            let data = try Data(contentsOf: localURL)
            print("\(request.filename) accessed locally")
            completion(data, localURL)
        } catch {
            // Download remote asset
            print("Downloading - \(request.remoteURL)")
            let session = URLSession.shared
            session.dataTask(with: request.remoteURL) { data, response, error in
                if let error = error {
                    print("Error downloading asset: \(error.localizedDescription) - \(request.remoteURL)")
                }
                
                guard let data = data else { return }
                let image = UIImage(data: data)!
                store(data: data, filename: request.filename)

                let thumbnail = ThumbnailFromImage.create(with: image)
                storeThumbnail(data: UIImageJPEGRepresentation(thumbnail, 0.95)!, filename: request.filename)
                
                completion(data, localURL)
                
            }.resume()
        }
    }
    
    static func requestThumbnail(filename: String) -> UIImage? {
        let localURL = thumbnailURL(for: filename)
        do {
            let data = try Data(contentsOf: localURL)
            return UIImage(data: data)
        } catch {
            return nil
        }
    }
    
    private static func getStorageURL() -> NSURL {
        let dir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        let url = NSURL(fileURLWithPath: dir)
        return url
    }
    
    private static func store(data: Data, filename: String) {
        let url = getStorageURL().appendingPathComponent(filename)!
        try! data.write(to: url)
    }
    
    private static func storeThumbnail(data: Data, filename: String) {
        try! data.write(to: thumbnailURL(for: filename))
    }
    
    private static func thumbnailURL(for filename: String) -> URL {
        return getStorageURL().appendingPathComponent("thumbnail-" + filename)!
    }
}
