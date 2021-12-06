//
//  FavoriteTracksModels.swift
//  soundcloudApp
//
//  Created by pioner on 15.10.2021.
//  Copyright (c) 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

enum FavoriteTracks {
   
  enum Model {
    struct Request {
      enum RequestType {
        case getTracksFavorite
        case removeFromFavorite(trackId: Int, playerViewControllr: PlayerViewController?, isSelfPlayerDelegate: Bool)
        case setPlayerTrackList(playerViewControllr: PlayerViewController)
        case setNewOrder(order: [Int])
      }
    }
    struct Response {
      enum ResponseType {
        case presentTracksFavorite(tracks: [TrackFavorite])
      }
    }
    struct ViewModel {
      enum ViewModelData {
        case displayFavoriteTraks(trackFavoriteViewModel: TrackFavoriteViewModel)
      }
    }
  }
  
}

struct TrackFavoriteViewModel {
    struct Cell: TrackFavoriteCellViewModel {
        var id: Int
        var coverImageData: Data?
        var songName: String
        var songAurhor: String
    }
    let cells: [Cell]
}
