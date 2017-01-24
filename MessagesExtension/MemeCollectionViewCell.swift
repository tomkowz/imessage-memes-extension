import UIKit

final class MemeCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet fileprivate var filenameLabel: UILabel!
    @IBOutlet fileprivate var thumbnailView: UIImageView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        filenameLabel.text = "<invalidated>"
        thumbnailView.image = nil
    }
    
    func configure(filename: String, thumbnail: UIImage?) {
        filenameLabel.text = filename
        thumbnailView.image = thumbnail
    }
}
