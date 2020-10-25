//
//  UIimageView+load.swift
//  Virtual Tourist
//
//  Created by Elina Mansurova on 2020-10-23.
//

import UIKit

extension UIImageView {


    //load image async from inaternet
    func loadFromURL(photoUrl: URL){
        //Request
        let request = URLRequest(url: photoUrl);
        //Session
        let session = URLSession.shared
        //Data task
        let datatask = session.dataTask(with: request) { (data, response, error) -> Void in
            if error != nil {
                print(error?.localizedDescription)
            }
            DispatchQueue.main.async {
                self.image = UIImage(data: data!)
            }
        }
        datatask.resume()
    }


}
