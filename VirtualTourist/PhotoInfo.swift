//
//  PhotoInfo.swift
//  VirtualTourist
//
//  Created by mahmoud mortada on 2/19/19.
//  Copyright © 2019 mahmoud mortada. All rights reserved.
//

import Foundation


class PhotoInfo :Codable{
    
    
   let id: String?
    let owner: String?
    let secret: String?
    let server: String?
    let farm: Int?
    let title: String?
    let ispublic: Int
    let isfriend: Int
    let isfamily: Int
 
    func toFullURL() -> String {
        return "https://farm\(String(describing: farm)).staticflickr.com/\(server ?? "")/\(String(describing: id))_\(String(describing: secret)).jpg"
    }
}
