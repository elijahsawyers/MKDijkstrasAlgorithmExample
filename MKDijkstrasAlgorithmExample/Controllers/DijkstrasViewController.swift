/*
    Created by Elijah Sawyers on 2/21/19.
    Copyright © 2019 Elijah Sawyers. All rights reserved.

    Abstract:
    Demonstrates how to use the MKDijkstrasAlgorithm framework.
 */

import UIKit
import MapKit
import MKDijkstrasAlgorithm

/**
    Interacts with Dijkstra's algorithm framework and displays the results in the MKMapView.

    - note: This is an example of how to implement Dijkstra's algorithm in places of
    interest, such as parks or golf courses, so that users can more easily
    navigate a venue lacking navigation services.
 */
class DijkstrasViewController: UIViewController, MKMapViewDelegate {
    
    /// The starting point for dijkstras algorithm.
    var startAnnotation: MKPointAnnotation?
    
    /// The ending point for dijkstras algorithm.
    var endAnnotation: MKPointAnnotation?
    
    /// The graph with nodes as MKMapPoints.
    var graph: MKWeightedDirectionalGraph!
    
    /// The Dijkstras alorithm object to be used on MKMapKitPoints.
    var dijkstras: MKDijkstrasAlgorithm!
    
    /// The initial position of the mapView camera.
    let initialCamera = MKMapCamera(lookingAtCenter: CLLocationCoordinate2D(latitude: 31.222871, longitude: -85.417598),
                                    fromDistance: 3000,
                                    pitch: 0,
                                    heading: 0)
    
    /// Outlet to the mapView.
    @IBOutlet weak var mapView: MKMapView! {
        didSet {
            // Set the camera to the center of the golf course.
            mapView.setCamera(initialCamera, animated: true)
            
            // Set various mapView properties.
            mapView.delegate = self
            mapView.showsCompass = false
            mapView.mapType = .mutedStandard
            mapView.showsPointsOfInterest = false
        }
    }
    
    // Handles the creation of annotations' views.
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "Annotation"
        
        let view:MKPinAnnotationView
        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView {
            dequeuedView.annotation = annotation
            view = dequeuedView
        } else {
            view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view.canShowCallout = false
        }
        
