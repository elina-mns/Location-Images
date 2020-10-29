//
//  ImageCell.swift
//  Location Images
//
//  Created by Elina Mansurova on 2020-10-23.
//

import UIKit

class ImageCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                layer.borderWidth = 2.0
                layer.borderColor = UIColor.gray.cgColor
            } else {
                layer.borderColor = UIColor.clear.cgColor
            }
        }
    }
    
}
