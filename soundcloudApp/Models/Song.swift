//
//  Song.swift
//  soundcloudApp
//
//  Created by pioner on 24.09.2021.
//

import Foundation

struct Track: Codable {
    let artworkUrl: String?
    let title: String?
    let user: SongUser?
    
}
