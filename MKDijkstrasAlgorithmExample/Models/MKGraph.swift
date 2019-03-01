/*
    Created by Elijah Sawyers on 2/27/19.
    Copyright © 2019 Elijah Sawyers. All rights reserved.

    Abstract:
    This file contains the necessary classes to implement a weighted, directional
    graph using MapKit. Nodes in the graph represent points on an MKMapView,
    and each edge's weight is the distance between the source and destination,
    measured in meters.
 */

import Foundation
import MapKit

/**
    This class is used as a node (a.k.a. vertex) in a MKWeightedDirectionalGraph.
 */
class MKNode {
    /// The identifier for the node.
    let name: String
    
    /// The Mercator coordinates of the node.
    let coordinates: MKMapPoint
    
    /// The edges, with weights, to all adjacent nodes.
    var edgesToAdjacentNodes: [MKEdge]
    
    /**
     Initializes an MKNode with the specified Mercator coordinate details.
     
     - parameter name: The identifier for the node.
     - parameter x: The x value of the Mercator coordinate.
     - parameter y: The y value of the Mercator coordinate.
     */
    init(name: String, x: Double, y: Double) {
        self.name = name
        self.coordinates = MKMapPoint(x: x, y: y)
        self.edgesToAdjacentNodes = []
    }
    
    /**
     Adds an edge to another node.
     - parameter edge: The MKEdge to add to the node.
     */
    func add(edge: MKEdge) {
        edgesToAdjacentNodes.append(edge)
    }
    
    /**
     Removes an edge from this node.
     - parameter edge: The MKEdge to be deleted from the node.
     */
    func remove(edge: MKEdge) {
        edgesToAdjacentNodes = edgesToAdjacentNodes.filter { !($0 === edge) }
    }
    
    /**
     Adds an edge to another node.
     - parameter destination: The destination node of the edge.
     */
    func addEdgeTo(destination: MKNode) {
        edgesToAdjacentNodes.append(MKEdge(source: self, destination: destination))
    }
    
    /**
     Removes an edge from this node.
     - parameter destination: The destination node of the edge to be deleted.
     */
    func removeEdgeFrom(destination: MKNode) {
        edgesToAdjacentNodes = edgesToAdjacentNodes.filter { !($0.destination === destination) }
    }
    
    
    /**
     Gets an edge from this node to another, if available.
     - parameter destination: The destination node of the edge to be deleted.
     - returns: An optional MKEdge, depending on whether or not the edge exists.
     */
    func edgeForDestination(destination: MKNode) -> MKEdge? {
        return edgesToAdjacentNodes.filter { $0.destination === destination }.first
    }
    
    /**
     Gets the number of edges from this node.
     - returns: The number of edges from this node.
     */
    func edgeCount() -> Int {
        return edgesToAdjacentNodes.count
    }
}

/**
    This class represents an edge (a.k.a. connection) in a MKWeightedDirectionalGraph.
 */
class MKEdge {
    /// The source node.
    let source: MKNode
    
    /// The destination node.
    let destination: MKNode
    
    /// The distance, measured in meters, between the two MKMapPoints (i.e. the weight of the edge).
    let weight: Double
    
    /**
     Initializes an MKEdge with the two supplied MKNodes.
     - parameter source: The source node of the edge.
     - parameter destination: The destination node of the edge.
     */
    init(source: MKNode, destination: MKNode) {
        self.source = source
        self.destination = destination
        self.weight = source.coordinates.distance(to: destination.coordinates)
    }
}

/**
    This class implements a weighted, directional graph using MapKit. Nodes in
    the graph represent points on an MKMapView, and each edge's weight is the
    distance between the source and destination, measured in meters.
 */
class MKWeightedDirectionalGraph {
    /// All nodes currently in the graph.
    private var nodes: [MKNode] = []
    
    func getNodes() -> [MKNode] {
        return nodes
    }
    
    /**
     Adds a node to the graph.
     - note: If the node with the same identifier is already in the graph, its information will be updated.
     - parameter node: The MKNode object to insert into the graph.
     */
    func add(node: MKNode) {
        for i in 0..<nodes.count {
            if nodes[i].name == node.name {
                nodes[i] = node
                return
            }
        }
        nodes.append(node)
    }
    
    /**
     Removes a node from the graph.
     - parameter node: The MKNode object to remove from the graph.
     */
    func remove(node: MKNode) {
        nodes = nodes.filter { !($0 === node) }
    }
    
    /**
     Removes a node from the graph, if it exists.
     - parameter node: The MKNode object to remove from the graph.
     */
    func removeNodeWith(name: String) {
        nodes = nodes.filter { $0.name != name }
    }
    
    /**
     Returns a node from the graph.
     - parameter name: The identifier of the node to return.
     - returns: An optional MKNode, depending on whether or not a node with the identifier exists.
     */
    func getNodeWith(name: String) -> MKNode? {
        return nodes.filter { $0.name == name }.first
    }
    
    /**
     Adds an edge to an existing node in the graph.
     - note: The edge will be disgarded if the source node doesn't exist in the graph.
     - parameter edge: The MKEdge to add to the graph.
     */
    func add(edge: MKEdge) {
        for node in nodes {
            if node === edge.source {
                node.add(edge: edge)
            }
        }
    }
    
    /**
     Removes an edge from the graph, if it exists.
     - parameter edge: The MKEdge to add to the graph.
     */
    func remove(edge: MKEdge) {
        for node in nodes {
            node.remove(edge: edge)
        }
    }
    
    /**
     Gets the number of nodes in the graph.
     - returns: The number of nodes in the graph.
     */
    func nodeCount() -> Int {
        return nodes.count
    }
    
    /**
     Gets the number of nodes in the graph.
     - returns: The number of edges in the graph.
     */
    func edgeCount() -> Int {
        var total = 0
        for node in nodes {
            total += node.edgeCount()
        }
        return total
    }
}
