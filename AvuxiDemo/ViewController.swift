//
//  ViewController.swift
//  Avuxi Demo
//
//  Created by Felix Lamouroux on 22/11/16.
//  Copyright © 2016 iosphere GmbH. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate  {

    // MARK: - Outlets
    @IBOutlet private weak var segmentedControlPoiCategory: UISegmentedControl?
    @IBOutlet private weak var map: MKMapView?

    private enum PoiCategory: String {
        case eating, nightlife, shopping, sightseeing

        //static let all: [PoiCategory] = [.eating, .nightlife, .shopping, .sightseeing]
        static let all: [PoiCategory] = [.sightseeing, .eating, .shopping, .nightlife]

        var overlay: AUIOverlay? {
            guard let filePath = Bundle.main.path(forResource: "json_\(rawValue)", ofType: "json"),
                let data = try? Data(contentsOf: URL(fileURLWithPath: filePath)),
                let safeOverlay = AUIOverlay(from: data) else {
                    return nil
            }

            return safeOverlay
        }

        var icon: UIImage? {
            return UIImage(named: "icon_\(rawValue)_grey")
        }
    }

    // MARK: - POI Category Selection

    @IBAction private func segmentedControlPoiChanged(_ sender: UISegmentedControl) {
        let index = sender.selectedSegmentIndex
        guard PoiCategory.all.indices.contains(index) else {
            return
        }

        let category = PoiCategory.all[index]
        overlay = category.overlay
    }

    private var overlay: AUIOverlay? {
        didSet {
            guard let safeMap = map else {
                return
            }

            if (oldValue != nil) {
                safeMap.removeOverlays(safeMap.overlays)
            }

            guard let safeOverlay = overlay else {
                return
            }

            for level in safeOverlay.levels {
                safeMap.addOverlays(level.polygons, level: .aboveRoads)
            }
        }
    }

    // MARK: - View Lifecycle 

    override func viewDidLoad() {
        super.viewDidLoad()
        CenterMap(lat: 41.3845, lon: 2.165, zoom: 0.5)
        setupSegmentedControl()
    }

    private func setupSegmentedControl() {
        guard let control = segmentedControlPoiCategory else {
            assertionFailure()
            return
        }

        control.removeAllSegments()
        var count = 0
        for poiCategory in PoiCategory.all {
            guard let icon = poiCategory.icon else {
                assertionFailure("Missing icon for \(poiCategory.rawValue)")
                continue
            }

            control.insertSegment(with: icon, at: count, animated: false)
            count += 1;
        }

        control.selectedSegmentIndex = 0
        overlay = PoiCategory.all[0].overlay
    }

    func CenterMap(lat: CLLocationDegrees,lon: CLLocationDegrees, zoom: CLLocationDegrees) {
        let span = MKCoordinateSpanMake(zoom, zoom)
        let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude:lat, longitude: lon), span: span)
        map?.setRegion(region, animated: true)
    }

    // MARK: - MKMapViewDelegate

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        guard let p = overlay as? AUIOverlayPolygon else {
            assertionFailure()
            return MKOverlayRenderer(overlay: overlay)
        }

        let pr = PolygonRenderer(polygon: p.polygon)
        pr.fillColor = UIColor.orange.withAlphaComponent(p.level?.opacity ?? 0.1)
        pr.lineWidth = 0

        return pr
    }
}
