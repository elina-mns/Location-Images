//
//  MapViewController.swift
//  Virtual Tourist
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
    }
    
    @objc func handleTap(gestureRecognizer: UILongPressGestureRecognizer) {
        let location = gestureRecognizer.location(in: mapView)
        let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
        // save to database
        savePin(coordinate: coordinate)
        
        let regionFocus = MKCoordinateRegion(center: coordinate, latitudinalMeters: 50000, longitudinalMeters: 50000)
        mapView.setRegion(regionFocus, animated: true)
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
        guard let annotation = annotationFromPin(pin: pin) else {
            return
        }
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
        guard let annotation = annotationFromPin(pin: pin) else {
            return
        }
        mapView.removeAnnotation(annotation)
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let vc = storyboard?.instantiateViewController(identifier: "LocationImagesController") as? LocationImagesController else {
            return
        }
        vc.coordinates = view.annotation?.coordinate
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
