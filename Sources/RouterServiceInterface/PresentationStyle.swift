import Foundation
import UIKit

public protocol PresentationStyle {
    func present(
        viewController: UIViewController,
        fromViewController: UIViewController,
        animated: Bool,
        completion: (() -> Void)?
    )
}

public extension PresentationStyle {
    func present(
        viewController: UIViewController,
        fromViewController: UIViewController,
        animated: Bool
    ) {
        present(
            viewController: viewController,
            fromViewController: fromViewController,
            animated: animated,
            completion: nil
        )
    }
}

public typealias Push = PushPresentationStyle

open class PushPresentationStyle: PresentationStyle {

    public init() {}

    open func present(
        viewController: UIViewController,
        fromViewController: UIViewController,
        animated: Bool,
        completion: (() -> Void)? = nil
    ) {
        fromViewController
            .navigationController?
            .pushViewController(
                viewController,
                animated: animated,
                completion: completion
        )
    }
}

public typealias Modal = ModalPresentationStyle 

open class ModalPresentationStyle: PresentationStyle {

    public init() {}

    open func present(
        viewController: UIViewController,
        fromViewController: UIViewController,
        animated: Bool,
        completion:  (() -> Void)? = nil
    ) {
        fromViewController.present(
            viewController,
            animated: true,
            completion: completion
        )
    }
}

private func commitTransaction(_ transaction: () -> Void, completion: (() -> Void)?) {
    CATransaction.begin()
    CATransaction.setCompletionBlock(completion)
    transaction()
    CATransaction.commit()
}

private extension UINavigationController {
    func pushViewController(_ viewController: UIViewController, animated: Bool, completion: (() -> Void)?) {
        commitTransaction({
            pushViewController(viewController, animated: animated)
        }, completion: completion)
    }
}
