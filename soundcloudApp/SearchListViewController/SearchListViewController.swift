//
//  SongListViewController.swift
//  soundcloudApp
//
//  Created by pioner on 23.09.2021.
//

import UIKit
import AVKit
import Combine

class SearchListViewController: UIViewController {
    
    var playerViewController: PlayerViewController?
    var trackList: TrakListCollection<Track> = TrakListCollection()
    var activeTrackIndexPath: IndexPath?
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var trackListTableView: UITableView!
    @IBOutlet weak var serchClearLabel: UILabel!
    @IBOutlet weak var trackListTableViewBottomConstraint: NSLayoutConstraint!
    let textSerchClearLabel = "Type Something to search"
    
    let trackFavoriteCoreData = TrackFavoriteCoreData()
    var trackFavorite: [Int:TrackFavorite] {
        return trackFavoriteCoreData.getAllTrackDict()
    }
    
    var subscriptions: AnyCancellable?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SoundCloudNetworking.shared.getToken { }
        
        self.playerViewController = (self.tabBarController as? TabBarController)?.playerViewController
        self.playerViewController?.delegate = self
        
        serchClearLabel.text = textSerchClearLabel
        trackListTableView.isHidden = true
        trackListTableView.dataSource = self
        trackListTableView.delegate = self
        
        searchBar.delegate = self
        
        setupSongListTableView()
        
        subscriptions = playerViewController?.addToFavoriteEvent.sink { [weak self] _ in
            self?.trackListTableView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        trackListTableView.reloadData()
        if self.playerViewController?.delegate === self, let indexPath = self.playerViewController?.getActiveTrackIndexPath() {
            self.trackListTableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        self.view.endEditing(true)
    }
    
    private func setupSongListTableView() {
        
        let identifier = String(describing: TrackListCell.self)
        let nib = UINib(nibName: identifier, bundle: nil)
        trackListTableView.register(nib, forCellReuseIdentifier: identifier)
    }

}

//MARK:- UITableViewDataSource

extension SearchListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: TrackListCell.self), for: indexPath) as? TrackListCell else {
            return UITableViewCell()
        }
        cell.trackFavoriteCoreData = trackFavoriteCoreData
        cell.track = self.trackList[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? TrackListCell else {return}
        cell.songNameLabel.text = cell.track?.title ?? ""
        cell.songAuthorLabel.text = cell.track?.user?.fullName ?? ""
        if let urlImage = cell.track?.artworkUrl {
            SoundCloudNetworking.shared.getImage(urlString: urlImage) { (image) in
                cell.coverImageView.image = image
            }
        }
        
        if let trackId = cell.track?.id, let _ = trackFavorite[trackId] {
            cell.faviriteButton.setBackgroundImage(UIImage(systemName: "heart.fill"), for: .normal)
            
            cell.faviriteButton.tintColor = #colorLiteral(red: 1, green: 0.4244204164, blue: 0, alpha: 0.8470588235)
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.trackList.count
    }
}

//MARK:- UITableViewDelegate

extension SearchListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.view.endEditing(true)
        
        if playerViewController?.delegate !== self {
            playerViewController?.pause()
            
            playerViewController?.delegate = self
        }
        
        playerViewController?.setupActiveTrackIndexPath(indexPath: indexPath)
        playerViewController?.setupPlayerAndPlay()
    }
    
}

//MARK:- UISearchBarDelegate

extension SearchListViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        self.view.endEditing(true)
        
        guard let text = searchBar.text else {return}
        
        if text != "" {
            SoundCloudNetworking.shared.getTracks(search: text,limit: 50) { [self] (responseTrack) in
                
                guard let collection = responseTrack.collection else {return}
                self.trackList.setList(from: collection)
                
                if self.trackList.count > 0 {
                    
                    self.trackListTableView.isHidden = false
                    
                    if playerViewController?.delegate === self {
                        playerViewController?.setList(tracks: self.trackList.list)
                    }
                }
                
                self.trackListTableView.reloadData()
            }
        } else {
            self.trackListTableView.isHidden = true
            if let playerVC = playerViewController{
                if !playerVC.isPlaying {
                    playerVC.turnHidde()
                }
            }
        }
        
    }
}

//MARK:- PlayerViewControllerDelegate

extension SearchListViewController: PlayerViewControllerDelegate{
    
    func play(trackIndexPath: IndexPath) {
        self.trackListTableView.selectRow(at: trackIndexPath, animated: true, scrollPosition: .none)
    }
    
    func pause() {
        
    }
    
    func prevPlay(trackIndexPath: IndexPath) {
        self.trackListTableView.selectRow(at: trackIndexPath, animated: true, scrollPosition: .top)
    }
    
    func nextPlay(trackIndexPath: IndexPath) {
        self.trackListTableView.selectRow(at: trackIndexPath, animated: true, scrollPosition: .bottom)
    }
    
    func close() {
        self.trackListTableView.deselectAllRows(animated: true)
    }
    
    func addToDelegat() {
        self.playerViewController?.setList(tracks: self.trackList.list)
        
        if let playerViewController = self.playerViewController, let _ = playerViewController.state as? MinPlayer {
            self.trackListTableViewBottomConstraint.constant = playerViewController.initialHeightButtonsView
        }
    }
    
    func removeFromDelegat() {
        self.trackListTableViewBottomConstraint.constant = 0
    }
    
    func randomeOrder(order: [Int], newTrackActiveIndexPath: IndexPath?) {
        if self.trackList.setOrder(from: order) {
            self.trackListTableView.reloadData()
            if let newIndexPath = newTrackActiveIndexPath {
                self.trackListTableView.selectRow(at: newIndexPath, animated: true, scrollPosition: .middle)
            }
        }
    }
    
    func showMin(heightMinState: CGFloat, animate: Bool, duration: Double) {
        self.trackListTableViewBottomConstraint.constant = heightMinState
        if animate {
            UIView.animate(withDuration: duration) {
                self.view.superview?.layoutIfNeeded()
            }
        }
    }
    
    func hidePlayer(animate: Bool, duration: Double) {
        self.trackListTableViewBottomConstraint.constant = 0
        if animate {
            UIView.animate(withDuration: duration) {
                self.view.superview?.layoutIfNeeded()
            }
        }
    }
    
}


