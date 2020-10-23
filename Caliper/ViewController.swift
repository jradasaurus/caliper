import Mapbox

var globalMapView: MGLMapView?

var polylineSource: MGLShapeSource?

var caliperCoords: [CLLocationCoordinate2D] = [
    CLLocationCoordinate2D(latitude: 30, longitude: -82),
    CLLocationCoordinate2D(latitude: 26, longitude: -82)
]

func updatePolylineWithCoordinates(coordinates: [CLLocationCoordinate2D]) {
    var mutableCoordinates = coordinates
    
    let polyline = MGLPolylineFeature(coordinates: &mutableCoordinates, count: UInt(mutableCoordinates.count))
    
    // Updating the MGLShapeSource’s shape will have the map redraw our polyline with the current coordinates.
    polylineSource?.shape = polyline
}

class ViewController: UIViewController, MGLMapViewDelegate {
    var caliperCounter = 0
    
    var mapView: MGLMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView = MGLMapView(frame: view.bounds)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.setCenter(CLLocationCoordinate2D(latitude: 28, longitude: -82), zoomLevel: 9, animated: false)
        mapView.zoomLevel = 6
        mapView.delegate = self
        view.addSubview(mapView)
        
        globalMapView = mapView
    }
    
    func addPolyline(to style: MGLStyle) {
        let source = MGLShapeSource(identifier: "polyline", shape: nil, options: nil)
        style.addSource(source)
        polylineSource = source
        
        let layer = MGLLineStyleLayer(identifier: "polyline", source: source)
        layer.lineJoin = NSExpression(forConstantValue: "round")
        layer.lineCap = NSExpression(forConstantValue: "round")
        layer.lineColor = NSExpression(forConstantValue: UIColor.red)
        
       
        style.addLayer(layer)
    }
    
    
    
    func mapView(_ mapView: MGLMapView, viewFor annotation: MGLAnnotation) -> MGLAnnotationView? {
        if let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "draggablePoint") {
            return annotationView
        } else {
            let view = DraggableAnnotationView(reuseIdentifier: "draggablePoint", size: 50, caliperId: caliperCounter)
            
            caliperCounter += 1
            
            return view
        }
    }
    
    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        return true
    }
    
    func mapViewDidFinishLoadingMap(_ mapView: MGLMapView) {
        let coordinates = [
            CLLocationCoordinate2D(latitude: 30, longitude: -82),
            CLLocationCoordinate2D(latitude: 26, longitude: -82)
        ]
        
        var pointAnnotations = [MGLPointAnnotation]()
        for coordinate in coordinates {
            let point = MGLPointAnnotation()
            point.coordinate = coordinate
            point.title = "To drag this annotation, first tap and hold."
            pointAnnotations.append(point)
        }
        
        mapView.addAnnotations(pointAnnotations)
        addPolyline(to: mapView.style!)
        updatePolylineWithCoordinates(coordinates: caliperCoords)
    }
}

// MGLAnnotationView subclass
class DraggableAnnotationView: MGLAnnotationView {
    var caliperId: Int = 0
    
    init(reuseIdentifier: String, size: CGFloat, caliperId: Int) {
        self.caliperId = caliperId
        
        super.init(reuseIdentifier: reuseIdentifier)
 
        isDraggable = true
        scalesWithViewingDistance = false
     
        frame = CGRect(x: 0, y: 0, width: size, height: size)
        backgroundColor = .darkGray
        layer.cornerRadius = size / 2
        layer.borderWidth = 1
        layer.borderColor = UIColor.white.cgColor
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.1
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setDragState(_ dragState: MGLAnnotationViewDragState, animated: Bool) {
        super.setDragState(dragState, animated: animated)
        
        switch dragState {
        case .starting:
            print("Starting", terminator: "")
            startDragging()
        case .dragging:
            print(".", terminator: "")
            
            let newCoordinate = globalMapView!.convert(center, toCoordinateFrom: nil)
            caliperCoords[caliperId] = newCoordinate
            updatePolylineWithCoordinates(coordinates: caliperCoords)
            
        case .ending, .canceling:
            print("Ending")
            endDragging()
        case .none:
            break
        @unknown default:
            fatalError("Unknown drag state")
        }
    }
    
    func startDragging() {
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: [], animations: {
            self.layer.opacity = 0.8
            self.transform = CGAffineTransform.identity.scaledBy(x: 1.5, y: 1.5)
        }, completion: nil)
    }
    
    func endDragging() {
        transform = CGAffineTransform.identity.scaledBy(x: 1.5, y: 1.5)
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: [], animations: {
            self.layer.opacity = 1
            self.transform = CGAffineTransform.identity.scaledBy(x: 1, y: 1)
        }, completion: nil)
    }
}
