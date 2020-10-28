//
//  GetPhotosResponse.swift
//  Location Images
//
//  Created by Elina Mansurova on 2020-10-22.
//

import UIKit

struct GetPhotosResponse: Codable {
    let photos: PhotoArray
}

struct PhotoArray: Codable {
    let photo: [Photo]
}

struct Photo: Codable {
    let id: String
    let secret: String
    let server: String
    var image: UIImage?
    
    init() {
        id = ""
        secret = ""
        server = ""
    }
    
    enum CodingKeys: String, CodingKey {
        case id, secret, server
    }
    
    var urlToDownload: URL {
        URL(string: "https://live.staticflickr.com/\(server)/\(id)_\(secret).jpg")!
    }
}
