//
//  TrackFavoriteCoreData.swift
//  soundcloudApp
//
//  Created by pioner on 12.10.2021.
//

import Foundation
import CoreData

class TrackFavoriteCoreData {
    
    let context = CoreDataStack.share.persistentContainer.viewContext
    
    func getAllTrack() -> [TrackFavorite] {
        
        let fetchRequest = NSFetchRequest<TrackFavorite>(entityName: String(describing: TrackFavorite.self))
        
        do {
            return try context.fetch(fetchRequest)
        } catch {
            print(error.localizedDescription)
            return []
        }
    }
    
    func getAllTrackDict() -> [Int:TrackFavorite] {
        let allTrack = getAllTrack()
        
        if allTrack.count > 0 {
            var allTrackDict = [Int:TrackFavorite]()
            allTrack.forEach { (track) in
                allTrackDict[Int(track.id)] = track
            }
            
            return allTrackDict
        } else {
            return [:]
        }
    }
    
    func addTrack(id: Int?,title: String?,fullNmae: String?,streamUrl: String?,imageData: Data?) {
        
        guard let id = id else { return }
        
        let track = NSEntityDescription.insertNewObject(forEntityName: String(describing: TrackFavorite.self), into: context) as? TrackFavorite
        
        track?.id = id
        track?.title = title
        track?.streamUrl = streamUrl
        track?.imageData = imageData
        track?.authorName = fullNmae
        
        saveContext()
    }
    
    func isFovoriteTrack(id: Int) -> Bool {
        let tacksDict = getAllTrackDict()
        return tacksDict[id] != nil ? true : false
    }
    
    func removeTrack(track: TrackFavorite) {
        context.delete(track)
        saveContext()
    }
    
    func removeTrackById(trackId: Int) -> Bool {
        let fetchRequest = NSFetchRequest<TrackFavorite>(entityName: String(describing: TrackFavorite.self))
        fetchRequest.predicate = NSPredicate(format: "id == %d", trackId)
        
        do {
            let tracks = try context.fetch(fetchRequest)
            if tracks.count > 0, let track = tracks.first {
                removeTrack(track: track)
                return true
            } else {
                return false
            }
        } catch {
            return false
        }
    }
    
    func saveContext(){
        CoreDataStack.share.saveContext()
    }
}
