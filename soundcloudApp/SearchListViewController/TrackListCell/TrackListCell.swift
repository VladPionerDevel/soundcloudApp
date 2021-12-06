//
//  SongListCell.swift
//  soundcloudApp
//
//  Created by pioner on 24.09.2021.
//

import UIKit

class TrackListCell: UITableViewCell {
    
    var track: Track? = nil
    
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var songNameLabel: UILabel!
    @IBOutlet weak var songAuthorLabel: UILabel!
    @IBOutlet weak var faviriteButton: UIButton!
    
    var trackFavoriteCoreData: TrackFavoriteCoreData!
    var trackFavorite: [Int:TrackFavorite] {
        return trackFavoriteCoreData.getAllTrackDict()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        coverImageView.image = UIImage(named: "logo_orange")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        songNameLabel.text = nil
        songAuthorLabel.text = nil
        coverImageView.image = UIImage(named: "logo_orange")
        
        faviriteButton.setBackgroundImage(UIImage(systemName: "heart"), for: .normal)
        faviriteButton.tintColor = UIColor.systemGray3
    }
    
    @IBAction func addToFavoriteTapped(_ sender: UIButton) {
        
        if let track = track {
            if let trackFavorite = trackFavorite[track.id] {
                trackFavoriteCoreData.removeTrack(track: trackFavorite)
                
                sender.setBackgroundImage(UIImage(systemName: "heart"), for: .normal)
                sender.tintColor = UIColor.systemGray3
            } else {
                var dataImage: Data? = nil
                if let _ = track.artworkUrl {
                    dataImage = coverImageView.image?.pngData()
                }
                trackFavoriteCoreData.addTrack(id: track.id, title: track.title, fullNmae:  track.user?.fullName, streamUrl: track.streamUrl, imageData: dataImage)
                
                sender.setBackgroundImage(UIImage(systemName: "heart.fill"), for: .normal)
                sender.tintColor = #colorLiteral(red: 1, green: 0.4244204164, blue: 0, alpha: 0.8470588235)
            }
        }
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
