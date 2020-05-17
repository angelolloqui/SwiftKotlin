
class ViewController: UIViewController {
    @BindView() lateinit var view: View
    @BindView() lateinit var label: TextView
    @BindView() lateinit var textField: EditText
    @BindView() lateinit var imageView: ImageView
    @BindView() lateinit var button: Button
    @BindView() lateinit var tableView: RecyclerView
    @BindView() lateinit var stackView: LinearLayout
    @BindView() lateinit var scrollView: ScrollView
    @BindView() lateinit var aSwitch: Switch
    
    fun method(label: TextView) : View {
        val view = View()
        view.addSubview(view)
        return view
    }
    
    @OnClick() fun onTap() {}
}
