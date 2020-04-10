import RouterServiceInterface

class MainFeature: Feature {

    struct Dependencies {
        let httpClient: HTTPClientProtocol
        let routerService: RouterServiceProtocol
    }

    static func build(
        dependencies: MainFeature.Dependencies,
        fromRoute route: Route?
    ) -> UIViewController {
        return MainViewController(dependencies: dependencies, route: route as? MainRoute)
    }

    static var dependenciesInitializer: AnyDependenciesInitializer {
        return AnyDependenciesInitializer(Dependencies.init)
    }

}

class MainViewController: UIViewController {

    let dependencies: MainFeature.Dependencies
    let route: MainRoute?

    init(dependencies: MainFeature.Dependencies, route: MainRoute?) {
        self.dependencies = dependencies
        self.route = route
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let route = route else {
            return
        }
        view.backgroundColor = UIColor(hexString: route.backgroundColorHex)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let newColor = "#" + String((0..<6).map { _ in "0123456789abcdef".randomElement()!
        })
        dependencies.routerService.navigate(
            toRoute: MainRoute(backgroundColorHex: newColor),
            fromView: self,
            presentationStyle: Push(),
            animated: true
        )
    }
}

public extension UIColor {
    convenience init(hexString: String, alpha: CGFloat = 1.0) {
        var hexInt: UInt32 = 0
        let scanner = Scanner(string: hexString)
        scanner.charactersToBeSkipped = CharacterSet(charactersIn: "#")
        scanner.scanHexInt32(&hexInt)

        let red = CGFloat((hexInt & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((hexInt & 0xFF00) >> 8) / 255.0
        let blue = CGFloat((hexInt & 0xFF) >> 0) / 255.0

        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}
