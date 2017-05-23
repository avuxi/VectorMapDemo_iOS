//
//  PolygonRenderer.swift
//  AvuxiDemo
//
//  Created by Felix Lamouroux on 21.11.16.
//  Copyright © 2016 iosphere GmbH. All rights reserved.
//

import MapKit

extension CGPoint {
    func diff(with other: CGPoint, dividedBy divider: CGFloat = 2.0) -> CGPoint {
        return CGPoint(x: (x - other.x) / divider, y: (y - other.y) / divider)
    }
}

extension UIBezierPath {
    // based on https://github.com/FlexMonkey/ImageToneCurveEditor/blob/master/ToneCurveEditor/UIBezierPathExtension.swift
    convenience init?(interpolationPoints: [CGPoint], alpha: CGFloat = 1.0/3.0) {
        guard interpolationPoints.count > 2  else {
            return nil
        }

        self.init()
        move(to: interpolationPoints[0])
        let indices = interpolationPoints.indices

        let startIndex = interpolationPoints.startIndex
        let endIndex = interpolationPoints.endIndex - 1
        let count = interpolationPoints.count

        for index in indices {
            var currentPoint = interpolationPoints[index]
            var nextIndex = (index + 1) % count
            var prevIndex = ((index == startIndex) ? count : index) - 1
            var previousPoint = interpolationPoints[prevIndex]
            var nextPoint = interpolationPoints[nextIndex]
            let targetPoint = nextPoint
            var m: CGPoint

            // Control point 1
            if index > 0 {
                m = nextPoint.diff(with: previousPoint)
            } else {
                m = nextPoint.diff(with: currentPoint)
            }

            let controlPoint1 = CGPoint(x: currentPoint.x + m.x * alpha, y: currentPoint.y + m.y * alpha)

            // Control point 2
            currentPoint = interpolationPoints[nextIndex]
            nextIndex = (nextIndex + 1) % interpolationPoints.count
            prevIndex = index
            previousPoint = interpolationPoints[prevIndex]
            nextPoint = interpolationPoints[nextIndex]

            if index < endIndex - 1 {
                m = nextPoint.diff(with: previousPoint)
            } else  {
                m = currentPoint.diff(with: previousPoint)
            }

            let controlPoint2 = CGPoint(x: currentPoint.x - m.x * alpha, y: currentPoint.y - m.y * alpha)

            addCurve(to: targetPoint, controlPoint1: controlPoint1, controlPoint2: controlPoint2)
        }
    }

    var points: [CGPoint] {
        var points = [CGPoint]()
        ob_enumerateElements { (elementPointer) in
            guard let element = elementPointer?.pointee else {
                return
            }

            switch(element.type) {
            case .moveToPoint, .addLineToPoint:
                let point = element.points.pointee
                points.append(point)

            case .closeSubpath:
                if let first = points.first {
                    points.append(first)
                }

            default:
                assertionFailure("Unhandled path element of type \(element.type)")
                break
            }
        }
        return points
    }
}


class PolygonRenderer: MKPolygonRenderer {
    override func fillPath(_ path: CGPath, in context: CGContext) {

        let originalPath = UIBezierPath(cgPath: path)
        guard let smooth = UIBezierPath(interpolationPoints: originalPath.points) else {
            super.fillPath(path, in: context)
            return
        }
        
        super.fillPath(smooth.cgPath, in: context)
    }
}
