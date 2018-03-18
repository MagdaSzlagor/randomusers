//
//  UserCell.swift
//  RandomUsers
//
//  Created by Magdalena Szlagor on 18/03/2018.
//  Copyright © 2018 Magdalena Szlagor. All rights reserved.
//

import UIKit

protocol UserCellDelegate: AnyObject {
    func removeUserFromFavourties(user: UserModel?)
    func addUserToFavourties(user: UserModel?)
}

class UserCell: UITableViewCell {
    
    @IBOutlet weak var favButton: UIButton?
    @IBOutlet weak var avatarImage: RemoteImageView?
    @IBOutlet weak var nameLabel: UILabel?
    @IBOutlet weak var addressLabel: UILabel?
    @IBOutlet weak var phoneLabel: UILabel?
    @IBOutlet weak var emailLabel: UILabel?
    weak var delegate: UserCellDelegate?
    
    var userModel: UserModel? {
        didSet {
            if let model = userModel {
                nameLabel?.text = model.name.toString()
                addressLabel?.text = model.location.toString()
                avatarImage?.loadImageFromUrl(urlString: model.photo.thumbnailPhoto)
                phoneLabel?.text = model.mobilePhone
                emailLabel?.text = model.email
            }
        }
    }
    
    var userFeedType: UserFeedModelType? {
        didSet {
            let image = favButton?.imageView?.image
            let grayImage = image?.imageWithColor(color: GlobalConstants.kGrayColor)
            let greenImage = image?.imageWithColor(color: GlobalConstants.kGreenColor)
            if let type = userFeedType {
                let selectedImage = type == .allUsers ? greenImage : grayImage
                let normalImage = type == .allUsers ? grayImage : greenImage
                
                favButton?.setImage(normalImage, for: .normal)
                favButton?.setImage(selectedImage, for: .highlighted)
                favButton?.setImage(selectedImage, for: .selected)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        nameLabel?.text = nil
        addressLabel?.text = nil
        phoneLabel?.text = nil
        avatarImage?.image = nil
        contentView.backgroundColor = .white
    }
    
    @IBAction func changeFavouriteValue() {
        if userFeedType == .allUsers {
            delegate?.addUserToFavourties(user: userModel)
        }
        else {
            delegate?.removeUserFromFavourties(user: userModel)
        }
    }
    
    override func prepareForReuse() {
        nameLabel?.text = nil
        addressLabel?.text = nil
        phoneLabel?.text = nil
        avatarImage?.image = nil
        
        super.prepareForReuse()
    }
}
