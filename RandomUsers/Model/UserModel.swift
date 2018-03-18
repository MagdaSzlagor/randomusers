//
//  UserModel.swift
//  RandomUsers
//
//  Created by Magdalena Szlagor on 18/03/2018.
//  Copyright © 2018 Magdalena Szlagor. All rights reserved.
//

import UIKit

public typealias JSONDictionary = [String : Any]

public struct UserModel {
    
    let photo: UserPhoto
    let userId: UserId
    let gender: String
    let name: Name
    let location: Location
    let email: String
    let mobilePhone: String
    
    init?(dictionary: JSONDictionary) {
        guard let email = dictionary["email"] as? String, let gender = dictionary["gender"] as? String, let mobilePhone = dictionary["cell"] as? String else { print("error parsing JSON within UserModel Init"); return nil }
        
        guard let location = Location(dictionary: dictionary["location"] as! JSONDictionary) else { print("error parsing JSON within UserModel Init"); return nil }
        
        guard let name = Name(dictionary: dictionary["name"] as! JSONDictionary) else { print("error parsing JSON within UserModel Init"); return nil }
        
        guard let photo = UserPhoto(dictionary: dictionary["picture"] as! JSONDictionary) else { print("error parsing JSON within UserModel Init"); return nil }
        
        guard let userId = UserId(dictionary: dictionary["id"] as! JSONDictionary) else { print("error parsing JSON within UserModel Init"); return nil }
        
        self.name = name
        self.location = location
        self.email = email
        self.mobilePhone = mobilePhone
        self.gender = gender
        self.userId = userId
        self.photo = photo
    }
}

extension UserModel {
    
    public func addToFavourites() {
        FavourtiesManager.shared.addToFavourites(user: self)
    }
    
    public func removeFromFavourites() {
        FavourtiesManager.shared.removeFavourites(user: self)
    }
    
    public func toDictionary() -> NSDictionary {
        let dict = NSMutableDictionary()
        dict["name"] = name.toDictionary()
        dict["email"] = email
        dict["cell"] = mobilePhone
        dict["gender"] = gender
        dict["location"] = location.toDictionary()
        dict["id"] = userId.toDictionary()
        dict["picture"] = photo.toDictionary()
        return dict
    }
}

struct UserId {
    let name: String
    let value: String
    
    init?(dictionary: JSONDictionary) {
        guard let name = dictionary["name"] as? String, let value = dictionary["value"] as? String else { print("error parsing JSON within UserId Init"); return nil }
        
        self.name = name
        self.value = value
    }
    
    public func getUserId() -> String {
        return name + value
    }
    
    fileprivate func toDictionary() -> NSDictionary {
        let dict = NSMutableDictionary()
        dict["name"] = name
        dict["value"] = value
        return dict
    }
}

struct UserPhoto {
    let largePhoto: String
    let mediumPhoto: String
    let thumbnailPhoto: String
    
    init?(dictionary: JSONDictionary) {
        guard let large = dictionary["large"] as? String, let medium = dictionary["medium"] as? String, let small = dictionary["thumbnail"]  as? String else { print("error parsing JSON within UserPhoto Init"); return nil }
        
        self.largePhoto = large
        self.mediumPhoto = medium
        self.thumbnailPhoto = small
    }
    
    fileprivate func toDictionary() -> NSDictionary {
        let dict = NSMutableDictionary()
        dict["large"] = largePhoto
        dict["medium"] = mediumPhoto
        dict["thumbnail"] = thumbnailPhoto
        return dict
    }
}

struct Location {
    let street: String
    let city: String
    let state: String
    let postcode: Int
    
    init?(dictionary: JSONDictionary) {
        guard let street = dictionary["street"] as? String, let city = dictionary["city"] as? String, let state = dictionary["state"] as? String, let postcode = dictionary["postcode"] as? Int else { print("error parsing JSON within Location Init"); return nil }
        
        self.street = street
        self.state = state
        self.city = city
        self.postcode = postcode
    }
    
    public func toString() -> String {
        return street + "\n" + "\(postcode)" + " " + city + "\n" + state
    }
    
    fileprivate func toDictionary() -> NSDictionary {
        let dict = NSMutableDictionary()
        dict["street"] = street
        dict["city"] = city
        dict["state"] = state
        dict["postcode"] = postcode
        return dict
    }
}

struct Name {
    let title: String
    let first: String
    let last: String
    
    init?(dictionary: JSONDictionary) {
        guard let title = dictionary["title"] as? String, let first = dictionary["first"] as? String, let last = dictionary["last"] as? String else { print("error parsing JSON within Name Init"); return nil }
        
        self.title = title
        self.first = first
        self.last = last
    }
    
    public func toString() -> String {
        return title + " " + first + " " + last
    }
    
    fileprivate func toDictionary() -> NSDictionary {
        let dict = NSMutableDictionary()
        dict["title"] = title
        dict["first"] = first
        dict["last"] = last
        return dict
    }
}

