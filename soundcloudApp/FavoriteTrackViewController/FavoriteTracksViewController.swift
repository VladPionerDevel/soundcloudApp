//
//  FavoriteTracksViewController.swift
//  soundcloudApp
//
//  Created by pioner on 15.10.2021.
//  Copyright (c) 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit
import Combine

protocol FavoriteTracksDisplayLogic: class {
    func displayData(viewModel: FavoriteTracks.Model.ViewModel.ViewModelData)
}

class FavoriteTracksViewController: UIViewController, FavoriteTracksDisplayLogic {
    
    var interactor: FavoriteTracksBusinessLogic?
    
    private var trackFavoriteViewModel = TrackFavoriteViewModel.init(cells: [])
    
    @IBOutlet weak var tableViewFavoriteTracks: UITableView!
    @IBOutlet weak var tableViewFavoriteTracksBottomConstraint: NSLayoutConstraint!
    
    let identifireCell = String(describing: TrackFavoriteCell.self)
    
    var playerViewController: PlayerViewController?
    
    var subscriptions: AnyCancellable?
    
    // MARK: Setup
    
    private func setup() {
        let viewController        = self
        let interactor            = FavoriteTracksInteractor()
        let presenter             = FavoriteTracksPresenter()
        viewController.interactor = interactor
        interactor.presenter      = presenter
        presenter.viewController  = viewController
    }
    
    // MARK: View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.playerViewController = (self.tabBarController as? TabBarController)?.playerViewController
        
        setup()
        
        setupTableView()
        
        subscriptions = playerViewController?.addToFavoriteEvent.sink { [weak self] _ in
            if let playerViewController = self?.playerViewController {
                self?.interactor?.makeRequest(request: .getTracksFavorite)
                if playerViewController.delegate === self {
                    self?.interactor?.makeRequest(request: .setPlayerTrackList(playerViewControllr: playerViewController))
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        interactor?.makeRequest(request: .getTracksFavorite)
        if self.playerViewController?.delegate === self, let indexPath = self.playerViewController?.getActiveTrackIndexPath() {
            self.tableViewFavoriteTracks.selectRow(at: indexPath, animated: false, scrollPosition: .none)
            interactor?.makeRequest(request: .setPlayerTrackList(playerViewControllr: playerViewController!))
        }
    }
    
    func displayData(viewModel: FavoriteTracks.Model.ViewModel.ViewModelData) {
        
        switch viewModel {
        
        case .displayFavoriteTraks(let trackFavoriteViewModel):
            self.trackFavoriteViewModel = trackFavoriteViewModel
            tableViewFavoriteTracks.reloadData()
        }
    }
    
    func removeTrackFromFavorite(trackFavoriteViewModel: TrackFavoriteViewModel.Cell) {
        let alert = UIAlertController(title: "Remove From Favorite", message: "Are you sure you want to remove \"\(trackFavoriteViewModel.songName)\" from your favorites", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { _ in
            let isSelfPlayerDelegate = self.playerViewController?.delegate === self
            self.interactor?.makeRequest(request: .removeFromFavorite(trackId: trackFavoriteViewModel.id, playerViewControllr: self.playerViewController, isSelfPlayerDelegate: isSelfPlayerDelegate))
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert,animated: true)
    }
    
    private func setupTableView(){
        let nib = UINib(nibName: identifireCell, bundle: nil)
        tableViewFavoriteTracks.register(nib, forCellReuseIdentifier: identifireCell)
    }
    
}

//MARK:- UITableViewDelegate

extension FavoriteTracksViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if self.playerViewController?.delegate !== self {
            playerViewController?.pause()
            self.playerViewController?.delegate = self
            
        }
        self.playerViewController?.setupActiveTrackIndexPath(indexPath: indexPath)
        self.playerViewController?.setupPlayerAndPlay()
    }
}

//MARK:- UITableViewDataSource

extension FavoriteTracksViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        trackFavoriteViewModel.cells.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: identifireCell, for: indexPath) as? TrackFavoriteCell else {return UITableViewCell()}
        cell.set(viewModel: trackFavoriteViewModel.cells[indexPath.row])
        
        cell.removeFromFavorite = { [weak self] in
            self?.removeTrackFromFavorite(trackFavoriteViewModel: self!.trackFavoriteViewModel.cells[indexPath.row])
        }
        
        return cell
    }
    
}

//MARK:- PlayerViewControllerDelegate

extension FavoriteTracksViewController: PlayerViewControllerDelegate {
    
    func play(trackIndexPath: IndexPath) {
        self.tableViewFavoriteTracks.selectRow(at: trackIndexPath, animated: true, scrollPosition: .none)
    }
    
    func pause() {
        
    }
    
    func prevPlay(trackIndexPath: IndexPath) {
        self.tableViewFavoriteTracks.selectRow(at: trackIndexPath, animated: true, scrollPosition: .top)
    }
    
    func nextPlay(trackIndexPath: IndexPath) {
        if trackIndexPath.row < trackFavoriteViewModel.cells.count {
            self.tableViewFavoriteTracks.selectRow(at: trackIndexPath, animated: true, scrollPosition: .bottom)
        }
    }
    
    func close() {
        self.tableViewFavoriteTracks.deselectAllRows(animated: true)
    }
    
    func addToDelegat() {
        
        if let playerViewController = self.playerViewController  {
            interactor?.makeRequest(request: .setPlayerTrackList(playerViewControllr: playerViewController))
            
            if let _ = playerViewController.state as? MinPlayer {
                self.tableViewFavoriteTracksBottomConstraint.constant = playerViewController.initialHeightButtonsView
            }
        }
    }
    
    func removeFromDelegat() {
        self.tableViewFavoriteTracksBottomConstraint.constant = 0
    }
    
    func randomeOrder(order: [Int], newTrackActiveIndexPath: IndexPath?) {
        interactor?.makeRequest(request: .setNewOrder(order: order))
        self.tableViewFavoriteTracks.selectRow(at: newTrackActiveIndexPath, animated: true, scrollPosition: .middle)
    }
    
    func showMin(heightMinState: CGFloat, animate: Bool, duration: Double) {
        self.tableViewFavoriteTracksBottomConstraint.constant = heightMinState
        if animate {
            UIView.animate(withDuration: duration) {
                self.view.superview?.layoutIfNeeded()
            }
        }
    }
    
    func hidePlayer(animate: Bool, duration: Double) {
        self.tableViewFavoriteTracksBottomConstraint.constant = 0
        if animate {
            UIView.animate(withDuration: duration) {
                self.view.superview?.layoutIfNeeded()
            }
        }
    }
    
}
