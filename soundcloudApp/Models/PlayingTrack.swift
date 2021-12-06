//
//  PlayingTrack.swift
//  soundcloudApp
//
//  Created by pioner on 28.10.2021.
//

import Foundation

class PlayingTrack: IdentifiableInt, PlayingTrackProtocol {
    var id: Int
    var streamUrl: String?
    var title: String?
    var authorName: String?
    var imageData: Data?
    var artworkUrl: String?
    
    init(id: Int, streamUrl: String?, title: String?, authorName: String?, imageData: Data?, artworkUrl: String?) {
        self.id = id
        self.streamUrl = streamUrl
        self.title = title
        self.authorName = authorName
        self.imageData = imageData
        self.artworkUrl = artworkUrl
    }
    
    convenience init(trackProtocol: PlayingTrackProtocol){
        self.init(
                    id: trackProtocol.id,
                    streamUrl: trackProtocol.streamUrl,
                    title: trackProtocol.title,
                    authorName: trackProtocol.authorName,
                    imageData: trackProtocol.imageData,
                    artworkUrl: trackProtocol.artworkUrl
        )
    }
}

