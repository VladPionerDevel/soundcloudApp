//
//  Song.swift
//  soundcloudApp
//
//  Created by pioner on 24.09.2021.
//

import Foundation

struct Track: Decodable {
    
    var id: Int
    var artworkUrl: String?
    var streamUrl: String?
    var title: String?
    let user: TrackUser?
    var authorName: String? {
        get {
            return user?.fullName
        }
        set {
            user?.fullName = newValue
        }
    }
    var imageData: Data? = nil
    
    
}

extension Track: PlayingTrackProtocol {
    
}
