//
//  FlickerAPI.swift
//  VirtualTourist
//
//  Created by mahmoud mortada on 2/19/19.
//  Copyright © 2019 mahmoud mortada. All rights reserved.
//

import Foundation
import PhotosUI

class FLickerAPI {
    
    let API_KEY = "24dbffb73c95414ca21a413f7d8b9e6c"
    let API_SECRET = "c60a26b2445ff22d"
    let urlSession = URLSession.shared
    let decoder = JSONDecoder()
    func recentPhotosURL(lat:Double,lon:Double) -> URL{
        return URL(string:"https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(API_KEY)&format=json&nojsoncallback=1&lat=\(lat)&lon=\(lon)&per_page=15")!
    }
    
    func photoURLBuilder(farm_id:Int,server_id:String,id:String,secret:String) -> URL {
        return URL(string:"https://farm\(farm_id).staticflickr.com/\(server_id)/\(id)_\(secret).jpg")!
    }
    
    func fetchRecentPhotos(lat:Double,long:Double,onComplete:@escaping(_ data:[PhotoInfo]?,_ error:PinError?)->Void){
        struct APIResponse :Codable{
            var photos:FlickerPhoto
        var stat:String
        }
        struct FlickerPhoto :Codable {
            var page:Int
            var pages: Int
            var perpage: Int
            var total: String
            var photo:[PhotoInfo]
           
        }
        let task = urlSession.dataTask(with: recentPhotosURL(lat: lat,lon: long)){data,response,error in
            guard  error == nil else {
                    return
            }
            
            
            guard let res =  response as? HTTPURLResponse else {
                return
            }
            
            if(res.statusCode != 200){
                return
            }
            do{
                
                let photos = try self.decoder.decode(APIResponse.self, from: data!)
                onComplete(photos.photos.photo,nil)
               
            }catch let error  {
                print(error)
                      onComplete(nil,PinError.NOTFOUNDPINS)
            }
          
        
            
            
            
        }
        
        task.resume()
    }
    
    func downloadImage(photoInfo:PhotoInfo,onComplete:@escaping (_ data:Data?,_ error:Error?)->Void){
        
      let task =   urlSession.dataTask(with: photoURLBuilder(farm_id: photoInfo.farm!, server_id: photoInfo.server!, id: photoInfo.id!, secret: photoInfo.secret!)){data,response,error in
        
        guard error == nil ,data != nil else {
            onComplete(nil,error)
            return
        }
       
        onComplete(data,error)
        }
    
        task.resume()
        
    }
    
    
    
    
}
