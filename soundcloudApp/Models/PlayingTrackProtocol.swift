//
//  PlayingTrackProtocol.swift
//  soundcloudApp
//
//  Created by pioner on 07.11.2021.
//

import Foundation

protocol PlayingTrackProtocol: IdentifiableInt {
    var id: Int { get set }
    var streamUrl: String? { get set }
    var title: String? { get set }
    var authorName: String? { get set }
    var imageData: Data? { get set }
    var artworkUrl: String? { get set }
}
