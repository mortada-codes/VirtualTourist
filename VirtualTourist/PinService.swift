//
//  PinService.swift
//  VirtualTourist
//
//  Created by mahmoud mortada on 2/22/19.
//  Copyright © 2019 mahmoud mortada. All rights reserved.
//

import Foundation




public enum PinError:Error{
   case NOTFOUNDPINS
}

class PinService {
    
    
    let pinRepo :PinRepository
    let flickerAPI:FLickerAPI
    init(pinRepo:PinRepository,flickerAPI:FLickerAPI) {
        self.pinRepo = pinRepo
        self.flickerAPI = flickerAPI
    }
    
    
    func fetchImages(lat:Double,lon:Double,onFetchLocal:@escaping(_ data:[Photo]?,_ error:PinError?)->Void,onFetchServer:@escaping (_ data:[PhotoInfo]?,_ error:PinError?)->Void){
        pinRepo.fetchImages(lat: lat,lon: lon){ data,error in
            if(data == nil){
                  self.saveOrUpdatePin(lat: lat, lon: lon, onComplete: onFetchServer)
            }else{
             onFetchLocal(data,error)
            }

            
            
        }
        
    }
    
    func saveImageToDisk(lat:Double,lon:Double,data:Data,urlString:String){
        pinRepo.addImage(lat:lat,lon:lon,data:data,urlString:urlString)
    }
    
    func deleteImageFromDisk(lat:Double,lon:Double,url:String){
        pinRepo.deleteImage(lat: lat,lon:lon,url:url)
    }
    
    func deleteImageFromDisk(lat:Double,lon:Double,photo:Photo){
        pinRepo.deleteImage(lat: lat,lon:lon,photo:photo)
    }
    
    func deleteAllImagesForPin(lat:Double,lon:Double){
        pinRepo.deleteAllImagesForPin(lat: lat,lon:lon)
    }
    func saveOrUpdatePin(lat:Double,lon:Double,onComplete:@escaping (_ data:[PhotoInfo]?,_ error:PinError?)->Void){
        self.flickerAPI.fetchRecentPhotos(lat: lat, long: lon){data,error in
            onComplete(data,error)
            
        }
    }
    
    func downloadImage(photoInfo:PhotoInfo,onComplete:@escaping (_ data:Data?,_ error:Error?)->Void){
         flickerAPI.downloadImage(photoInfo: photoInfo, onComplete: onComplete)
    }
    
}
