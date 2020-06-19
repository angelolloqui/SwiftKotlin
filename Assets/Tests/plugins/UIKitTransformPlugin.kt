
internal class ViewController: UIViewController {
    @BindView() lateinit internal var view: View
    @BindView() lateinit internal var label: TextView
    @BindView() lateinit internal var textField: EditText
    @BindView() lateinit internal var imageView: ImageView
    @BindView() lateinit internal var button: Button
    @BindView() lateinit internal var tableView: RecyclerView
    @BindView() lateinit internal var stackView: LinearLayout
    @BindView() lateinit internal var scrollView: ScrollView
    @BindView() lateinit internal var aSwitch: Switch
    
    internal fun method(label: TextView) : View {
        val view = View()
        view.addSubview(view)
        return view
    }
    
    @OnClick() internal fun onTap() {}
}
