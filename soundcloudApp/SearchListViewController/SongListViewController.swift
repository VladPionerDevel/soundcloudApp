//
//  SongListViewController.swift
//  soundcloudApp
//
//  Created by pioner on 23.09.2021.
//

import UIKit

class TrackListViewController: UIViewController {
    
    var dismissButton: UIButton!
    
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var songListTableView: UITableView!
    @IBOutlet weak var serchClearLabel: UILabel!
    let textSerchClearLabel = "Type Something to search"
    
    
    let data = ["New York, NY", "Los Angeles, CA", "Chicago, IL", "Houston, TX",
            "Philadelphia, PA", "Phoenix, AZ", "San Diego, CA", "San Antonio, TX",
            "Dallas, TX", "Detroit, MI", "San Jose, CA", "Indianapolis, IN",
            "Jacksonville, FL", "San Francisco, CA", "Columbus, OH", "Austin, TX",
            "Memphis, TN", "Baltimore, MD", "Charlotte, ND", "Fort Worth, TX"]
    
    //let data1 = [Song(cover: <#T##UIImage#>, name: <#T##String#>, author: <#T##String#>)]

    var filteredData: [String]!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //SoundCloudNetworking.shared.getToken(comletionHandler: { })
        //print(SoundCloudNetworking.shared.getSavedToken())
        SoundCloudNetworking.shared.getTracks(search: "like a stone")
        
        serchClearLabel.text = textSerchClearLabel
        songListTableView.isHidden = true
        
        
        filteredData = data
        
        songListTableView.dataSource = self
        searchBar.delegate = self
        
        
        setupSongListTableView()
        
        stupButDismis()
    }
    
    private func setupSongListTableView() {
        
        let identifier = String(describing: SongListCell.self)
        let nib = UINib(nibName: identifier, bundle: nil)
        songListTableView.register(nib, forCellReuseIdentifier: identifier)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        checkAuthorisation()
    }
    
    func stupButDismis(){
        dismissButton = UIButton(frame: CGRect(x: 0, y: 400, width: 100, height: 50))
        dismissButton.setTitle("dismiss", for: .normal)
        dismissButton.backgroundColor = .red

        dismissButton.addTarget(self, action: #selector(dis), for: .touchUpInside)
        
        view.addSubview(dismissButton)
    }
    
    @objc func dis(_ sendre: UIButton){
        let userdefaults = UserDefaults.standard
        userdefaults.removeObject(forKey: "token")
        checkAuthorisation()
    }
    
    private func checkAuthorisation() {
        //print(Authorisation.isToken())
        if !Authorisation.isToken() {
            let loginVC = storyboard?.instantiateViewController(identifier: "loginVC")
            present(loginVC!, animated: false)
        }
    }
    

}

//MARK:- UITableViewDataSource

extension TrackListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SongListCell.self), for: indexPath) as? SongListCell else {
            return UITableViewCell()
        }
            cell.songNameLabel?.text = filteredData[indexPath.row]
            return cell
        }

        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return filteredData.count
        }
}

extension TrackListViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText.isEmpty {
            filteredData = []
            
            songListTableView.isHidden = true
        } else {
            filteredData = data.filter { (item: String) -> Bool in
                return item.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil
            }
            
            songListTableView.isHidden = false
        }
        
        songListTableView.reloadData()
    }
}


