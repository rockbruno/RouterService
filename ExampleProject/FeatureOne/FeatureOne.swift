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
        view.backgroundColor = .white
        let httpLabel = UILabel()
        httpLabel.text = "\(dependencies.httpClient)"
        view.addSubview(httpLabel)
        httpLabel.translatesAutoresizingMaskIntoConstraints = false
        httpLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        httpLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        let routerLabel = UILabel()
        routerLabel.text = "\(dependencies.routerService)"
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
        dependencies.routerService.navigate(
            toRoute: FeatureTwoRoute(),
            fromView: self,
            presentationStyle: Push(),
            animated: true
        )
    }
}
