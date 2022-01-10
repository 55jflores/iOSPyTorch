import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    //@IBOutlet var imageView: UIImageView!
    @IBOutlet weak var imageView: UIImageView!
    //@IBOutlet var resultView: UITextView!
    @IBOutlet weak var resultView: UILabel!
   
    let photoPicker = UIImagePickerController()
    
    private lazy var module: TorchModule = {
        if let filePath = Bundle.main.path(forResource: "model", ofType: "pt"),
            let module = TorchModule(fileAtPath: filePath) {
            return module
        } else {
            fatalError("Can't find the model file!")
        }
    }()

    private lazy var labels: [String] = {
        if let filePath = Bundle.main.path(forResource: "words", ofType: "txt"),
            let labels = try? String(contentsOfFile: filePath) {
            return labels.components(separatedBy: .newlines)
        } else {
            fatalError("Can't find the text file!")
        }
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // set delegate as current class
        photoPicker.delegate = self
        
        // Contains camera module: Allows user to take image using front or reat
        // Easiest way to user camera functionality in any app .photoLibrary
        photoPicker.sourceType = .photoLibrary
        
        //Bool value: If user is allowed to edit selected image or movie like cropping
        photoPicker.allowsEditing = false
        
    }
    // After user picked image
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        // Check if image was picked. ? Means this data should be UIImage type
        if let userPickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            // Display image
            imageView.image = userPickedImage

        }
        
        // Dismiss image picker. Go back to view controller
        //imagePicker.dismiss(animated: true, completion: nil)
        photoPicker.dismiss(animated: true, completion: nil)

    }
    
    //@IBAction func photoTapped(_ sender: Any) {
        // Once camera button is tapped
       // present(photoPicker, animated: false, completion: nil)
   // }
    
    
    @IBAction func photoTapped(_ sender: Any) {
        //Once camera button is tapped
        present(photoPicker, animated: false, completion: nil)
    }
    @IBAction func classify(_ sender: Any) {
        let image = imageView.image!
        //imageView.image = image
        let resizedImage = image.resized(to: CGSize(width: 224, height: 224))
        guard var pixelBuffer = resizedImage.normalized() else {
            return
        }
        guard let outputs = module.predict(image: UnsafeMutableRawPointer(&pixelBuffer)) else {
            return
        }
        let zippedResults = zip(labels.indices, outputs)
        let sortedResults = zippedResults.sorted { $0.1.floatValue > $1.1.floatValue }.prefix(1)
        var text = ""
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        for result in sortedResults {
            text += " \(labels[result.0]): \(formatter.string(from:result.1)!) % \n\n"
        }
        resultView.text = text
    }
    /*
    @IBAction func classify(_ sender: Any) {
        let image = imageView.image!
        //imageView.image = image
        let resizedImage = image.resized(to: CGSize(width: 224, height: 224))
        guard var pixelBuffer = resizedImage.normalized() else {
            return
        }
        guard let outputs = module.predict(image: UnsafeMutableRawPointer(&pixelBuffer)) else {
            return
        }
        let zippedResults = zip(labels.indices, outputs)
        let sortedResults = zippedResults.sorted { $0.1.floatValue > $1.1.floatValue }.prefix(1)
        var text = ""
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        for result in sortedResults {
            text += " \(labels[result.0]): \(formatter.string(from:result.1)!) % \n\n"
        }
        resultView.text = text
    }
 */
}
