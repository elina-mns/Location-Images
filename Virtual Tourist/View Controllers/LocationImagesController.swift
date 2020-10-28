//
//  LocationImagesController.swift
//  Virtual Tourist
//
//  Created by Elina Mansurova on 2020-10-21.
//

import Foundation
import MapKit
import CoreData

class LocationImagesController: UIViewController, MKMapViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
   
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var addCollection: UIButton!
    @IBOutlet weak var noImagesFound: UILabel!
    @IBOutlet weak var newCollection: UIButton!
    
    var photos: [Photo] = []
    private let reuseIdentifier = "ImageCell"
    var coordinates: CLLocationCoordinate2D?
    
    var dataController: DataController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        collectionView.delegate = self
        collectionView.dataSource = self
        newCollection.isEnabled = false
        focusOnMap()
        if checkIfThereAreSavedImages() {
            loadPhotoFromDataBase()
            newCollection.isEnabled = true
        } else {
            downloadImages()
        }
        noImagesFound.isHidden = true
    }
    
    @IBAction func didTapNewCollection(_ sender: Any) {
        photos = []
        collectionView.reloadData()
        downloadImages()
    }
    
    func focusOnMap() {
        guard let coordinates = coordinates else {
            return
        }
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinates
        
        mapView.addAnnotation(annotation)
        let regionFocus = MKCoordinateRegion(center: coordinates, latitudinalMeters: 50000, longitudinalMeters: 50000)
        mapView.setRegion(regionFocus, animated: true)
    }
    
    fileprivate func checkIfThereAreSavedImages() -> Bool {
        if let pin = pinFromLocation() {
            return pin.photos?.count != 0
        }
        return false
    }
    
    func pinFromLocation() -> Pin? {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Pin")
        guard let coordinates = coordinates else {
            return nil
        }
        request.predicate = NSPredicate(format: "latitude == %lf && longitude == %lf", coordinates.latitude, coordinates.longitude)
        return try? dataController.viewContext.fetch(request).first as? Pin
    }
    
    func loadPhotoFromDataBase() {
        guard let pin = pinFromLocation(), let photos = pin.photos else {
            return
        }
        for photo in photos {
            if let savedPhoto = photo as? SavedPhoto,
               let imageData = savedPhoto.imageData {
                var photo = Photo()
                photo.image = UIImage(data: imageData)
                self.photos.append(photo)
            }
        }
        collectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    fileprivate func savePhotoToCoreData(_ image: UIImage?) {
        let savedPhoto = SavedPhoto(context: self.dataController.viewContext)
        savedPhoto.imageData = image?.jpegData(compressionQuality: 1.0)
        self.pinFromLocation()?.addToPhotos(savedPhoto)
        do {
            try self.dataController.viewContext.save()
        } catch {
            print(error)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ImageCell
        let photo = self.photos[indexPath.row]
        if let image = photo.image {
            cell.imageView.image = image
        } else {
            cell.imageView.loadFromURL(photoUrl: photo.urlToDownload) { [weak self] image in
                guard let self = self else { return }
                self.savePhotoToCoreData(image)
            }
        }
        return cell
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is MKPointAnnotation else { print("no mkpointannotaions"); return nil }
        
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.rightCalloutAccessoryView = UIButton(type: .infoDark)
            pinView!.pinTintColor = UIColor.black
        }
        else {
            pinView!.annotation = annotation
        }
        return pinView
    }
    
    func downloadImages() {
        guard let coordinates = coordinates else {
            return
        }
        Client.getCollection(coordinate: coordinates) { (result) in
            switch result {
            case .success(let response):
                self.photos = response.photos.photo
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                    if self.photos.isEmpty {
                        self.noImagesFound.isHidden = false
                    }
                }
            case .failure:
                self.noImagesFound.isHidden = false
            }
            self.newCollection.isEnabled = true
        }
    }
    
    
}

extension LocationImagesController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let space: CGFloat = 3.0
        let dimension = (view.frame.size.width - (2 * space)) / 3.0
        let size = CGSize(width:dimension, height: dimension)
        return size
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 3.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout
                            collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 3.0
    }
}

