import RouterServiceInterface
import HTTPClientInterface
import FeatureFlagInterface
import FeatureTwoInterface

public struct FeatureOne: FlaggableFeature {

    @Dependency var httpClient: HTTPClientProtocol
    @Dependency var routerService: RouterServiceProtocol
    @Dependency var featureFlag: FeatureFlagProtocol

    public init() {}
    
    public func isEnabled() -> Bool {
        return featureFlag.isEnabled()
    }
    
    public func buildFallback(fromRoute route: Route?) -> UIViewController {
        return FallbackController()
    }

    public func build(fromRoute route: Route?) -> UIViewController {
        return MainViewController(
            httpClient: httpClient,
            routerService: routerService
        )
    }
}

final class MainViewController: UIViewController {

    let httpClient: HTTPClientProtocol
    let routerService: RouterServiceProtocol

    init(
        httpClient: HTTPClientProtocol,
        routerService: RouterServiceProtocol
    ) {
        self.httpClient = httpClient
        self.routerService = routerService
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    override func loadView() {
        let view = UIView()

        view.backgroundColor = .white
        let httpLabel = UILabel()
        httpLabel.text = "\(httpClient)"
        view.addSubview(httpLabel)
        httpLabel.translatesAutoresizingMaskIntoConstraints = false
        httpLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        httpLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        let routerLabel = UILabel()
        routerLabel.text = "\(routerService)"
        view.addSubview(routerLabel)
        routerLabel.translatesAutoresizingMaskIntoConstraints = false
        routerLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        routerLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 32).isActive = true
        let button = UIButton(type: .system)
        button.setTitle("Go to FeatureTwo", for: .normal)
        button.addTarget(self, action: #selector(goToFeatureTwo), for: .touchUpInside)
        view.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        button.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 64).isActive = true
        self.view = view
    }

    @objc private func goToFeatureTwo() {
        routerService.navigate(
            toRoute: FeatureTwoRoute(),
            fromView: self,
            presentationStyle: Push(),
            animated: true
        )
    }
}

final class FallbackController: UIViewController {
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    override func loadView() {
        let view = UIView()

        view.backgroundColor = .white
        let emptyStateLabel = UILabel()
        emptyStateLabel.text = "Fallback View Controller"
        view.addSubview(emptyStateLabel)
        emptyStateLabel.translatesAutoresizingMaskIntoConstraints = false
        emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        emptyStateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        self.view = view
    }
}
