//
//  TaskDetailViewController.swift
//  lab-task-squirrel
//
//
//

import UIKit
import MapKit
import PhotosUI
import CoreLocation
// TODO: Import PhotosUI

class TaskDetailViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet private weak var completedImageView: UIImageView!
    @IBOutlet private weak var completedLabel: UILabel!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var attachPhotoButton: UIButton!

    // MapView outlet
    @IBOutlet private weak var mapView: MKMapView!
    
    @IBOutlet weak var viewPhoto: UIButton!

    var task: Task!
    
    private let locationManager = CLLocationManager()
        private var currentLocation: CLLocation?
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//
//            // Segue to Detail View Controller
//         if segue.identifier == "PhotoSegue" {
//             if let photoViewController = segue.destination as? PhotoViewController {
//                 photoViewController.task = task
//              }
//          }
//      }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Request location permissions
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
        
        // Register custom annotation view
        mapView.register(TaskAnnotationView.self, forAnnotationViewWithReuseIdentifier: TaskAnnotationView.identifier)
        
        // Set mapView delegate
        mapView.delegate = self
        
        
        // TODO: Register custom annotation view

        // TODO: Set mapView delegate

        // UI Candy
        mapView.layer.cornerRadius = 12


        updateUI()
        updateMapView()
    }

    // ✅ Handles successful location updates
        func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            if let latestLocation = locations.last {
                currentLocation = latestLocation
            }
        }

        // ✅ Handles location errors (Fix for the crash)
        func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
            print("❌ Location update failed: \(error.localizedDescription)")
        }

    /// Configure UI for the given task
    private func updateUI() {
//        titleLabel.text = task.title
        descriptionLabel.text = task.description
        
        let completedImage = UIImage(systemName: task.isComplete ? "circle.inset.filled" : "circle")
        
        // calling `withRenderingMode(.alwaysTemplate)` on an image allows for coloring the image via it's `tintColor` property.
        completedImageView.image = completedImage?.withRenderingMode(.alwaysTemplate)
        completedLabel.text = task.isComplete ? task.title: task.title
        
        let color: UIColor = task.isComplete ? .systemBlue : .tertiaryLabel
        completedImageView.tintColor = color
        completedLabel.textColor = color
        
        attachPhotoButton.isHidden = task.isComplete
       
//        viewPhoto.isHidden = !task.isComplete
        
    }

    @IBAction func didTapAttachPhotoButton(_ sender: Any) {
        
        let alert = UIAlertController(title: "Choose Photo", message: "Select an option", preferredStyle: .actionSheet)

               let cameraAction = UIAlertAction(title: "Take Photo", style: .default) { _ in
                   self.openCamera()
               }

               let libraryAction = UIAlertAction(title: "Choose from Library", style: .default) { _ in
                   self.checkPhotoLibraryPermission()
               }

               let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)

               alert.addAction(cameraAction)
               alert.addAction(libraryAction)
               alert.addAction(cancelAction)

               present(alert, animated: true)
           }

    
    private func openCamera() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            showAlert(title: "Camera Unavailable", message: "Camera access is not available on this device.")
            return
        }
        
        locationManager.requestLocation()  // ✅ Request the latest GPS location
        
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = self
        present(picker, animated: true)
    }

    
    private func checkPhotoLibraryPermission() {
            if PHPhotoLibrary.authorizationStatus(for: .readWrite) != .authorized {
                PHPhotoLibrary.requestAuthorization(for: .readWrite) { [weak self] status in
                    DispatchQueue.main.async {
                        if status == .authorized {
                            self?.presentImagePicker()
                        } else {
                            self?.presentGoToSettingsAlert()
                        }
                    }
                }
            } else {
                presentImagePicker()
            }
        }

    private func presentImagePicker() {
        
        // Create a configuration object
        var config = PHPickerConfiguration(photoLibrary: PHPhotoLibrary.shared())

        // Set the filter to only show images as options (i.e. no videos, etc.).
        config.filter = .images

        // Request the original file format. Fastest method as it avoids transcoding.
        config.preferredAssetRepresentationMode = .current

        // Only allow 1 image to be selected at a time.
        config.selectionLimit = 1

        // Instantiate a picker, passing in the configuration.
        let picker = PHPickerViewController(configuration: config)

        // Set the picker delegate so we can receive whatever image the user picks.
        picker.delegate = self

        // Present the picker.
        present(picker, animated: true)
        
        // TODO: Create, configure and present image picker.

    }

    func updateMapView() {
        
        // Make sure the task has image location.
        guard let imageLocation = task.imageLocation else { return }

        // Get the coordinate from the image location. This is the latitude / longitude of the location.
        // https://developer.apple.com/documentation/mapkit/mkmapview
        let coordinate = imageLocation.coordinate

        // Set the map view's region based on the coordinate of the image.
        // The span represents the maps's "zoom level". A smaller value yields a more "zoomed in" map area, while a larger value is more "zoomed out".
        let region = MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        mapView.setRegion(region, animated: true)
        
        
        // Add an annotation to the map view based on image location.
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
        
        // TODO: Set map viewing region and scale

        // TODO: Add annotation to map view
    }
}

