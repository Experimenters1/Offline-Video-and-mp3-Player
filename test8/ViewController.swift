//
//  ViewController.swift
//  test
//
//  Created by huy on 07/04/2023.
//

import UIKit
import AVFoundation
import AVKit
import MobileCoreServices

class ViewController: UIViewController, UINavigationControllerDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    let userDefaults = UserDefaults.standard
    var links: [[String: Any]] = []

        override func viewDidLoad() {
            super.viewDidLoad()

            loadLinks()
                    
            //tableView.register(UITableViewCell.self, forCellReuseIdentifier: "LinkCell")
                tableView.dataSource = self
                tableView.delegate = self
                tableView.reloadData()
        }


    // MARK: Load Links
       
       func loadLinks() {
           if let savedLinks = userDefaults.array(forKey: "savedLinks") as? [[String: Any]] {
               links = savedLinks
           }
       }
       
       // MARK: Save Links
       
       func saveLinks() {
           userDefaults.set(links, forKey: "savedLinks")
       }
       
    @IBAction func addLinkButtonTapped(_ sender: Any) {
        let filePicker = UIDocumentPickerViewController(documentTypes: [kUTTypeMP3 as String, kUTTypeMovie as String], in: .import)
        // tạo một UIDocumentPickerViewController để cho phép người dùng chọn tài liệu
        filePicker.delegate = self   // thiết lập delegate cho UIDocumentPickerViewController
        present(filePicker, animated: true)  // hiển thị UIDocumentPickerViewController
    }

    @IBAction func selectPhotoButtonTapped(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.mediaTypes = [kUTTypeMovie as String, kUTTypeImage as String]
        present(picker, animated: true)
    }

}

// MARK: - UITableViewDataSource

// MARK: - UITableViewDataSource

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return links.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier")
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "reuseIdentifier")
        }
        
        if let link = links[indexPath.row] as? [String: Any] {
            cell.textLabel?.text = link["name"] as? String
            cell.detailTextLabel?.text = link["date"] as? String
            if let url = link["url"] as? URL {
                cell.detailTextLabel?.text = url.path
            }
        }
        
        return cell
    }
}

// MARK: - UIDocumentPickerDelegate
extension ViewController: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let selectedUrl = urls.first else { return }
        
        let name = selectedUrl.lastPathComponent
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .medium
        let date = dateFormatter.string(from: Date())
        
        let newLink = ["name": name, "date": date, "url": selectedUrl.absoluteString]
        links.append(newLink)
        saveLinks()
        tableView.reloadData()
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}


// MARK: - UITableViewDelegate



extension ViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let urlString = links[indexPath.row]["url"] as? String, let url = URL(string: urlString) {
            let pathExtension = url.pathExtension
            
            if pathExtension == "mp3" {
                // Nếu là file nhạc mp3
                let player = AVPlayer(url: url)
                let playerViewController = AVPlayerViewController()
                playerViewController.player = player
                present(playerViewController, animated: true) {
                    player.play()
                }
            } else  {
                // Nếu là file video mp4, mov, avi, mpeg, flv, webm, hoặc wmv
                let player = AVPlayer(url: url)
                let playerViewController = AVPlayerViewController()
                playerViewController.player = player
                present(playerViewController, animated: true) {
                    player.play()
                }
            }
            }
        }
    }



    
    
// MARK: - UIDocumentPickerDelegate

extension ViewController: UIImagePickerControllerDelegate {

func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    if let mediaType = info[UIImagePickerController.InfoKey.mediaType] as? String,
       let url = info[UIImagePickerController.InfoKey.mediaURL] as? URL,
       mediaType == (kUTTypeMovie as String) {
        
        let name = url.lastPathComponent
           
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .medium
        let date = dateFormatter.string(from: Date())
        
        var type = ""
        if let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, url.pathExtension as CFString, nil)?.takeRetainedValue() {
            if let mimeType = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType)?.takeRetainedValue() {
                type = mimeType as String
            }
        }
        
        let newLink = ["name": name, "date": date, "type": type, "url": url.absoluteString]
        links.append(newLink)
        saveLinks()
        tableView.reloadData()
    }
    
    picker.dismiss(animated: true, completion: nil)
}

func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    picker.dismiss(animated: true, completion: nil)
}
}


    
    // MARK: - UIImagePickerControllerDelegate

extension URL {
    var typeIdentifier: String? {
        return (try? resourceValues(forKeys: [.typeIdentifierKey]))?.typeIdentifier
    }
}
