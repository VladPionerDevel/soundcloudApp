//
//  StatePlayer.swift
//  soundcloudApp
//
//  Created by pioner on 05.10.2021.
//

import Foundation

protocol StatePlaerObject: class {
    var state: StatePlayer {get set}
    
    func setState(state: StatePlayer)
    
    func turnFullScreen()
    
    func turnMin()
    
    func turnHidde()
    
    func showFullScreen()
    
    func showCoverAndNameView(animate: Bool)
    
    func hidePlayer(animate: Bool,_ completionHandler: @escaping ()->Void)
    
    func showMin()
    
    func hideCoverAndNameView(animate: Bool)
}

extension StatePlaerObject {
    
    func setState(state: StatePlayer){
        self.state = state
    }
    
    func turnFullScreen() {
        state.fullScreenPlayeer(viewController: self)
    }
    
    func turnMin() {
        state.minPlayer(viewController: self)
    }
    
    func turnHidde() {
        state.hiddenPlayer(viewController: self)
    }
}


protocol StatePlayer {
    func minPlayer(viewController: StatePlaerObject)
    func fullScreenPlayeer(viewController: StatePlaerObject)
    func hiddenPlayer(viewController: StatePlaerObject)
}

class MinPlayer: StatePlayer {
    func minPlayer(viewController: StatePlaerObject) {
        return
    }

    func fullScreenPlayeer(viewController: StatePlaerObject) {
        viewController.showFullScreen()
        viewController.showCoverAndNameView(animate: true)
        viewController.setState(state: FullScreenPlayeer())
    }

    func hiddenPlayer(viewController: StatePlaerObject) {
        viewController.hidePlayer(animate: true) {
            viewController.showCoverAndNameView(animate: false)
        }
        viewController.setState(state: HiddenPlayer())
    }
}

class FullScreenPlayeer: StatePlayer {
    func minPlayer(viewController: StatePlaerObject) {
        viewController.showMin()
        viewController.hideCoverAndNameView(animate: true)
        viewController.setState(state: MinPlayer())
    }

    func fullScreenPlayeer(viewController: StatePlaerObject) {
        return
    }

    func hiddenPlayer(viewController: StatePlaerObject) {
        viewController.hidePlayer(animate: true) { }
        viewController.setState(state: HiddenPlayer())
    }
}

class HiddenPlayer: StatePlayer {
    func minPlayer(viewController: StatePlaerObject) {
        viewController.hideCoverAndNameView(animate: false)
        viewController.showMin()
        viewController.setState(state: MinPlayer())
    }

    func fullScreenPlayeer(viewController: StatePlaerObject) {
        viewController.showFullScreen()
        viewController.setState(state: FullScreenPlayeer())
    }

    func hiddenPlayer(viewController: StatePlaerObject) {
        return
    }
}

