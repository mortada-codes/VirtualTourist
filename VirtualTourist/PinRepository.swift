//
//  PinRepository.swift
//  VirtualTourist
//
//  Created by mahmoud mortada on 2/22/19.
//  Copyright © 2019 mahmoud mortada. All rights reserved.
//

import Foundation
import CoreData

class PinRepository{
    let ENTITY_PIN = "Pin"
    let ENTITY_Image = "Photo"
    let contextManager: NSManagedObjectContext
    let entity:NSEntityDescription
    init(context:NSManagedObjectContext){
        self.contextManager = context
        entity = NSEntityDescription.entity(forEntityName: ENTITY_PIN, in: contextManager)!
    }
    
    
    func createPin(lat:Double,lon:Double){
       let pin =  Pin(context: contextManager)
    
     
        pin.lat = lat
        pin.lon = lon
        do {
            try contextManager.save()
        }catch let err as NSError{
            
        }
        
    }
    
    func updatePin(lat:Double,lon:Double){
        
    }
    
    
    func addImage(lat:Double,lon:Double,data:Data,urlString:String){
        let newPhoto = Photo(context: contextManager)
        newPhoto.image = data
        newPhoto.url = urlString
        let pin = fetchPin(lat: lat, lon: lon)
        if (pin != nil){
             pin?.addToPhotos(newPhoto)
        }
        do {
            try contextManager.save()
        }catch let _ as NSError{
            
        }
    }
    
    func deleteImage(lat:Double,lon:Double,url:String){
        let pin = fetchPin(lat: lat, lon: lon)
        if (pin != nil){
            pin?.photos?.map({item in return item as! Photo}).filter({photo in photo.url == url}).forEach({photo in contextManager.delete(photo)})
        }
        do {
            try contextManager.save()
        }catch let _ as NSError{
            
        }
    }
    
    func deleteImage(lat:Double,lon:Double,photo:Photo){
        let pin = fetchPin(lat: lat, lon: lon)
        if (pin != nil){
            pin?.removeFromPhotos(photo)
        }
        do {
            try contextManager.save()
        }catch let _ as NSError{
            
        }
    }
    func deleteAllImagesForPin(lat:Double,lon:Double){
        let pin = fetchPin(lat: lat, lon: lon)
        if (pin != nil){
            pin?.removeFromPhotos((pin?.photos)!)
        }
        do {
            try contextManager.save()
        }catch let _ as NSError{
            
        }
    }
    
    func fetchPin(lat:Double,lon:Double) -> Pin?{
        let fetchRequest = NSFetchRequest<Pin>(entityName: ENTITY_PIN)
        let predicate = NSPredicate(format: " lat = %@  AND lon = %@ ", argumentArray: [lat,lon])
        
        fetchRequest.predicate = predicate
        do{
            let result = try  contextManager.fetch(fetchRequest)
            return result.first
        }catch let err as NSError{
            return nil
        }
    }
    
    
    func fetchImages(lat:Double,lon:Double,onComplete:@escaping(_ data:[Photo]?,_ error:PinError?)->Void){
        let fetchRequest = NSFetchRequest<Pin>(entityName: ENTITY_PIN)
        let predicate = NSPredicate(format: " lat = %@  AND lon = %@ ", argumentArray: [lat,lon])
    
        fetchRequest.predicate = predicate
        do{
         let result = try  contextManager.fetch(fetchRequest)
            if(result.count == 0){
                onComplete(nil,nil)
                return 
            }
            
            let photos = result.first?.photos
            guard photos != nil else {
                return
            }
          
            onComplete(  photos?.allObjects as! [Photo],nil)
        }catch let err as NSError{
            onComplete(nil,PinError.NOTFOUNDPINS)
        }
        
    }
    
    
    
    
    
}
