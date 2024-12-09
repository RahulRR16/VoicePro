//
//  AudioFileListVC.swift
//  VoiceGo
//
//  Created by Rahul on 21/10/24.
//

import Foundation
import UIKit
import CoreData
import AVFAudio
import MobileCoreServices

class AudioFileListVC: BaseViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var savedAudioFiles: [AudioFile] = []
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        view.backgroundColor = UIColor(hexString: "#292C30")
        tableView.backgroundColor = UIColor(hexString: "#292C30")
//        tableView.bounces = false
        fetchSavedAudioFiles()
    }

    // Fetch saved audio files from Core Data
    func fetchSavedAudioFiles() {
        let request: NSFetchRequest<AudioFile> = AudioFile.fetchRequest()
        
        do {
            savedAudioFiles = try context.fetch(request)
            tableView.reloadData()
        } catch {
            print("Failed to fetch audio files: \(error)")
        }
    }

    // UITableView DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return savedAudioFiles.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "audioFileCell", for: indexPath)
        cell.backgroundColor = UIColor(hexString: "#292C30")
        cell.textLabel?.textColor = .white
        let audioFile = savedAudioFiles[indexPath.row]
        cell.textLabel?.text = audioFile.fileName
        return cell
    }

    // UITableView Delegate (play or save to files on selection)
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let audioFile = savedAudioFiles[indexPath.row]
        
        // Option to play or save to device files
        let alert = UIAlertController(title: audioFile.fileName, message: "What would you like to do?", preferredStyle: .actionSheet)
        
        // Play the audio
        alert.addAction(UIAlertAction(title: "Play", style: .default, handler: { _ in
            self.playAudio(audioFile: audioFile)
        }))
        
        // Save to device
        alert.addAction(UIAlertAction(title: "Save to Files", style: .default, handler: { _ in
            self.saveToFiles(audioFile: audioFile)
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    // Play audio function
    func playAudio(audioFile: AudioFile) {
        // Ensure the file URL string is not nil and convert it to a valid file URL
        if let filePath = audioFile.fileURL {
            if FileManager.default.fileExists(atPath: filePath) {
                print("File exists at path: \(filePath)")
            } else {
                print("File does not exist at path: \(filePath)")
            }
            let fileURL = URL(fileURLWithPath: filePath) // Use `fileURLWithPath` for local files
            do {
                let player = try AVAudioPlayer(contentsOf: fileURL)
                player.play()
            } catch {
                print("Error playing audio: \(error.localizedDescription)")
            }
        } else {
            print("Invalid file URL.")
        }
    }
    
    // Function to save audio file to Files app
    func saveToFiles(audioFile: AudioFile) {
        guard let audioURL = URL(string: audioFile.fileURL ?? "") else { return }

        // Create a temporary copy of the file in the app’s sandbox to present it for saving
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(audioURL.lastPathComponent)

        do {
            // Copy the file to a temporary location
            try FileManager.default.copyItem(at: audioURL, to: tempURL)
            
            // Create and present a UIDocumentPickerViewController to let the user choose where to save the file
            let documentPicker = UIDocumentPickerViewController(forExporting: [tempURL])
            documentPicker.delegate = self
            documentPicker.modalPresentationStyle = .formSheet
            present(documentPicker, animated: true)
            
        } catch {
            print("Error copying file for saving: \(error.localizedDescription)")
        }
    }

}

// Extend for UIDocumentInteractionControllerDelegate
extension AudioFileListVC: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        if let savedURL = urls.first {
            print("File saved at: \(savedURL.path)")
            // You can show a success message to the user here
        }
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        print("User cancelled the document picker")
    }
}
