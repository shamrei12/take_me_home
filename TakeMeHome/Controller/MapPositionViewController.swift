//
//  MapPositionViewController.swift
//  TakeMeHome
//
//  Created by Алексей Шамрей on 10.03.23.
//

import UIKit
import MapKit

class MapPositionViewController: UIViewController {
    private var geocoder: GeocoderModel!
    let annotations = MKPointAnnotation()
    private var zoom = 25000
    private var latitude: Double = 0.0
    private var longtitude: Double = 0.0

    @IBOutlet weak var mapView: MKMapView!
    override func viewDidLoad() {
        super.viewDidLoad()
        geocoder = GeocoderModel()
    }


    func updateMap(adress: String) {
        
        geocoder.adressToСoordinates(adress: adress) { [self] (latitude, longtitude) in
            DispatchQueue.main.async {
                self.latitude = latitude
                self.longtitude = longtitude
                workMapKit(latitude: latitude, longtitude: longtitude)
            }
            
        }
        
    }
    
    
    func workMapKit(latitude: Double, longtitude: Double) {
        annotations.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longtitude)
        mapView.addAnnotation(annotations)
        
        let cameraCenterd = CLLocationCoordinate2D(latitude: latitude, longitude: longtitude)
        let region = MKCoordinateRegion(center: cameraCenterd, latitudinalMeters: 5000, longitudinalMeters: 5000)
        mapView.setCameraBoundary(MKMapView.CameraBoundary(coordinateRegion: region), animated: true)
        
        let zoomRage = MKMapView.CameraZoomRange(maxCenterCoordinateDistance: CLLocationDistance(zoom))
        mapView.setCameraZoomRange(zoomRage, animated: false)
        mapView.isZoomEnabled = true
    }
    
    @IBAction func zoomPlus(_ sender: UIButton) {
        zoom -= 2500
        
        if zoom > -18500 {
            let zoomRage = MKMapView.CameraZoomRange(maxCenterCoordinateDistance: CLLocationDistance(zoom))
            mapView.setCameraZoomRange(zoomRage, animated: false)
        }
    }
    
    @IBAction func zoomMinus(_ sender: UIButton) {
        zoom += 2500
        let zoomRage = MKMapView.CameraZoomRange(minCenterCoordinateDistance: CLLocationDistance(zoom))
        mapView.setCameraZoomRange(zoomRage, animated: false)
    }


}