// TODO: Conform to PHPickerViewControllerDelegate + implement required method(s)

// TODO: Conform to MKMapKitDelegate + implement mapView(_:viewFor:) delegate method.

// Helper methods to present various alerts
extension TaskDetailViewController {

    /// Presents an alert notifying user of photo library access requirement with an option to go to Settings in order to update status.
    func presentGoToSettingsAlert() {
        let alertController = UIAlertController (
            title: "Photo Access Required",
            message: "In order to post a photo to complete a task, we need access to your photo library. You can allow access in Settings",
            preferredStyle: .alert)

        let settingsAction = UIAlertAction(title: "Settings", style: .default) { _ in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }

            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl)
            }
        }

        alertController.addAction(settingsAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)

        present(alertController, animated: true, completion: nil)
    }

    /// Show an alert for the given error
    private func showAlert(title: String = "Oops...", message: String) {
        let alertController = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )

        let action = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(action)

        present(alertController, animated: true)
    }

}

extension TaskDetailViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {

        // Dismiss the picker
        picker.dismiss(animated: true)

        // Get the selected image asset (we can grab the 1st item in the array since we only allowed a selection limit of 1)
        let result = results.first

        // Get image location
        // PHAsset contains metadata about an image or video (ex. location, size, etc.)
        guard let assetId = result?.assetIdentifier,
              let location = PHAsset.fetchAssets(withLocalIdentifiers: [assetId], options: nil).firstObject?.location else {
            return
        }

        print("📍 Image location coordinate: \(location.coordinate)")
        
        // Make sure we have a non-nil item provider
        guard let provider = result?.itemProvider,
              // Make sure the provider can load a UIImage
              provider.canLoadObject(ofClass: UIImage.self) else { return }

        // Load a UIImage from the provider
        provider.loadObject(ofClass: UIImage.self) { [weak self] object, error in

            // Handle any errors
            if let error = error {
                DispatchQueue.main.async { [weak self] in
                    self?.showAlert(title: "Error", message: error.localizedDescription)
                }

            }

            // Make sure we can cast the returned object to a UIImage
            guard let image = object as? UIImage else { return }

            print("🌉 We have an image!")

            // UI updates should be done on main thread, hence the use of `DispatchQueue.main.async`
            DispatchQueue.main.async { [weak self] in

                // Set the picked image and location on the task
                self?.task.set(image, with: location)

                // Update the UI since we've updated the task
                self?.updateUI()

                // Update the map view since we now have an image an location
                self?.updateMapView()
            }
        }
    }
    

}

extension TaskDetailViewController: MKMapViewDelegate {
    
    // Implement mapView(_:viewFor:) delegate method.
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {

        // Dequeue the annotation view for the specified reuse identifier and annotation.
        // Cast the dequeued annotation view to your specific custom annotation view class, `TaskAnnotationView`
        // 💡 This is very similar to how we get and prepare cells for use in table views.
        guard let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: TaskAnnotationView.identifier, for: annotation) as? TaskAnnotationView else {
            fatalError("Unable to dequeue TaskAnnotationView")
        }

        // Configure the annotation view, passing in the task's image.
        annotationView.configure(with: task.image)
        return annotationView
    }

}

// MARK: - UIImagePickerControllerDelegate (Handling Camera)
extension TaskDetailViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {

        picker.dismiss(animated: true)

        guard let image = info[.originalImage] as? UIImage else { return }

        // Use the current location if available; otherwise, default to (0,0)
        let imageLocation = currentLocation ?? CLLocation(latitude: 0, longitude: 0)

        print("📍 Captured image location: \(imageLocation.coordinate.latitude), \(imageLocation.coordinate.longitude)")

        DispatchQueue.main.async {
            self.task.set(image, with: imageLocation)  //
            self.updateUI()
            self.updateMapView()
        }
    }
}

