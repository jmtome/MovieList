//
//  UIKitPreview.swift
//  MovieList
//
//  Created by macbook on 25/05/2023.
//

import Foundation

#if canImport(SwiftUI) && DEBUG
import SwiftUI

struct ViewControllerRepresentable: UIViewControllerRepresentable {
    
    func makeUIViewController(context: Context) -> some UIViewController {
        let vc = UIViewController()
        
        let titleView = TitleAndOverview(frame: .zero)
        titleView.translatesAutoresizingMaskIntoConstraints = false
        
        vc.view.addSubview(titleView)
        titleView.pinToEdges(of: vc.view, with: 8)
        
        return vc
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
    
    struct ViewController_Preview: PreviewProvider {
        static var previews: some View {
            ViewControllerRepresentable()
        }
    }
}
#endif
