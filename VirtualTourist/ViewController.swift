//
//  ViewController.swift
//  VirtualTourist
//
//  Created by mahmoud mortada on 2/15/19.
//  Copyright © 2019 mahmoud mortada. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class ViewController: UIViewController {
   
    var locationRepository:LocationRepository?
    var pinRepository:PinRepository?
    @IBOutlet weak var mapView: MKMapView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
            mapView.delegate = self
        
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate{
            locationRepository = LocationRepository(context: appDelegate.persistentContainer.viewContext)
        
             self.pinRepository = PinRepository(context: appDelegate.persistentContainer.viewContext)
      
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
    
    }

    @IBAction func onTap(_ sender: UITapGestureRecognizer) {
        
        if(sender.state == .ended){
            let locationInView = sender.location(in: mapView)
            let tappedCoordinate = mapView.convert(locationInView, toCoordinateFrom: mapView)
            addAnnotation(coordinate: tappedCoordinate)
            self.pinRepository?.createPin(lat: tappedCoordinate.latitude, lon: tappedCoordinate.longitude)
        }
    }
    
    func addAnnotation(coordinate:CLLocationCoordinate2D){
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    

}


extension ViewController :MKMapViewDelegate{
    
    	
    
    
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
      let region = mapView.region
        locationRepository?.setLocation(lat: region.center.latitude, lon: region.center.longitude,latDelta:region.span.latitudeDelta,lonDelta:region.span.longitudeDelta)
       
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            let coords =        view.annotation?.coordinate
        let addPhotoController = storyboard?.instantiateViewController(withIdentifier: "AddPhotosController") as? AddPhotosViewController
        addPhotoController?.lat = coords?.latitude
        addPhotoController?.lon = coords?.longitude
            present(addPhotoController!, animated: true)
    }
   
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let addPhotoController = storyboard?.instantiateViewController(withIdentifier: "AddPhotosController")
        present(addPhotoController!, animated: true)
    }
    
    func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
    //    mapView.addAnnotation(TouristAnnotation(coordinate:  mapView.region.center))
            
        if let currentLocation =   locationRepository?.getLocation(),(currentLocation != nil){
            
        
            let coords = CLLocationCoordinate2D(latitude: currentLocation.lat, longitude: currentLocation.lon)
        let region = MKCoordinateRegion(center: coords, span: MKCoordinateSpan(latitudeDelta: currentLocation.latDelta, longitudeDelta:currentLocation.lonDelta))
        mapView.setRegion(region, animated: true)
        }
        }
    
    
    
    
    
}

