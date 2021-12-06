//
//  TabBarController.swift
//  soundcloudApp
//
//  Created by pioner on 19.10.2021.
//

import UIKit

class TabBarController: UITabBarController {
    
    var playerViewController: PlayerViewController!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupPlayerViewController()
        setupItems()
    }
    
    private func setupItems(){
        let searchVC = (storyboard?.instantiateViewController(identifier: "SearchListViewController"))!
        
        let favoriteTrackVC = (storyboard?.instantiateViewController(identifier: "FavoriteTracksViewController"))!
        
        self.setViewControllers([searchVC,favoriteTrackVC], animated: true)
        self.modalPresentationStyle = .fullScreen
    }
    
    private func setupPlayerViewController(){
        self.playerViewController = (storyboard!.instantiateViewController(identifier: "PlayerViewController") as! PlayerViewController)
        
        addChild(playerViewController)
        view.insertSubview(playerViewController.view, at: 1)
        playerViewController.didMove(toParent: self)
        
        playerViewController.turnHidde()
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if let _ = playerViewController.state as? FullScreenPlayeer {
            playerViewController.turnMin()
        }
    }
    
}
