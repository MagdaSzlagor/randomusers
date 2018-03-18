//
//  ViewController.swift
//  RandomUsers
//
//  Created by Magdalena Szlagor on 18/03/2018.
//  Copyright © 2018 Magdalena Szlagor. All rights reserved.
//

import UIKit

class UsersFeedTVC: UITableViewController {

    var userFeed: UserFeedModel
    var pullToRefreshControl: UIRefreshControl!
    let searchController = UISearchController(searchResultsController: nil)
    
    init(initWithUserFeedModelType: UserFeedModelType) {
        userFeed = UserFeedModel(initWithUserFeedModelType: initWithUserFeedModelType)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureSearchController()
        configureTableView()
        
        self.title = userFeed.userFeedModelType == .allUsers ? "All users" : "Favourites"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if userFeed.userFeedModelType == .favouriteUsers || userFeed.users.count == 0 {
            refresh(animated: false)
        }
    }
    
    private func configureSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search users"
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    private func configureTableView() {
        tableView.register(UINib.init(nibName: "UserCell", bundle: Bundle.main), forCellReuseIdentifier: "UserCell")
        tableView.allowsSelection = false
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.separatorStyle = .none
        
        pullToRefreshControl = UIRefreshControl()
        pullToRefreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        pullToRefreshControl.addTarget(self, action: #selector(UsersFeedTVC.refresh(animated:)), for: .valueChanged)
        tableView.addSubview(pullToRefreshControl)
    }
    
    @objc private func refresh(animated: Bool = true) {
        if animated == true {
            pullToRefreshControl.beginRefreshing()
        }
        
        userFeed.fetchUsers(completion: { [unowned self] in
            self.pullToRefreshControl.endRefreshing()
            self.tableView.reloadData()
        })
    }
}

extension UsersFeedTVC {
    
    //MARK: Table Data Source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userFeed.users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath) as! UserCell
        cell.userModel = userFeed.users[indexPath.row]
        cell.userFeedType = userFeed.userFeedModelType
        cell.delegate = self
        
        return cell
    }
}

extension UsersFeedTVC: UserCellDelegate {
    func removeUserFromFavourties(user: UserModel?) {
        user?.removeFromFavourites()
        refresh(animated: false)
        BPStatusBarAlert(duration: 0.2, delay: 1.5, position: .statusBar)
            .message(message: "User removed from favourites")
            .messageColor(color: .white)
            .bgColor(color: GlobalConstants.kGrayColor)
            .completion {}
            .show()
    }
    
    func addUserToFavourties(user: UserModel?) {
        user?.addToFavourites()
        BPStatusBarAlert(duration: 0.2, delay: 1.5, position: .statusBar)
            .message(message: "User added to favourites")
            .messageColor(color: .white)
            .bgColor(color: GlobalConstants.kGreenColor)
            .completion {}
            .show()
    }
}

extension UsersFeedTVC: UISearchResultsUpdating {
    
    //MARK: UISearchController delegate
    
    func updateSearchResults(for searchController: UISearchController) {
        let text = searchController.searchBar.text
        if self.isFiltering() {
            userFeed.searchForUser(searchText: text!)
        }
        else {
            userFeed.resetSearch()
        }
        tableView.reloadData()
    }
    
    func isFiltering() -> Bool {
        guard let text = searchController.searchBar.text else { return false }
        
        return searchController.isActive && !text.isEmpty
    }
}
