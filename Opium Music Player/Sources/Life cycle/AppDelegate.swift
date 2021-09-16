//
//  AppDelegate.swift
//  Opium ~ Music Player for IPhone
//
//  Created by Антон Сивцов on 06.08.2021.
//

import UIKit
import SnapKit
import AVFoundation

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        window?.rootViewController = AppContainer.makeRootVC()
        
        setupAudioBackground()
        
        return true
    }
    
    private func setupAudioBackground() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.default)
        } catch let error as NSError {
            AppContainer.showAlert(
                type: .failure,
                text: "Setting category to AVAudioSessionCategoryPlayback failed: \(error.localizedFailureReason)"
            )
        }
    }
    
}

