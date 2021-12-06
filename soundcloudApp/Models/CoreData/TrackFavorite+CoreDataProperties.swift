//
//  TrackFavorite+CoreDataProperties.swift
//  soundcloudApp
//
//  Created by pioner on 28.10.2021.
//
//

import Foundation
import CoreData


extension TrackFavorite {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TrackFavorite> {
        return NSFetchRequest<TrackFavorite>(entityName: "TrackFavorite")
    }

    @NSManaged public var artworkUrl: String?
    @NSManaged public var id: Int
    @NSManaged public var imageData: Data?
    @NSManaged public var streamUrl: String?
    @NSManaged public var title: String?
    @NSManaged public var authorName: String?

}

extension TrackFavorite : IdentifiableInt {

}

extension TrackFavorite: PlayingTrackProtocol {
    
}
