import RouterServiceInterface

struct FeatureTwo: Feature {

    @Dependency var routerService: RouterServiceProtocol

    func build(fromRoute route: Route?) -> UIViewController {
        return FeatureTwoViewController(route: route)
    }
}

class FeatureTwoViewController: UIViewController {

    let route: Route?

    init(route: Route?) {
        self.route = route
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    override func loadView() {
        let view = UIView()
        view.backgroundColor = .green
        let label = UILabel()
        label.text = route.debugDescription
        view.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        self.view = view
    }
}
