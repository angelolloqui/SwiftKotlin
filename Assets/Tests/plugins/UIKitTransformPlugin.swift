
class ViewController: UIViewController {
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var aSwitch: UISwitch!

    func method(label: UILabel) -> UIView {
        let view = UIView()
        view.addSubview(view)
        return view
    }

    @IBAction func onTap() {
    }
}
