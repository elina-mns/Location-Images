//
//  UIimageView+load.swift
//  Virtual Tourist
//
//  Created by Elina Mansurova on 2020-10-23.
//

import UIKit

private let cache = NSCache<NSString, NSData>()

extension UIImageView {
    //load image async from internet
    func loadFromURL(photoUrl: URL){
        if let cachedData = cache.object(forKey: photoUrl.absoluteString as NSString) {
            DispatchQueue.main.async {
                self.image = UIImage(data: cachedData as Data)
            }
            return
        }
        //Request
        let request = URLRequest(url: photoUrl);
        //Session
        let session = URLSession.shared
        //Data task
        let datatask = session.dataTask(with: request) { (data, response, error) -> Void in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            guard let data = data else {
                return
            }
            cache.setObject(data as NSData, forKey: photoUrl.absoluteString as NSString)
            DispatchQueue.main.async {
                self.image = UIImage(data: data)
            }
        }
        datatask.resume()
    }


}
