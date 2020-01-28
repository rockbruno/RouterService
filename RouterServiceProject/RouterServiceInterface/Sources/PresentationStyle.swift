import Foundation
import UIKit

public protocol PresentationStyle {
    func present(
        viewController: UIViewController,
        fromViewController: UIViewController,
        animated: Bool
    )
}

public typealias Push = PushPresentationStyle

open class PushPresentationStyle: PresentationStyle {

    public init() {}

    open func present(
        viewController: UIViewController,
        fromViewController: UIViewController,
        animated: Bool
    ) {
        fromViewController
            .navigationController?
            .pushViewController(
                viewController,
                animated: animated
        )
    }
}

public typealias Modal = PushPresentationStyle

open class ModalPresentationStyle: PresentationStyle {

    public init() {}

    open func present(
        viewController: UIViewController,
        fromViewController: UIViewController,
        animated: Bool
    ) {
        fromViewController.present(
            viewController,
            animated: true,
            completion: nil
        )
    }
}
