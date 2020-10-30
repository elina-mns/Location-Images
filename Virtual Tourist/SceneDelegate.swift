//
//  SceneDelegate.swift
//  Location Images
//
//  Created by Elina Mansurova on 2020-10-21.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    let dataController = DataController(modelName: "Pins&Photos")

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        let navigationController = window?.rootViewController as? UINavigationController
        let mapViewController = navigationController?.topViewController as? MapViewController
        mapViewController?.dataController = dataController
    
        dataController.load()
        guard let _ = (scene as? UIWindowScene) else { return }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        try? dataController.viewContext.save()
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        try? dataController.viewContext.save()
    }


}

