//
//  ViewController.swift
//  Gopemon KO
//
//  Created by Francesco Thiery on 26/07/16.
//  Copyright © 2016 Coocked. All rights reserved.
//

import UIKit
import MapKit

/*
 https://pokevision.com/map/data/-33.871021303288/151.21165752411
 http://ugc.pokevision.com/images/pokemon/19.png
 
 //expiration_time
 //latitude
 //longitude
 //pokemonId
 */

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate{
    
    @IBOutlet weak var mapView: MKMapView!
    var locationManager : CLLocationManager!
    var networkOperation : SimpleNetworkOperation!
    var userHasBeenLocated = false
    var coordinate : CLLocationCoordinate2D?
    var beans = [PokemonBean]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "PokeRadar"
//        self.navigationController?.navigationBar.barTintColor = UIColor.greenColor()
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .Follow
        NSTimer.scheduledTimerWithTimeInterval(10,
                                               target: self,
                                               selector: #selector(ViewController.performRequest),
                                               userInfo: nil,
                                               repeats: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //NSLog("Updated Location:" + locations.description
        if let coordinate = manager.location?.coordinate{
            self.coordinate = coordinate
            self.userHasBeenLocated = true
        }
    }
    
    func performRequest(){
//        let request = NSURLRequest(URL: NSURL(string: "http://ugc.pokevision.com/images/pokemon/19.png")!)
//         NSURLConnection.sendAsynchronousRequest(request,
//                                                 queue: NSOperationQueue.mainQueue(),
//                                                 completionHandler: imageCompletion)
        
        if userHasBeenLocated{
            networkOperation = SimpleNetworkOperation(url: "https://pokevision.com/map/data/" + coordinate!.latitude.description + "/" + coordinate!.longitude.description)
            networkOperation.get(jsonCompletion, headerParams: nil)
        }
    }
    
    func jsonCompletion(data : AnyObject?, code : Int?, error: NSError?){
        var beans = [PokemonBean]()
        if let pokemons = data?["pokemon"] as? NSMutableArray{
            for p in pokemons{
                let bean = PokemonBean()
                NetworkJSONUtils.bindMembers(fromData: p, toObject: bean)
                beans.append(bean)
            }
        }
        self.beans = beans
        dispatch_async(GlobalMainQueue) { 
            self.addMarkers()
        }
    }
    
    func addMarkers(){
        mapView.removeAnnotations(mapView.annotations)
        for pokeBean in beans {
            if pokeBean.isValid(){
                let annotation = PokeAnnotation()
                let lat = Double(pokeBean.latitude!)
                let lng = Double(pokeBean.longitude!)
                annotation.pokeBean = pokeBean
             
                annotation.coordinate = CLLocationCoordinate2DMake(lat,lng)
                mapView.addAnnotation(annotation)
            }
        }
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if let pokeAnnotation = annotation as? PokeAnnotation{
            let annView = PokeAnnotationView(annotation: annotation, reuseIdentifier: nil)
            annView.getImage(pokeAnnotation.pokeBean.pokemonId!)
            annView.canShowCallout = true
            annView.enabled = true
            //annView.d = NSDate(timeIntervalSince1970: pokeAnnotation.pokeBean.expiration_time!)
            return annView
        }
        return nil
    }
}

class PokeAnnotationView : MKAnnotationView{
    func getImage(byId : NSNumber){
        let request = NSURLRequest(URL: NSURL(string: "http://ugc.pokevision.com/images/pokemon/" + byId.stringValue + ".png")!)
        NSURLConnection.sendAsynchronousRequest(request,
                                                queue: NSOperationQueue.mainQueue(),
                                                completionHandler: imageCompletion)
    }
    
    func imageCompletion(response: NSURLResponse?, data : NSData?, error : NSError?){
        dispatch_async(GlobalMainQueue) {
            if data != nil{
                self.image = UIImage(data: data!)
            }
        }
    }
}

class PokeAnnotation : MKPointAnnotation{
    var pokeBean : PokemonBean!
    override var title: String? {
        get {
            let formattedTime = NSString(format: "%.1f", NSDate(timeIntervalSince1970: Double(pokeBean.expiration_time!)).timeIntervalSinceNow)
//            self.title = formattedTime as String
            return formattedTime as String + "s"
        }set{
            
        }
    }
}

