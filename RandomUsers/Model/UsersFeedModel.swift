//
//  UserFeedModel.swift
//  RandomUsers
//
//  Created by Magdalena Szlagor on 18/03/2018.
//  Copyright © 2018 Magdalena Szlagor. All rights reserved.
//

import UIKit

class UserFeedModel {
    
    public private(set) var userFeedModelType: UserFeedModelType
    public private(set) var users: [UserModel] = []
    public private(set) var allUsers: [UserModel] = []
    
    init(initWithUserFeedModelType: UserFeedModelType) {
        self.userFeedModelType = initWithUserFeedModelType
    }
    
    public func fetchUsers(completion: @escaping () -> ()) {
        if userFeedModelType == .allUsers {
            self.fetchAllUsers(completion: completion)
        }
        else {
            self.fetchFavUsers(completion: completion)
        }
    }
    
    public func searchForUser(searchText: String) {
        users = allUsers.filter({( user : UserModel) -> Bool in
            return (user.name.toString().lowercased().contains(searchText.lowercased())
                || user.mobilePhone.contains(searchText))
        })
    }
    
    public func resetSearch() {
        users = allUsers
    }
    
    private func fetchAllUsers(completion: @escaping () -> ()) {
        let urlString = "https://randomuser.me/api/?results=" + "\(GlobalConstants.kNrOfUsers)"
        let url = URL(string: urlString)
        WebService().load(resource: WebService.parseUserFeedResponse(withURL: url!)) { [unowned self] result in
            switch result {
            case .success(let usersPage):
                DispatchQueue.main.async {
                    self.users = usersPage.users
                    self.allUsers = usersPage.users
                    completion()
                }
                
            case .failure(let fail):
                print(fail)
            }
        }
    }
    
    private func fetchFavUsers(completion: @escaping () -> ()) {
        guard let favourites = FavourtiesManager.shared.getAllFavourites()?.allValues as? [JSONDictionary] else { print("error within fetchFavUsers"); return }
        
        let favUsers = favourites.flatMap(UserModel.init)
        users = favUsers
        allUsers = favUsers
        completion()
    }
}

enum UserFeedModelType {
    case allUsers
    case favouriteUsers
}

class UsersPageModel {
    let page: Int
    let numberOfItems: Int
    let users: [UserModel]
    
    init?(dictionary: JSONDictionary, usersArray: [UserModel]) {
        guard let info = dictionary["info"] as? JSONDictionary, let page = info["page"] as? Int, let numberOfItems = info["results"]  as? Int else { print("error parsing JSON within UsersPageModel Init"); return nil }
        
        self.page = page
        self.numberOfItems = numberOfItems
        self.users = usersArray
    }
}
