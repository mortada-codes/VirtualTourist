//
//  AddPhotosViewController.swift
//  VirtualTourist
//
//  Created by mahmoud mortada on 2/18/19.
//  Copyright © 2019 mahmoud mortada. All rights reserved.
//

import UIKit
import MapKit

import Photos
class AddPhotosViewController: UIViewController{
    
    private let sectionInsets = UIEdgeInsets(top: 20.0,
                                             left: 20.0,
                                             bottom: 20.0,
                                             right: 20.0)
    private let itemsPerRow: CGFloat = 3
    @IBOutlet weak var collectionView: UICollectionView!
    let reuseIdentifier = "photoViewCell"
    var pinService:PinService?
    var pinPhotos:[PhotoInfo?] = []
    var photos :[Photo?] = []
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var btnAddColection: UIButton!
    @IBOutlet weak var photoCollectionView: UICollectionView!
  
    
   public var lat:Double?
   public var lon:Double?
    
    @IBAction func onOkayPressed(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true)
    }
    
    override func viewDidLoad() {
        photoCollectionView.delegate = self
        photoCollectionView.dataSource = self
        
        mapView.delegate = self
        btnAddColection.isEnabled = false
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate{
            let flickerAPI = FLickerAPI()
            let pinRepository = PinRepository(context: appDelegate.persistentContainer.viewContext)
            self.pinService = PinService(pinRepo: pinRepository, flickerAPI: flickerAPI)
        }
        
     
        pinService?.fetchImages(lat: lat!, lon: lon!,onFetchLocal:{ (photos:[Photo]?,error:PinError?) in
            guard error == nil,photos != nil else {
                return
            }
            self.photos.removeAll()
            self.photos = photos!
                self.collectionView.reloadData()
       self.btnAddColection.isEnabled = true
        },onFetchServer: { (data:[PhotoInfo]?,err:PinError?) in
            guard err == nil, data != nil else {
                return
            }
            
            DispatchQueue.main.async {
           
                self.pinPhotos.removeAll()
                self.pinPhotos =  data!
                self.collectionView.reloadData()
        self.btnAddColection.isEnabled = true
            }
            
        })
        
        
    }
    
    @IBAction func onAddCollection(_ sender: Any) {
        pinService?.saveOrUpdatePin(lat: self.lat!, lon: self.lon!){
            (data:[PhotoInfo]?,err:PinError?) in
            guard err == nil, data != nil else {
                return
            }
            
            DispatchQueue.main.async {
                
                self.pinPhotos.removeAll()
                self.pinPhotos =  data!
                self.photos.removeAll()
                self.pinService?.deleteAllImagesForPin(lat: self.lat!, lon: self.lon!)
                self.collectionView.reloadData()
                
            }
        }
    }
    
}


extension AddPhotosViewController :MKMapViewDelegate{
    func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
        if(lat != nil && lon != nil){
            let coords = CLLocationCoordinate2D(latitude: lat!, longitude: lon!)
            let region = MKCoordinateRegion(center: coords, span: MKCoordinateSpan(latitudeDelta: 0.225, longitudeDelta: 0.225))
            mapView.setRegion(region, animated: true)
            let point = MKPointAnnotation()
            point.coordinate = coords
         mapView.addAnnotation(point)
    }
}
}


extension AddPhotosViewController : UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }

    
}

extension AddPhotosViewController  :UICollectionViewDataSource,UICollectionViewDelegate{
   
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 15
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if(!pinPhotos.isEmpty && pinPhotos.count > indexPath.item){
            let item =  pinPhotos[indexPath.item]
            self.pinService?.deleteImageFromDisk(lat: self.lat!, lon: self.lon!, url: (item?.toFullURL())!)
            pinPhotos[indexPath.item] = nil
        }
        
        if(!photos.isEmpty && photos.count>indexPath.item){
            let item =  photos[indexPath.item]
            self.pinService?.deleteImageFromDisk(lat: self.lat!, lon: self.lon!, photo: item!)
            photos[indexPath.item] = nil
            
        }
        
       
        self.collectionView.reloadData()
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier,
                                                      for: indexPath) as! PhotoCollectionViewCell
        
      
        cell.backgroundColor = .gray
        if(!self.pinPhotos.isEmpty && self.pinPhotos.count > indexPath.item){
        let pinPhoto = self.pinPhotos[indexPath.item]
        if(pinPhoto != nil){
            pinService?.downloadImage(photoInfo: pinPhoto!){ data,error in
                if(data != nil){
                    self.pinService?.saveImageToDisk(lat: self.lat!, lon: self.lon!, data: data!, urlString: pinPhoto!.toFullURL())
                }
                    DispatchQueue.main.async {
                    
                if(data != nil){
                    if let image = UIImage(data:data!){
        cell.imageView.image = image
                    }
       
                }
            }
        }
        }else if (!photos.isEmpty && photos.count>indexPath.item){
            if let savedImageData = photos[indexPath.item]?.image{
                cell.imageView.image = UIImage(data:savedImageData)
            }
        }else{
            cell.imageView.image = nil

            }
        }
        
        return cell
       
    }
    
    
}


