//
//  SceneDelegate.swift
//  MovieList
//
//  Created by macbook on 03/05/2023.
//

import UIKit
import MovieListFramework

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let window = UIWindow(windowScene: windowScene)
        self.window = window
        
        // Configure Appearance both in UIKit and SwiftUI
        window.overrideUserInterfaceStyle = .dark
        configureNavigationBarAppearance()
        configureTabBar()
        
        // Fetch and Save user IP to get User Country Code For Streaming Suggestions
        fetchAndSaveCountryCode()

        // Create favorites resource
        let favoritesRepo = FavoritesRepository()
        // Create network resource
        let networkingResource = TMDBNetworkingService()
        
        //Uncomment to test flows.
//        window.rootViewController = setupAndCreateUIKitFlow(networkingService: networkingResource, favoritesRepository: favoritesRepo)
        window.rootViewController = setupAndCreateSwiftUIFlow(networkingService: networkingResource, favoritesRepository: favoritesRepo)
        window.makeKeyAndVisible()
    }
    
    //Mark: - Create UIKit Flow TabBar Setup.
    private func setupAndCreateUIKitFlow(networkingService: NetworkingService, favoritesRepository: FavoritesRepository) -> UIViewController {
        // Create the main view controller
        let mainScreenViewController = MainScreenBuilder.build(favoritesRepository: favoritesRepository, networkRepository: networkingService)
        let mainScreenNavigationController = UINavigationController(rootViewController: mainScreenViewController)
        
        // Create tab bar items
        let mainScreenItem = UITabBarItem(title: "Main", image: UIImage(systemName: "film"), selectedImage: UIImage(systemName: "film.fill"))
        let favoritesItem = UITabBarItem(title: "Favorites", image: UIImage(systemName: "star"), selectedImage: UIImage(systemName: "star.fill"))
        
        // Create the favorites view controller
        let favoritesViewController = FavBuilder.build(favoritesRepository: favoritesRepository, networkRepository: networkingService)
        let favoritesNavigationController = UINavigationController(rootViewController: favoritesViewController)
        
        // Set the tab bar items for each view controller
        mainScreenViewController.tabBarItem = mainScreenItem
        favoritesViewController.tabBarItem = favoritesItem
        
        // Create the tab bar controller
        
        let tabBarController = MLTabBarController()
        tabBarController.viewControllers = [mainScreenNavigationController, favoritesNavigationController]

        return tabBarController
    }
    
    //Mark: - Create SwiftUI Flow TabBar Setup.
    private func setupAndCreateSwiftUIFlow(networkingService: NetworkingService, favoritesRepository: FavoritesRepository) -> UIViewController {
        //SwiftUI of the Main Tab
        let viewController = HostingController()
        viewController.dataSource = createDummyData()
        viewController.favoritesRepository = favoritesRepository
        viewController.networkingService = networkingService
        return viewController
    }
    
    private func createDummyData() -> [MediaViewModel] {
        var myData: [MediaViewModel] = []
        for index in 0..<20 {
            myData.append(MediaViewModel.viewModelFrom(mediaItem: MocchyItems.expectedItems(at: index)))
        }
        return myData
    }
    private func fetchAndSaveCountryCode() {
        Task {
            let countryCode = await CountryService.fetchCountryCodeAsync()
            
            if let countryCode = countryCode {
                UserDefaults.standard.set(countryCode, forKey: "savedCountryCode")
                print("Country code saved to UserDefaults: \(countryCode)")
            } else {
                print("Failed to retrieve country code.")
            }
        }
    }
    func configureNavigationBarAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = .prussianBlue
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        UINavigationBar.appearance().tintColor = .white
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        
    }
    
    func configureTabBar() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .prussianBlue
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = UITabBar().standardAppearance
        UITabBar.appearance().tintColor = .systemTeal
    }

    class MLTabBarController: UITabBarController {
        override func viewDidLoad() {
            super.viewDidLoad()
            configureTabBar()
        }

        private func configureTabBar() {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .prussianBlue
            tabBar.standardAppearance = appearance
            tabBar.scrollEdgeAppearance = tabBar.standardAppearance
            tabBar.tintColor = .systemTeal
        }
        
//        override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
//            guard let indexOfNewTab = tabBar.items?.firstIndex(of: item) else { return }
//            
//            print("item is :\(item)")
//        }
        
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
    
}
