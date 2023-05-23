//
//  DispatchQueue+Extension.swift
//  MovieList
//
//  Created by macbook on 17/05/2023.
//

import UIKit

extension DispatchQueue {
    static func mainAsyncIfNeeded(execute work: @escaping () -> Void) {
        if Thread.isMainThread {
            work()
        } else {
            main.async(execute: work)
        }
    }
}
