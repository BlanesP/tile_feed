//
//  BaseViewModel.swift
//  TileFeed
//
//  Created by Pau Blanes on 28/7/22.
//

import Combine
import Foundation

protocol BaseViewModel: ObservableObject, Logger {
    associatedtype ViewInput
    associatedtype ViewOutput

    var output: PassthroughSubject<ViewOutput, Never> { get }

    func input(_ input: ViewInput)
}
