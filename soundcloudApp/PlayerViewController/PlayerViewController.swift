//
//  PlayerViewController.swift
//  soundcloudApp
//
//  Created by pioner on 01.10.2021.
//

import UIKit
import AVKit
import Combine


@objc protocol PlayerViewControllerDelegate: class {
    var playerViewController: PlayerViewController? {get set}
    @objc optional func play(trackIndexPath: IndexPath)
    @objc optional func pause()
    @objc optional func prevPlay(trackIndexPath: IndexPath)
    @objc optional func nextPlay(trackIndexPath: IndexPath)
    @objc optional func shuffle()
    @objc optional func close()
    @objc optional func addToDelegat()
    @objc optional func removeFromDelegat()
    @objc optional func randomeOrder(order: [Int], newTrackActiveIndexPath: IndexPath?)
    @objc optional func showMin(heightMinState: CGFloat, animate: Bool, duration: Double)
    @objc optional func hidePlayer(animate: Bool, duration: Double)
}

class PlayerViewController: UIViewController {
    
    let playerViewModel: PlayerViewModel = PlayerViewModel()
    
    var state: StatePlayer = HiddenPlayer()
    
    var delegate: PlayerViewControllerDelegate? {
        willSet {
            if let delegate = delegate {
                delegate.removeFromDelegat?()
            }
            
        } didSet {
            if let delegate = delegate {
                delegate.addToDelegat?()
            }
        }
    }
    
    var isPlaying: Bool {
        guard let player = playerViewModel.player else {return false}
        if player.rate == 0 {
            return false
        } else {
            return true
        }
    }
    
    @IBOutlet weak var coverAndNamevView: UIView!
    
    @IBOutlet weak var leadingButtonBackwardConstraint: NSLayoutConstraint!
    @IBOutlet weak var trailingButtonForvardConstraint: NSLayoutConstraint!
    @IBOutlet weak var buttonPlayHorisontalCenterConstraint: NSLayoutConstraint!
    @IBOutlet weak var heightbuttonsViewConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var withButtonsView: UIView!
    @IBOutlet weak var labelsNameAndAuthorStack: UIStackView!
    
    @IBOutlet weak var progressSlider: UISlider!
    @IBOutlet weak var buttonPlay: UIButton!
    @IBOutlet weak var trackNameTopLabel: UILabel!
    @IBOutlet weak var trackNameBottomLabel: UILabel!
    @IBOutlet weak var trackAuthorTopLabel: UILabel!
    @IBOutlet weak var trackAuthorBottomLabel: UILabel!
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var timesStack: UIStackView!
    @IBOutlet weak var currntTimeLabel: UILabel!
    @IBOutlet weak var allTimeLabel: UILabel!
    @IBOutlet weak var shuffleButton: UIButton!
    @IBOutlet weak var addToFavoriteButton: UIButton!
    
    let addToFavoriteEvent = PassthroughSubject<(Int, Bool), Never>()
    
    let initialHeightButtonsView: CGFloat = 176 + UIApplication.shared.bottomSafeArial
    private let shuffleButtonAlphaWhereFalse: CGFloat = 0.3
    private let heightViewCoverAndName: CGFloat = 445
    private let leadingAndTrailingButtonsSpacing: CGFloat = 42
    private let topButtonsSpacing:CGFloat = 41
    private var animationsDuration = 0.8
    
    private let removeFromFavoritesText = "Remove from favourites"
    private let addToFavoritesText = "Add to favourites"
    
    var trackName = "" {
        willSet {
            trackNameTopLabel.text = newValue
            trackNameBottomLabel.text = newValue
        }
    }
    
