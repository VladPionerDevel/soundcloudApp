//
//  FavoriteTracksPresenter.swift
//  soundcloudApp
//
//  Created by pioner on 15.10.2021.
//  Copyright (c) 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

protocol FavoriteTracksPresentationLogic {
  func presentData(response: FavoriteTracks.Model.Response.ResponseType)
}

class FavoriteTracksPresenter: FavoriteTracksPresentationLogic {
  weak var viewController: FavoriteTracksDisplayLogic?
  
  func presentData(response: FavoriteTracks.Model.Response.ResponseType) {
  
    switch response {
    
    case .presentTracksFavorite(let tracksFavorite):
        
        let cells = tracksFavorite.map { (track)  in
            cellViewModel(tracksFavorite: track)
        }

        let tracksFavoriteViewModel = TrackFavoriteViewModel.init(cells: cells)
        viewController?.displayData(viewModel: FavoriteTracks.Model.ViewModel.ViewModelData.displayFavoriteTraks(trackFavoriteViewModel: tracksFavoriteViewModel))
    
    }
  }
    
    private func cellViewModel(tracksFavorite: TrackFavorite) -> TrackFavoriteViewModel.Cell {
        let id = tracksFavorite.id
        let cover = tracksFavorite.imageData
        let name = tracksFavorite.title ?? ""
        let author = tracksFavorite.authorName ?? ""
        return TrackFavoriteViewModel.Cell.init(id: Int(id), coverImageData: cover, songName: name, songAurhor: author)
    }
    
  
}
