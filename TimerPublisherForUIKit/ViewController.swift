//
//  ViewController.swift
//  TimerPublisherForUIKit
//
//  Created by Pooyan J on 3/27/25.
//

import UIKit
import Combine

class ViewController: UIViewController {

    @IBOutlet weak var button: UIButton!
    @IBAction func buttonAction(_ sender: Any) {
        viewModel.start()
    }
    
    private var viewModel = ViewModel()
    private var cancellabled: Set<AnyCancellable> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupBindings()
    }
}

// MARK: - Binding Functions
extension ViewController {
    
    private func setupBindings() {
        bindButtonStyle()
        bindButtonTitle()
    }
    
    private func bindButtonStyle() {
        viewModel.$isEnabled
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] isEnabled in
                button.isEnabled = isEnabled
            }.store(in: &cancellabled)
    }
    
    private func bindButtonTitle() {
        viewModel.buttonTitle
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] title in
                button.setTitle(title, for: .normal)
            }.store(in: &cancellabled)
    }
}

// MARK: - ViewModel
final class ViewModel: ObservableObject {
    
    @Published var isEnabled: Bool = true
    var buttonTitle = CurrentValueSubject<String, Never>("Initial Value")
    var cancellable: AnyCancellable?
    private var otpTimer = 10
    
    func start() {
        resetTimer(buttonTitle: otpTimer.description, isEnabled: false)
        cancellable = Timer
            .publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [unowned self] _ in
                if otpTimer >= 0 {
                    startTimer()
                } else {
                    resetTimer(buttonTitle: "Start", isEnabled: true)
                }
            }
    }
    
    private func startTimer() {
            otpTimer -= 1
            self.buttonTitle.send("\(otpTimer)")
            isEnabled = false
            objectWillChange.send()
    }
    
    private func resetTimer(buttonTitle: String, isEnabled: Bool) {
        cancellable?.cancel()
         otpTimer = 10
        self.isEnabled = isEnabled
        self.buttonTitle.send(buttonTitle)
        objectWillChange.send()
    }
}

