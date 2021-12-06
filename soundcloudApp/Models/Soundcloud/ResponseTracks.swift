//
//  CollectionTrack.swift
//  soundcloudApp
//
//  Created by pioner on 27.09.2021.
//

import Foundation

class ResponseTracks: Decodable {
    let collection: [Track]?
    let next_href: String?
}
