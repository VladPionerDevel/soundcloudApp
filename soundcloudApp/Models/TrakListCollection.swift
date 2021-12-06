//
//  PlayingTraksCollection.swift
//  soundcloudApp
//
//  Created by pioner on 02.11.2021.
//

import Foundation

class TrakListCollection<T: IdentifiableInt> {
    
    var list: [T] {
        return getListFromOrderAndListDict()
    }
    
    var count: Int {
        return order.count
    }
    
    var order: [Int] = []
    
    var orderRandome: Bool = false {
        willSet {
            if !orderRandome {
                setRandomOrder()
            } else {
                setInitialOrder()
            }
        }
    }
    
    private var listDict: [Int: T] = [:]
    private var tempOrder: [Int] = []
    
    subscript(index: Int) -> T {
        get {
            return list[index]
        }
        set(newValue) {
            listDict[order[index]] = newValue
        }
    }
    
    init() { }
    
    init(from list: [T]) {
        self.setList(from: list)
    }
    
    convenience init(playingTrackList: [PlayingTrackProtocol]) {
        let list = playingTrackList.map { track in
            PlayingTrack(trackProtocol: track) as! T
        }
        
        self.init(from: list)
    }
    
    func setList(from list: [T]) {
        self.order = []
        self.listDict = [:]
        self.tempOrder = []
        
        list.forEach { (item) in
            order.append(item.id)
            listDict[item.id] = item
        }
        tempOrder = order
    }
    
    func setOrder(from ids: [Int]) -> Bool{
        if !isEqualList(for: ids) {
            return false
        }
        
        self.order = ids
        
        return true
    }
    
    func isEqualList(for listInput: [Int]) -> Bool {
        if listInput.count != self.count {
            return false
        }
        
        var isEqual = true
        for item in listInput {
            if !self.order.contains(item) {
                isEqual = false
                break
            }
        }
        
        return isEqual
    }
    
    func getIndexPathById(id: Int) -> IndexPath? {
        
        for (index, track) in self.list.enumerated() {
            if track.id == id {
                return IndexPath(row: index, section: 0)
            }
        }
        
        return nil
    }
    
    private func getListFromOrderAndListDict() -> [T] {
        var listTemp: [T] = []
        self.order.forEach { (id) in
            if let track = self.listDict[id] {
                listTemp.append(track)
            }
        }
        return listTemp
    }
    
    private func setRandomOrder(){
        self.order.shuffle()
    }
    
    private func setInitialOrder(){
        self.order = tempOrder
    }
    
}
