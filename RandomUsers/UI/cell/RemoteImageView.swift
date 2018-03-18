//
//  RemoteImageView.swift
//  RandomUsers
//
//  Created by Magdalena Szlagor on 18/03/2018.
//  Copyright © 2018 Magdalena Szlagor. All rights reserved.
//

import UIKit

let imageCache = NSCache<NSString, UIImage>()

class RemoteImageView: UIImageView {
    
    var imageUrl: String?
    
    func loadImageFromUrl(urlString: String) {
        imageUrl = urlString
        
        let url = URL(string: urlString)
        
        image = nil
        
        if let imageFromCache = imageCache.object(forKey: urlString as NSString) {
            self.image = imageFromCache
            return
        }
        
        URLSession.shared.dataTask(with: url!, completionHandler: { (data, respones, error) in
            
            if error == nil {
                DispatchQueue.main.async {
                    let imageToCache = UIImage(data: data!)
                    if self.imageUrl == urlString {
                        self.image = imageToCache
                    }
                    imageCache.setObject(imageToCache!, forKey: urlString as NSString)
                }
            }
        }).resume()
    }
}