    var trackAuthor = ""{
        willSet {
            trackAuthorTopLabel.text = newValue
            trackAuthorBottomLabel.text = newValue
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hidePlayer(animate: false, {})
        
        withButtonsView.gestureRecognizers = [UITapGestureRecognizer(target: self, action: #selector(tapViewWithButton))]
        
        playerViewModel.delegate = self
        
        settupSwipeDown()
        settupSwipeToLeft()
        settupSwipeToRight()
        shuffleButton.alpha = shuffleButtonAlphaWhereFalse
    }
    
    @IBAction func playTapped(_ sender: UIButton) {
        guard let player = playerViewModel.player else {return}
        
        if player.rate == 0 {
            self.play()
        } else {
            self.pause()
        }
        
    }
    
    @IBAction func prevTapped(_ sender: UIButton) {
        playerViewModel.prevPlay()
        delegate?.prevPlay?(trackIndexPath: playerViewModel.trackActiveInddexPath!)
    }
    
    @IBAction func nextTapped(_ sender: UIButton) {
        playerViewModel.nextPlay()
        delegate?.nextPlay?(trackIndexPath: playerViewModel.trackActiveInddexPath!)
    }
    
    @IBAction func shuffleTapped(_ sender: UIButton) {
        playerViewModel.orderRandome = !playerViewModel.orderRandome
        delegate?.randomeOrder?(order: playerViewModel.trackList.order, newTrackActiveIndexPath: playerViewModel.trackActiveInddexPath)
        
        if playerViewModel.orderRandome {
            shuffleButton.alpha = 1
        } else {
            shuffleButton.alpha = shuffleButtonAlphaWhereFalse
        }
    }
    
    @IBAction func backTapped(_ sender: UIButton) {
        self.turnMin()
    }
    
    @IBAction func closeTapped(_ sender: UIButton) {
        playerViewModel.pause()
        self.turnHidde()
        delegate?.close?()
    }
    
    @IBAction func addToFavoriteTapped(_ sender: UIButton) {
        if playerViewModel.isFavoritePlayingTrack {
            playerViewModel.removeFromFavorite()
            addToFavoriteButton.setTitle(addToFavoritesText, for: .normal)
        } else {
            playerViewModel.addToFavorite(imageData: self.coverImageView.image?.pngData())
            addToFavoriteButton.setTitle(removeFromFavoritesText, for: .normal)
        }
        
        if let playingTrackId = playerViewModel.playingTrack?.id {
            addToFavoriteEvent.send((playingTrackId, playerViewModel.isFavoritePlayingTrack))
        }
    }
    
    func setupPlayer(){
        playerViewModel.setupPlayer(){}
    }
    
    func play() {
        playerViewModel.play()
        delegate?.play?(trackIndexPath: playerViewModel.trackActiveInddexPath!)
    }
    
    func setupPlayerAndPlay() {
        playerViewModel.setupPlayerAndPlay()
        delegate?.play?(trackIndexPath: playerViewModel.trackActiveInddexPath!)
    }
    
    func pause() {
        playerViewModel.pause()
        delegate?.pause?()
    }
    
    func setupActiveTrackIndexPath(indexPath: IndexPath){
        playerViewModel.trackActiveInddexPath = indexPath
    }
    
    func getActiveTrackIndexPath() -> IndexPath? {
        return playerViewModel.trackActiveInddexPath
    }
    
    func setList(tracks: [PlayingTrackProtocol]) {
        let list = TrakListCollection<PlayingTrack>(playingTrackList: tracks)
        playerViewModel.trackList = list
    }
    
    @objc func finishedPlaying( _ myNotification:NSNotification) {
        playerViewModel.nextPlay()
    }
    
    @objc func swipeDown(){
        self.turnMin()
    }
    
    @objc func swipeToRight() {
        playerViewModel.nextPlay()
        delegate?.nextPlay?(trackIndexPath: playerViewModel.trackActiveInddexPath!)
    }
    
    @objc func swipeToLeft() {
        playerViewModel.prevPlay()
        delegate?.prevPlay?(trackIndexPath: playerViewModel.trackActiveInddexPath!)
    }
    
    @objc func playbackSliderValueChanged(_ playbackSlider:UISlider) {
        let seconds : Int64 = Int64(playbackSlider.value)
        let targetTime:CMTime = CMTimeMake(value: seconds, timescale: 1)
        
        playerViewModel.player!.seek(to: targetTime)
        
        if playerViewModel.player!.rate == 0
        {
            playerViewModel.player?.play()
        }
    }
    
    @objc func tapViewWithButton(){
        self.turnFullScreen()
    }
    
    private func setAddToFavoriteButton(){
        addToFavoriteButton.layer.cornerRadius = 5
        addToFavoriteButton.layer.borderWidth = 1
        addToFavoriteButton.layer.borderColor = #colorLiteral(red: 1, green: 0.4244204164, blue: 0, alpha: 0.8470588235)
        
        if let _ = playerViewModel.playingTrack {
            
            if playerViewModel.isFavoritePlayingTrack {
                addToFavoriteButton.setTitle(removeFromFavoritesText, for: .normal)
            } else {
                addToFavoriteButton.setTitle(addToFavoritesText, for: .normal)
            }
        } else {
            addToFavoriteButton.setTitle("", for: .normal)
        }
    }
    
    private func settupSwipeDown() {
        let swipeGestureRecognizerDown = UISwipeGestureRecognizer(target: self, action: #selector(swipeDown))
        
        swipeGestureRecognizerDown.direction = .down
        view.addGestureRecognizer(swipeGestureRecognizerDown)
    }
    
    private func settupSwipeToLeft() {
        let swipeGestureRecognizerToLeft = UISwipeGestureRecognizer(target: self, action: #selector(swipeToLeft))
        
        swipeGestureRecognizerToLeft.direction = .left
        view.addGestureRecognizer(swipeGestureRecognizerToLeft)
    }
    
    private func settupSwipeToRight() {
        let swipeGestureRecognizerToRight = UISwipeGestureRecognizer(target: self, action: #selector(swipeToRight))
        
        swipeGestureRecognizerToRight.direction = .right
        view.addGestureRecognizer(swipeGestureRecognizerToRight)
    }
    
    private func setCoverImage(from playingTrack: PlayingTrack){
        
        if let imageData = playingTrack.imageData {
            self.coverImageView.image = UIImage(data: imageData)
            self.coverImageView.contentMode = .scaleAspectFit
            return
        }
        
        if let artworkUrl = playingTrack.artworkUrl, artworkUrl != "" {
            SoundCloudNetworking.shared.getImage(urlString: artworkUrl) { (image) in
                self.coverImageView.image = image
                self.coverImageView.contentMode = .scaleAspectFit
            }
            return
        }
        
        self.coverImageView.image = UIImage(named: "logo_orange")
        self.coverImageView.contentMode = .center
        
    }
    
    private func stringFromTimeInterval(interval: TimeInterval) -> String {
        
        let interval = !interval.isNaN ? Int(interval) : 0
        let seconds = interval % 60
        let minutes = (interval / 60) % 60
        let hours = (interval / 3600)
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
}

// MARK: - StatePlaerObject

extension PlayerViewController: StatePlaerObject {
    
    func showFullScreen() {
        UIView.animate(withDuration: animationsDuration, animations: {
            self.view.frame.origin.y = 0
        })
        
        self.setAddToFavoriteButton()
    }
    
    func showMin() {
        UIView.animate(withDuration: animationsDuration, animations: { [weak self] in
            if self != nil {
                self!.view.frame.origin.y = self!.view.frame.height - self!.initialHeightButtonsView
                self!.delegate?.showMin?(heightMinState: self!.initialHeightButtonsView, animate: true, duration: self!.animationsDuration)
            }
        })
    }
    
    func hidePlayer(animate: Bool, _ completionHandler: @escaping () -> Void) {
        let duration = animate ? animationsDuration : 0
        
        UIView.animate(withDuration: duration, animations: { [weak self] in
            if self != nil {
                self!.view.frame.origin.y = self!.view.frame.height
                self!.delegate?.hidePlayer?(animate: true, duration: duration)
            }
        }) { (_) in
            completionHandler()
        }
    }
    
    func showCoverAndNameView(animate: Bool){
        heightbuttonsViewConstraint.constant = initialHeightButtonsView
        leadingButtonBackwardConstraint.constant = leadingAndTrailingButtonsSpacing
        trailingButtonForvardConstraint.constant = leadingAndTrailingButtonsSpacing
        buttonPlayHorisontalCenterConstraint.priority = UILayoutPriority(rawValue: 1000)
        
        if animate {
            UIView.animate(withDuration: animationsDuration) {
                self.view.superview?.layoutIfNeeded()
            }
        }
        
        let duration = animate ? animationsDuration : 0
        
        UIView.animate(withDuration: duration,animations: { [weak self] in
            if self != nil {
                self!.labelsNameAndAuthorStack.alpha = 0
                self!.timesStack.alpha = 1
            }
        })
    }
    
    func hideCoverAndNameView(animate: Bool){
        heightbuttonsViewConstraint.constant = view.frame.height
        leadingButtonBackwardConstraint.constant = 20
        trailingButtonForvardConstraint.constant = 20
        buttonPlayHorisontalCenterConstraint.priority = UILayoutPriority(rawValue: 800)
        
        if animate {
            UIView.animate(withDuration: animationsDuration) {
                self.view.superview?.layoutIfNeeded()
            }
        }
        
        let duration = animate ? animationsDuration : 0
        
        UIView.animate(withDuration: duration,animations: { [weak self] in
            if self != nil {
                self!.labelsNameAndAuthorStack.alpha = 1
                self!.timesStack.alpha = 0
            }
        })
        
    }
    
}


//MARK: - PlayerViewModelDelegate

extension PlayerViewController: PlayerViewModelDelegate {
    
    func playerPlay(playing: PlayerViewModel) {
        
        buttonPlay.setBackgroundImage(UIImage(systemName: "pause.fill"), for: .normal)
        
        if let _ = self.state as? HiddenPlayer {
            self.turnMin()
        }
    }
    
    func playerPause() {
        buttonPlay.setBackgroundImage(UIImage(systemName: "play.fill"), for: .normal)
    }
    
    func initializationPlayer(playing: PlayerViewModel, player: AVPlayer,playerItem: AVPlayerItem) {
        
        if let track = playing.playingTrack {
            trackName = track.title ?? ""
            trackAuthor = track.authorName ?? ""
            setCoverImage(from: track)
            setAddToFavoriteButton()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.finishedPlaying(_:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)

        progressSlider.minimumValue = 0

        progressSlider.addTarget(self, action: #selector(self.playbackSliderValueChanged(_:)), for: .valueChanged)

        let duration : CMTime = playerItem.asset.duration
        let seconds : Float64 = CMTimeGetSeconds(duration)
        allTimeLabel.text = self.stringFromTimeInterval(interval: seconds)
        
        let duration1 : CMTime = playerItem.currentTime()
        let seconds1 : Float64 = CMTimeGetSeconds(duration1)
        currntTimeLabel.text = self.stringFromTimeInterval(interval: seconds1)

        progressSlider.maximumValue = Float(seconds)
        progressSlider.isContinuous = true

        player.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1, preferredTimescale: 1), queue: DispatchQueue.main) { [self] (CMTime) -> Void in

            if playerViewModel.player?.currentItem?.status == .readyToPlay {
                let time : Float64 = CMTimeGetSeconds(playerViewModel.player!.currentTime());
                self.progressSlider.value = Float ( time );
                
                self.currntTimeLabel.text = self.stringFromTimeInterval(interval: time)
            }

        }
    }
}

