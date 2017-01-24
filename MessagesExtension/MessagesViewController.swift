import UIKit
import Messages

class MessagesViewController: MSMessagesAppViewController {
    
    @IBOutlet fileprivate var activityIndicator: UIActivityIndicatorView!
    @IBOutlet fileprivate var collectionView: UICollectionView!
    
    fileprivate let BaseURL = URL(string: "http://213.32.69.32/m")!
    fileprivate let CellIdentifier = "MemeCollectionViewCell"
    
    fileprivate var items = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        collectionView.register(MemeCollectionViewCell.self, forCellWithReuseIdentifier: CellIdentifier)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchMemes()
    }
}

extension MessagesViewController {
    
    fileprivate func startSpinner() {
        DispatchQueue.main.async { [unowned self] in
            self.activityIndicator.startAnimating()
        }
    }
    
    fileprivate func stopSpinner() {
        DispatchQueue.main.async { [unowned self] in
            self.activityIndicator.stopAnimating()
        }
    }
    
    fileprivate func fetchMemes() {
        startSpinner()
        let url = self.BaseURL.appendingPathComponent("api/memes")
        ListOfMemes.download(url: url, completion: { [unowned self] list in
            self.items = list
            DispatchQueue.main.async { [unowned self] in
                self.collectionView.reloadData()
                self.stopSpinner()
            }
        })
    }
}

extension MessagesViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        startSpinner()
        collectionView.deselectItem(at: indexPath, animated: true)
        
        // Access asset
        let filename = items[indexPath.row]
        let remoteURL = self.BaseURL.appendingPathComponent(filename)
        let request = ImageAssetProviderRequest(remoteURL: remoteURL, filename: filename)
        ImageAssetProvider.requestImage(request: request, completion: { [unowned self] data, localURL in
            // Refresh the cell (thumbnail might be available
            DispatchQueue.main.async { [unowned self] in
                self.collectionView.reloadItems(at: [indexPath])
            }
            
            // Send attachement
            self.activeConversation?.insertAttachment(localURL, withAlternateFilename: filename, completionHandler: { error in
                if let error = error {
                    print("Cannot insert attachement, error: \(error.localizedDescription)")
                } else {
                    print("Inserted successfully")
                }
                self.stopSpinner()
            })
        })
    }
}

extension MessagesViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let cell = cell as! MemeCollectionViewCell
        let filename = items[indexPath.row]
        let thumbnail = ImageAssetProvider.requestThumbnail(filename: filename)
        cell.configure(filename: filename, thumbnail: thumbnail)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifier, for: indexPath) as! MemeCollectionViewCell
        return cell
    }
}

extension MessagesViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100, height: 100)
    }
}
