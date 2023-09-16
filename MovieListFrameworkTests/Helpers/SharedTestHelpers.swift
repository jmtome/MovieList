//
//  SharedTestHelpers.swift
//  MovieListFrameworkTests
//
//  Created by macbook on 14/09/2023.
//

import Foundation

func anyNSError() -> NSError{
    return NSError(domain: "any error", code: 0)
}

func anyURL() -> URL {
    return URL(string: "https://any-url.com")!
}
