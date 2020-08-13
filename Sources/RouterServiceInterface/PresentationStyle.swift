import Foundation
import UIKit

public protocol PresentationStyle {
    func present(
        viewController: UIViewController,
        fromViewController: UIViewController,
        animated: Bool,
        completion:(() -> Void)?
    )
}

public typealias Push = PushPresentationStyle

open class PushPresentationStyle: PresentationStyle {

    public init() {}

    open func present(
        viewController: UIViewController,
        fromViewController: UIViewController,
        animated: Bool,
        completion:(() -> Void)?
    ) {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        fromViewController
            .navigationController?
            .pushViewController(
                viewController,
                animated: animated
        )
        CATransaction.commit()
    }
}

public typealias Modal = ModalPresentationStyle 

open class ModalPresentationStyle: PresentationStyle {

    public init() {}

    open func present(
        viewController: UIViewController,
        fromViewController: UIViewController,
        animated: Bool,
        completion:(() -> Void)?
    ) {
        fromViewController.present(
            viewController,
            animated: true,
            completion: completion
        )
    }
}