        return view
    }
    
    // Handles when annotations are tapped.
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        // Set the start point if no annotations have been clicked.
        if startAnnotation == nil {
            clearOverlays()
            startAnnotation = view.annotation as? MKPointAnnotation
        } else {
            // Otherwise, set the endAnnotation and perform dijkstra's algorithm.
            endAnnotation = view.annotation as? MKPointAnnotation
            
            // Find shortest path between points.
            var path = dijkstras.shortestPath(start: startAnnotation!.title!, end: endAnnotation!.title!)
            
            // Traverse the path, grabbing the MKMapPoints.
            var shortestPathPoints: [CLLocationCoordinate2D] = []
            while path != nil {
                shortestPathPoints.append(path!.node.coordinates.coordinate)
                path = path?.previousPath
            }
            
            // Create and add a polyline overlay.
            let polyLine = MKPolyline(coordinates: &shortestPathPoints, count: shortestPathPoints.count)
            mapView.addOverlay(polyLine)
            
            // Set the start and end back to nil.
            startAnnotation = nil
            endAnnotation = nil
        }
    }
    
    // Handles rendering the polyline.
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let overlayRenderer = MKPolylineRenderer(overlay: overlay)
        overlayRenderer.strokeColor = UIColor.blue
        overlayRenderer.lineWidth = 2
        return overlayRenderer
    }
    
    /// Clears the MKPolylines and resets the camera to its initial state.
    @IBAction func resetToInitialState(_ sender: Any) {
        // Set the camera back to initial position.
        mapView.setCamera(initialCamera, animated: true)
        startAnnotation = nil
        endAnnotation = nil
        clearOverlays()
    }
    
    /// Removes all overlays from the mapView.
    func clearOverlays() {
        let overlays = mapView.overlays
        for overlay in overlays {
            mapView.removeOverlay(overlay)
        }
    }
    
    // Setup the annotations and graph.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Some arbitrary test points on the golf course.
        var latLons: [CLLocationCoordinate2D] = []
        latLons.append(CLLocationCoordinate2D(latitude: 31.222890, longitude: -85.421010))
        latLons.append(CLLocationCoordinate2D(latitude: 31.223779, longitude: -85.419583))
        latLons.append(CLLocationCoordinate2D(latitude: 31.223789, longitude: -85.417737))
        latLons.append(CLLocationCoordinate2D(latitude: 31.223770, longitude: -85.416128))
        latLons.append(CLLocationCoordinate2D(latitude: 31.222688, longitude: -85.414562))
        latLons.append(CLLocationCoordinate2D(latitude: 31.221880, longitude: -85.415999))
        latLons.append(CLLocationCoordinate2D(latitude: 31.221945, longitude: -85.417705))
        latLons.append(CLLocationCoordinate2D(latitude: 31.221972, longitude: -85.419711))
        latLons.append(CLLocationCoordinate2D(latitude: 31.222807, longitude: -85.417673))
        
        // Convert coordinates to MKMapPoints
        var points: [MKMapPoint] = []
        for coordinate in latLons {
            points.append(MKMapPoint(coordinate))
        }
        
        // Initialize graph.
        graph = MKWeightedDirectionalGraph()
        
        // Create Nodes.
        var nodes: [MKNode] = []
        
        for i in 0..<points.count {
            let node = MKNode(name: String(i), x: points[i].x, y: points[i].y)
            nodes.append(node)
            graph.add(node: node)
        }
        
        // Create Edges.
        nodes[0].addEdgeTo(destination: nodes[1])
        nodes[0].addEdgeTo(destination: nodes[7])
        
        nodes[1].addEdgeTo(destination: nodes[0])
        nodes[1].addEdgeTo(destination: nodes[7])
        nodes[1].addEdgeTo(destination: nodes[2])
        
        nodes[2].addEdgeTo(destination: nodes[1])
        nodes[2].addEdgeTo(destination: nodes[3])
        nodes[2].addEdgeTo(destination: nodes[8])
        nodes[2].addEdgeTo(destination: nodes[5])
        
        nodes[3].addEdgeTo(destination: nodes[2])
        nodes[3].addEdgeTo(destination: nodes[5])
        nodes[3].addEdgeTo(destination: nodes[4])
        
        nodes[4].addEdgeTo(destination: nodes[3])
        nodes[4].addEdgeTo(destination: nodes[5])
        
        nodes[5].addEdgeTo(destination: nodes[2])
        nodes[5].addEdgeTo(destination: nodes[3])
        nodes[5].addEdgeTo(destination: nodes[4])
        nodes[5].addEdgeTo(destination: nodes[6])
        
        nodes[6].addEdgeTo(destination: nodes[5])
        nodes[6].addEdgeTo(destination: nodes[7])
        nodes[6].addEdgeTo(destination: nodes[8])
        
        nodes[7].addEdgeTo(destination: nodes[0])
        nodes[7].addEdgeTo(destination: nodes[1])
        nodes[7].addEdgeTo(destination: nodes[6])
        nodes[7].addEdgeTo(destination: nodes[8])
        
        nodes[8].addEdgeTo(destination: nodes[2])
        nodes[8].addEdgeTo(destination: nodes[6])
        nodes[8].addEdgeTo(destination: nodes[7])
        
        // Add annotations for MapPoints.
        for i in 0..<points.count {
            let annotation = MKPointAnnotation()
            annotation.title = nodes[i].name
            annotation.coordinate = latLons[i]
            mapView.addAnnotation(annotation)
        }
        
        // Initialize dijkstra's algorithm with the weighted, directed graph.
        dijkstras = MKDijkstrasAlgorithm(graph: graph)
    }
}

