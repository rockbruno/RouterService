import RouterServiceInterface
import HTTPClientInterface
import FeatureTwoInterface

public final class FeatureOne: Feature {

    public struct Dependencies {
        let httpClient: HTTPClientProtocol
        let routerService: RouterServiceInterface.RouterServiceProtocol
    }

    public static func build(
        dependencies: FeatureOne.Dependencies,
        fromRoute route: Route?
    ) -> UIViewController {
        return MainViewController(dependencies: dependencies)
    }

    public static var dependenciesInitializer: AnyDependenciesInitializer {
        return AnyDependenciesInitializer(Dependencies.init)
    }
}

class MainViewController: UIViewController {

    let dependencies: FeatureOne.Dependencies

    init(dependencies: FeatureOne.Dependencies) {
        self.dependencies = dependencies
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    override func loadView() {
        let view = UIView()

        let blaLabe = SelectableView()
//        blaLabe.backgroundColor = .red
        view.addSubview(blaLabe)
        blaLabe.translatesAutoresizingMaskIntoConstraints = false
        blaLabe.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        blaLabe.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        blaLabe.widthAnchor.constraint(equalToConstant: 200).isActive = true
        blaLabe.heightAnchor.constraint(equalToConstant: 40).isActive = true
//        blaLabe.enableDebugInteraction()

        view.backgroundColor = .white
//        let httpLabel = UILabel()
//        httpLabel.text = "\(dependencies.httpClient)"
//        view.addSubview(httpLabel)
//        httpLabel.translatesAutoresizingMaskIntoConstraints = false
//        httpLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
//        httpLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
//        let routerLabel = UILabel()
//        routerLabel.text = "\(dependencies.routerService)"
//        view.addSubview(routerLabel)
//        routerLabel.translatesAutoresizingMaskIntoConstraints = false
//        routerLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
//        routerLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 32).isActive = true
//        let button = UIButton(type: .system)
//        button.setTitle("Go to FeatureTwo", for: .normal)
//        button.addTarget(self, action: #selector(goToFeatureTwo), for: .touchUpInside)
//        view.addSubview(button)
//        button.translatesAutoresizingMaskIntoConstraints = false
//        button.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
//        button.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 64).isActive = true
        self.view = view
    }

    @objc private func goToFeatureTwo() {
        dependencies.routerService.navigate(
            toRoute: FeatureTwoRoute(),
            fromView: self,
            presentationStyle: Push(),
            animated: true
        )
    }
}

final class SelectableView: UIView, DebugMenuInteractionDelegate {

    func copyUUID() -> DebugAction {
        return .init(title: "Copy UUID") { _ in
            // Copy the UUID to pasteboard
        }
    }

    func printLoginJSON() -> DebugAction {
        return .init(title: "Print the Backend's Login Response") { _ in
            // Print it!
        }
    }

    func debugActions() -> [DebugAction] {
        return [copyUUID(), printLoginJSON()]
    }

    override init(frame: CGRect) {
        super.init(frame: .zero)
        let blaLabe = UserTextField()
        blaLabe.render(user: User(identifier: "bla", name: "Bruno Rocha"))
        addSubview(blaLabe)
        blaLabe.translatesAutoresizingMaskIntoConstraints = false
        blaLabe.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        blaLabe.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }

    required init?(coder: NSCoder) {
        fatalError()
    }
}

extension UIView {
    public func enableDebugInteraction(delegate: DebugMenuInteractionDelegate) {
        disableDebugInteraction(delegate: delegate)
        let debugInteraction = DebugMenuInteraction(delegate: delegate)
        addInteraction(debugInteraction)
    }

    public func disableDebugInteraction(delegate: DebugMenuInteractionDelegate) {
        for case let interaction as DebugMenuInteraction in interactions {
            removeInteraction(interaction)
        }
    }
}

extension DebugMenuInteractionDelegate where Self: UIView {
    public func enableDebugInteraction() {
        enableDebugInteraction(delegate: self)
    }

    public func disableDebugInteraction() {
        enableDebugInteraction(delegate: self)
    }
}

public struct DebugAction {
    public let title: String
    public let handler: UIActionHandler

    public init(
        title: String,
        handler: @escaping UIActionHandler
    ) {
        self.title = title
        self.handler = handler
    }
}

public protocol DebugMenuInteractionDelegate: AnyObject {
    func debugActions() -> [UIAction]
}

public final class DebugMenuInteraction: UIContextMenuInteraction {

    class DelegateProxy: NSObject, UIContextMenuInteractionDelegate {
        weak var delegate: DebugMenuInteractionDelegate?

        public func contextMenuInteraction(
            _ interaction: UIContextMenuInteraction,
            configurationForMenuAtLocation location: CGPoint
        ) -> UIContextMenuConfiguration? {
            return UIContextMenuConfiguration(
                identifier: nil,
                previewProvider: nil
            ) { [weak self] _ in
                let actions: [UIAction] = self?.delegate?.debugActions() ?? []
                return UIMenu(title: "Debug Actions", children: actions)
            }
        }
    }

    static let identifier: NSString = "__debugInteractionSDK"
    private let contextMenuDelegateProxy: DelegateProxy

    public init(delegate: DebugMenuInteractionDelegate) {
        let contextMenuDelegateProxy = DelegateProxy()
        contextMenuDelegateProxy.delegate = delegate
        self.contextMenuDelegateProxy = contextMenuDelegateProxy
        super.init(delegate: contextMenuDelegateProxy)
    }
}

struct User {
    let identifier: String
    let name: String
}

final class UserTextField: UITextField {

    private(set) var user: User?

    func render(user: User) {
        self.user = user
        text = "Logged as \(user.name)"
    }
}

extension UIView {
    public func addDebugMenuInteraction() {
        #if DEBUG
        guard let delegate = self as? DebugMenuInteractionDelegate else {
            return
        }
        let debugInteraction = DebugMenuInteraction(delegate: delegate)
        addInteraction(debugInteraction)
        #endif
    }
}
