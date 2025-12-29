//
//  KeyboardObserver.swift
//  Iakadir
//

import Foundation
import UIKit
import Combine

final class KeyboardObserver: ObservableObject {
    @Published private(set) var isVisible: Bool = false

    private var cancellables = Set<AnyCancellable>()

    init() {
        let willShow = NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
            .map { _ in true }

        let willHide = NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
            .map { _ in false }

        willShow
            .merge(with: willHide)
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .sink { [weak self] visible in
                DispatchQueue.main.async {
                    self?.isVisible = visible
                }
            }
            .store(in: &cancellables)
    }
}
