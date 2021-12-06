//
//  TrackFavoriteCell.swift
//  soundcloudApp
//
//  Created by pioner on 15.10.2021.
//

import UIKit

protocol TrackFavoriteCellViewModel {
    var id: Int { get }
    var coverImageData: Data? { get }
    var songName: String { get }
    var songAurhor: String { get }
}

class TrackFavoriteCell: UITableViewCell {
    
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var songNameLabel: UILabel!
    @IBOutlet weak var songAuthorLabel: UILabel!
    @IBOutlet weak var faviriteButton: UIButton!
    
    var removeFromFavorite: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        coverImageView.image = UIImage(named: "logo_orange")
    }
    
    func set(viewModel: TrackFavoriteCellViewModel){
        
        if let imageData = viewModel.coverImageData{
            self.coverImageView.image = UIImage(data: imageData)
        }
        
        self.songNameLabel.text = viewModel.songName
        self.songAuthorLabel.text = viewModel.songAurhor
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        songNameLabel.text = nil
        songAuthorLabel.text = nil
        coverImageView.image = UIImage(named: "logo_orange")
        
        faviriteButton.setBackgroundImage(UIImage(systemName: "heart.fill"), for: .normal)
        faviriteButton.tintColor = #colorLiteral(red: 1, green: 0.4244204164, blue: 0, alpha: 0.8470588235)
    }
    
    @IBAction func removeFavoriteTapped(_ sender: UIButton) {
        guard let removeFromFavorite = removeFromFavorite else {return}
        removeFromFavorite()
    }
    
    
}
