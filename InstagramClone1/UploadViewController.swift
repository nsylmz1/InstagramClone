

import UIKit
import Firebase
import FirebaseStorage
import FirebaseAuth

class UploadViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var commentText: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.isUserInteractionEnabled = true
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(chooseImage))
        imageView.addGestureRecognizer(gestureRecognizer)

    }
    @objc func chooseImage(){
        let picker = UIImagePickerController()
                picker.delegate = self
                picker.sourceType = .photoLibrary // .
                picker.allowsEditing = true
                present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let editedImage = info[.editedImage] as? UIImage {
            imageView.image = editedImage
        } else if let originalImage = info[.originalImage] as? UIImage {
            imageView.image = originalImage
        }
        dismiss(animated: true, completion: nil)
    }
    func makeAlert(titleInput : String , messageInput : String){
        let alert = UIAlertController(title: titleInput, message: messageInput, preferredStyle: UIAlertController.Style.alert)
        let okButton = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
        alert.addAction(okButton)
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func uploadButtonClicked(_ sender: Any) {
        let storage = Storage.storage()
                let storageReference = storage.reference()
                
                let mediaFolder = storageReference.child("media")
                
                
                if let data = imageView.image?.jpegData(compressionQuality: 0.5) {
                    
                    let uuid = UUID().uuidString
                    
                    let imageReference = mediaFolder.child("\(uuid).jpg")
                    imageReference.putData(data, metadata: nil) { (metadata, error) in
                        if error != nil {
                            self.makeAlert(titleInput: "Error!", messageInput: error?.localizedDescription ?? "Error")
                        } else {
                            
                            imageReference.downloadURL { (url, error) in
                                
                                if error == nil {
                                    
                                    let imageUrl = url?.absoluteString
                                    
                                    
                                    //DATABASE
                                    
                                    let firestoreDatabase = Firestore.firestore()
                                    
                                    var firestoreReference : DocumentReference? = nil
                                    
                                    let firestorePost = ["imageUrl" : imageUrl!, "postedBy" : Auth.auth().currentUser!.email!, "postComment" : self.commentText.text!,"date" : FieldValue.serverTimestamp(), "likes" : 0 ] as [String : Any]

                                    firestoreReference = firestoreDatabase.collection("Posts").addDocument(data: firestorePost, completion: { (error) in
                                        if error != nil {
                                            
                                            self.makeAlert(titleInput: "Error!", messageInput: error?.localizedDescription ?? "Error")
                                            
                                        } else {
                                            
                                            self.imageView.image = UIImage(named: "select (1).png")
                                            self.commentText.text = ""
                                            self.tabBarController?.selectedIndex = 0
                                            
                                        }
                                    })
                        }
                    }
                }
            }
        }
        
    }
    
   
}
