import Foundation

final class ListOfMemes {
    
    static func download(url: URL, completion: @escaping ([String]) -> Void) {
        DispatchQueue.global().async {
            let session = URLSession.shared
            session.dataTask(with: url) { data, response, error in
                var list = [String]()
                let json = try! JSONSerialization.jsonObject(with: data!, options: .mutableLeaves) as! [String: AnyObject]
                
                for meme in json["memes"] as! [[String: AnyObject]] {
                    let filename = meme["filename"] as! String
                    list.append(filename)
                }
                
                completion(list)
                
                }.resume()
        }
    }
}
