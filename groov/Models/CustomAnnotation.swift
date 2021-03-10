//
//  CustomAnnotation.swift
//  groov
//
//  Created by Alice Wu on 3/9/21.
//

import Foundation
import MapKit

class CustomAnnotation: NSObject, MKAnnotation {
    let userID: String?
    let trackName: String?
    let trackArtist: String?
    let trackImage: String?
    let trackPreview: String?
    let coordinate: CLLocationCoordinate2D

    init(
        userID: String?,
        trackName: String?,
        trackArtist: String?,
        trackImage: String?,
        trackPreview: String?,
        coordinate: CLLocationCoordinate2D
    ) {
        self.userID = userID
        self.trackName = trackName
        self.trackArtist = trackArtist
        self.trackImage = trackImage
        self.trackPreview = trackPreview
        self.coordinate = coordinate

        super.init()
    }

    var title: String? {
      let text = "\(trackName!)"
      return text
    }
    
    var subtitle: String? {
    let text = "\(trackArtist!)"
    return text
    }
}

