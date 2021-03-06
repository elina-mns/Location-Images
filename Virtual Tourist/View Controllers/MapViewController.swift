//
//  MapViewController.swift
//  Location Images
//
//  Created by Elina Mansurova on 2020-10-21.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    var dataController: DataController!
    
    var fetchResultsController: NSFetchedResultsController<Pin>!
    
    private func setupFetchedResultsController() {
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "latitude", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "Pin")
        fetchResultsController.delegate = self
        do {
            try fetchResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be executed: \(error.localizedDescription)")
        }
    }
    
   
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleTap))
        mapView.addGestureRecognizer(gestureRecognizer)
        
        setupFetchedResultsController()
        
        let pins: [Pin] = fetchResultsController.fetchedObjects ?? []
        for pin in pins {
            insertInMapView(pin: pin)
        }
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "SavedLocation")
        if let savedLocation = try? dataController.viewContext.fetch(request).first as? SavedLocation {
            let coordinate = CLLocationCoordinate2D(latitude: savedLocation.latitude, longitude: savedLocation.longitude)
            let span = MKCoordinateSpan(latitudeDelta: savedLocation.spanLatitude, longitudeDelta: savedLocation.spanLongitude)
            let regionFocus = MKCoordinateRegion(center: coordinate, span: span)
            mapView.setRegion(regionFocus, animated: false)
        }
    }
    
    @objc func handleTap(gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == .ended {
            let location = gestureRecognizer.location(in: mapView)
            let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
            // save to database
            savePin(coordinate: coordinate)
            
            let regionFocus = MKCoordinateRegion(center: coordinate, latitudinalMeters: 50000, longitudinalMeters: 50000)
            mapView.setRegion(regionFocus, animated: true)
        }
    }
    
    func savePin(coordinate: CLLocationCoordinate2D) {
        let pin = Pin(context: dataController.viewContext)
        pin.latitude = coordinate.latitude
        pin.longitude = coordinate.longitude
        do {
            try dataController.viewContext.save()
        } catch {
            print(error)
        }
    }
    
    func deletePin(coordinate: CLLocationCoordinate2D) {
        print("deleting")
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Pin")
        request.predicate = NSPredicate(format: "latitude == %lf && longitude == %lf", coordinate.latitude, coordinate.longitude)
        if let pinToDelete = try? dataController.viewContext.fetch(request).first as? Pin {
            dataController.viewContext.delete(pinToDelete)
            try? dataController.viewContext.save()
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is MKPointAnnotation else { print("no mkpointannotaions"); return nil }
        
        let reuseId = "pin"
        let pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView ?? MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
        pinView.canShowCallout = true
        let infoButton = UIButton(type: .infoDark)
        infoButton.tag = 1
        pinView.rightCalloutAccessoryView = infoButton
        let closeButton = UIButton(type: .close)
        closeButton.tag = 2
        pinView.leftCalloutAccessoryView = closeButton
        pinView.pinTintColor = .black
        pinView.annotation = annotation
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control.tag == 1 {
            guard let vc = storyboard?.instantiateViewController(identifier: "LocationImagesController") as? LocationImagesController else {
                return
            }
            vc.coordinates = view.annotation?.coordinate
            vc.dataController = dataController
            
            self.navigationController?.pushViewController(vc, animated: true)
        } else if control.tag == 2, let coordinate = view.annotation?.coordinate {
            showConfirmationForDelete(title: "Delete Selected Location",
                                      message: "Are you sure you want to delete the current pin?") {
                self.deletePin(coordinate: coordinate)
            }
        }
    }
    
    func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
        let centerLatitude = mapView.region.center.latitude
        let centerLongitude = mapView.region.center.longitude
        let spanLatitude = mapView.region.span.latitudeDelta
        let spanLongitude = mapView.region.span.longitudeDelta
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "SavedLocation")
        if let savedLocation = try? dataController.viewContext.fetch(request).first as? SavedLocation {
            savedLocation.latitude = centerLatitude
            savedLocation.longitude = centerLongitude
            savedLocation.spanLatitude = spanLatitude
            savedLocation.spanLongitude = spanLongitude
            try? dataController.viewContext.save()
        } else {
            let savedLocation = SavedLocation(context: dataController.viewContext)
            savedLocation.latitude = centerLatitude
            savedLocation.longitude = centerLongitude
            savedLocation.spanLatitude = spanLatitude
            savedLocation.spanLongitude = spanLongitude
            try? dataController.viewContext.save()
        }
    }
}

extension MapViewController: NSFetchedResultsControllerDelegate {
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            insertInMapView(pin: anObject as? Pin)
        case .delete:
            deleteInMapView(pin: anObject as? Pin)
        case .update:
            break
        case .move:
            break
        @unknown default:
            fatalError()
        }
    }
    
    func insertInMapView(pin: Pin?) {
        guard let pin = pin,
              let annotation = annotationFromPin(pin: pin) else {
            return
        }
        annotation.title = "\(pin.latitude), \(pin.longitude)"
        mapView.addAnnotation(annotation)
    }
    
    func annotationFromPin(pin: Pin?) -> MKPointAnnotation? {
        guard let pin = pin else {
            return nil
        }
        let coordinate = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        return annotation
    }
    
    func deleteInMapView(pin: Pin?) {
        guard let pin = pin,
              let annotationToRemove = mapView.annotations.first(where: { $0.coordinate.latitude == pin.latitude && $0.coordinate.longitude == pin.longitude }) else {
            return
        }
        mapView.removeAnnotation(annotationToRemove)
    }
}
