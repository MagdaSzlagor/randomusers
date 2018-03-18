//
//  FavourtiesManager.swift
//  RandomUsers
//
//  Created by Magdalena Szlagor on 18/03/2018.
//  Copyright © 2018 Magdalena Szlagor. All rights reserved.
//

import Foundation

public class FavourtiesManager {
    
    public static let shared = FavourtiesManager()
    let plistName = "Favourites"
    
    init() {
        SwiftyPlistManager.shared.start(plistNames: [plistName], logging: false)
    }
    
    public func addToFavourites(user: UserModel) {
        SwiftyPlistManager.shared.addNew(user.toDictionary(), key: user.userId.getUserId(), toPlistWithName: plistName, completion: { (err) in
            if (err != nil) {
                print(err.debugDescription)
            }
        })
    }
    
    public func removeFavourites(user: UserModel) {
        SwiftyPlistManager.shared.removeKeyValuePair(for: user.userId.getUserId(), fromPlistWithName: plistName, completion: { (err) in
            if (err != nil) {
                print(err.debugDescription)
            }
        })
    }
    
    public func getAllFavourites() -> NSDictionary? {
        return SwiftyPlistManager.shared.getAllValues(fromPlistWithName: plistName)
    }
}
