//
//  FavoriteTracksInteractor.swift
//  soundcloudApp
//
//  Created by pioner on 15.10.2021.
//  Copyright (c) 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

protocol FavoriteTracksBusinessLogic {
    func makeRequest(request: FavoriteTracks.Model.Request.RequestType)
}

class FavoriteTracksInteractor: FavoriteTracksBusinessLogic {
    
    var presenter: FavoriteTracksPresentationLogic?
    var service: FavoriteTracksService?
    
    let trackCoreData = TrackFavoriteCoreData()
    var trackList = TrakListCollection<TrackFavorite>()
    
    func makeRequest(request: FavoriteTracks.Model.Request.RequestType) {
        if service == nil {
            service = FavoriteTracksService()
        }
        
        switch request {
        case .getTracksFavorite:
            self.trackList.setList(from: trackCoreData.getAllTrack())
            self.presenter?.presentData(response: FavoriteTracks.Model.Response.ResponseType.presentTracksFavorite(tracks: self.trackList.list))
            
        case .removeFromFavorite(let trackId, let playerViewControllr, let isSelfPlayerDelegate):
            if trackCoreData.removeTrackById(trackId: trackId) {
                self.trackList.setList(from: trackCoreData.getAllTrack())
                self.presenter?.presentData(response: FavoriteTracks.Model.Response.ResponseType.presentTracksFavorite(tracks: self.trackList.list))
                if isSelfPlayerDelegate  {
                    playerViewControllr?.setList(tracks: self.trackList.list)
                }
            }
        case .setPlayerTrackList(playerViewControllr: let playerViewControllr):
            self.trackList.setList(from: trackCoreData.getAllTrack())
            playerViewControllr.setList(tracks: self.trackList.list)
        case .setNewOrder(let order):
            if trackList.setOrder(from: order) {
                self.presenter?.presentData(response: FavoriteTracks.Model.Response.ResponseType.presentTracksFavorite(tracks: self.trackList.list))
            }
        }
        
    }
    
}
