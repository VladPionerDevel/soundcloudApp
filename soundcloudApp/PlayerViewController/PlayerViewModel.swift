//
//  Player.swift
//  soundcloudApp
//
//  Created by pioner on 29.09.2021.
//

import Foundation
import AVKit

protocol PlayerViewModelDelegate {
    func initializationPlayer(playing: PlayerViewModel, player: AVPlayer,playerItem: AVPlayerItem)
    func playerPlay(playing: PlayerViewModel)
    func playerPause()
}

class PlayerViewModel {
    
    let trackFavoriteCoreData = TrackFavoriteCoreData()
    
    var player: AVPlayer?
    var playerItem: AVPlayerItem?
    
    var trackList = TrakListCollection<PlayingTrack>()
    var trackActiveInddexPath: IndexPath?
    {
        willSet {
            var track: PlayingTrack? = nil
            if let newIndexPath = newValue {
                if newIndexPath.row < trackList.list.count {
                    track = trackList.list[newIndexPath.row]
                }
            }
            self.playingTrack = track
        }
    }
    
    var orderRandome: Bool {
        get {
            return trackList.orderRandome
        } set {
            guard let trackId = playingTrack?.id else {return}
            trackList.orderRandome = newValue
            trackActiveInddexPath = searchTrackActiveInddexPath(trackId: trackId)
        }
    }
    
    var playingTrack: PlayingTrack? = nil
    
    var isFavoritePlayingTrack: Bool {
        get {
            guard let playingTrack = playingTrack else {return false}
            return trackFavoriteCoreData.isFovoriteTrack(id: playingTrack.id)
        }
    }

    var plaingObservers = NSMutableSet()
    var delegate: PlayerViewModelDelegate?

    var headers: [String: String] = [:]
    
    private var attemptGetAsset = 0

    func setupPlayer(completionHandler: @escaping ()->Void){
        
        self.setPlayerAndPlayerItem { [weak self] in
            guard let player = self?.player, let playerItem = self?.playerItem else {return}
            
            DispatchQueue.main.async {
                self?.delegate?.initializationPlayer(playing: self!, player: player, playerItem: playerItem)
                completionHandler()
            }
        }
    }
    
    func play(){
        guard let player = self.player else {return}
        
        player.play()
        delegate?.playerPlay(playing: self)
    }
    
    func setupPlayerAndPlay(){
        
        setupPlayer {
            self.play()
        }
    }
    
    func pause(){
        guard let player = self.player else {return}
        
        player.pause()
        delegate?.playerPause()
    }
    
    func prevPlay(){
        guard let indexPath = self.trackActiveInddexPath, indexPath.row != 0 else {return}
        
        self.trackActiveInddexPath?.row -= 1
        self.setupPlayer(){}
        self.play()
        
    }
    
    func nextPlay(){
        guard let indexPath = self.trackActiveInddexPath, indexPath.row < (self.trackList.list.count - 1) else {return}
        
        self.trackActiveInddexPath?.row += 1
        self.setupPlayer(){}
        self.play()
        
    }
    
    func addToFavorite(imageData: Data?){
        var imageData = imageData
        
        if playingTrack?.imageData == nil,  playingTrack?.artworkUrl == nil {
            imageData = nil
        }
        trackFavoriteCoreData.addTrack(id:playingTrack?.id,title: playingTrack?.title,fullNmae: playingTrack?.authorName,streamUrl: playingTrack?.streamUrl,imageData: imageData)
    }
    
    func removeFromFavorite(){
        guard let playingTrack = playingTrack else  {return}
        let _ = trackFavoriteCoreData.removeTrackById(trackId: playingTrack.id)
    }
    
    private func setupHeaders(token: String){
        self.headers = [
            "accept": "application/json; charset=utf-8",
            "authorization": "OAuth \(token)"
        ]
    }
    
    private func setPlayerAndPlayerItem(completionHandler: @escaping ()->Void ){
        guard let token = SoundCloudNetworking.shared.getSavedToken(),
              let indexPath = self.trackActiveInddexPath,
              let urlString =  self.trackList.list[indexPath.row].streamUrl,
              let url = URL.init(string: urlString)
        else {return}
        
        setupHeaders(token: token)
        
        let asset = AVURLAsset(url: url, options: ["AVURLAssetHTTPHeaderFieldsKey": self.headers])
        
        let assetLength = Float(asset.duration.value)/Float(asset.duration.timescale)
        
        if assetLength > 0 {
            self.playerItem = AVPlayerItem(asset: asset)
            self.player = AVPlayer(playerItem: self.playerItem)
            
            guard let _ = self.player, let _ = self.playerItem else {return}
            completionHandler()
            
        } else {
            
            if self.attemptGetAsset <= 3  {
                self.attemptGetAsset += 1
                
                SoundCloudNetworking.shared.getToken { [weak self] in
                    self?.setPlayerAndPlayerItem(completionHandler: completionHandler)
                }
            }
            self.attemptGetAsset = 0
        }
        
    }
    
    private func searchTrackActiveInddexPath(trackId: Int) -> IndexPath? {
        
        for (index, val) in trackList.order.enumerated() {
            if val == trackId {
                return IndexPath(row: index, section: 0)
            }
        }
        
        return self.trackActiveInddexPath
    }
    
    
}
