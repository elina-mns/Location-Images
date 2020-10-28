//
//  Client.swift
//  Location Images
//
//  Created by Elina Mansurova on 2020-10-22.
//

import Foundation
import MapKit

class Client {
    
    static let apiKey = "e6a4f20b60ddf3398bfe3d3d97ac922a"
    
    
    enum Endpoints {
        static let baseUrl = "https://www.flickr.com/services/rest/"
        case getCollection(lat: Double, lon: Double)
        var stringValue: String {
            switch self {
            case let .getCollection(lat, lon):
                return Client.Endpoints.baseUrl + "?method=flickr.photos.search&api_key=\(Client.apiKey)&lat=\(lat)&lon=\(lon)&rad=5&format=json&nojsoncallback=1"
            }
        }
        var url: URL {
            return URL(string: stringValue)!
        }
    }
        
    static func getCollection(coordinate: CLLocationCoordinate2D, completion: @escaping (Result<GetPhotosResponse, Error>) -> Void) {
        let url = Endpoints.getCollection(lat: coordinate.latitude, lon: coordinate.longitude).url
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else {
                completion(.failure(error!))
                return
            }
            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(GetPhotosResponse.self, from: data)
                completion(.success(response))
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
}
