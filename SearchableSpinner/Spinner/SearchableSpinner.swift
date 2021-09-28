//
//  SearchableSpinner.swift
//  SearchableSpinner
//
//  Created by Romana on 26/8/21.
//

import UIKit

@objc protocol SearchableSpinnerDelegate{
    func spinnerValue(_ spinner: SearchableSpinner, index:Int, value:String, object: Any)
}

@IBDesignable class SearchableSpinner: UITextField, SearchViewDelegate {
    
    func selectedValue(index:Int, value:String, object: Any){
        self.text = value
        if (spinnerDelegate != nil) {
            spinnerDelegate.spinnerValue(self, index: index, value: value, object: object)
        }
    }
    
    var spinnerDelegate: SearchableSpinnerDelegate!
    var arrow : Arrow!
    var table : UITableView!
    public  var selectedIndex: Int?
    
    @IBInspectable public var innerPage: Bool = false
    @IBInspectable public var rowHeight: CGFloat = 30
    @IBInspectable public var hideOptionsWhenSelect = true
    @IBInspectable public var isSearchEnable: Bool = true {
        didSet{
            addGesture()
        }
    }
    @IBInspectable public var dropDownBorderColor: UIColor =  UIColor.lightGray {
        didSet {
            layer.borderColor = dropDownBorderColor.cgColor
        }
    }
    @IBInspectable public var listHeight: CGFloat = 150{
        didSet {}
    }
    @IBInspectable public var dropDownBorderWidth: CGFloat = 0.0 {
        didSet {
            layer.borderWidth = dropDownBorderWidth
        }
    }
    @IBInspectable public var dropDownCornerRadius: CGFloat = 5.0 {
        didSet {
            layer.cornerRadius = dropDownCornerRadius
        }
    }
    
    fileprivate  var tableheightX: CGFloat = 100
    fileprivate  var parentController:UIViewController?
    fileprivate  var pointToParent = CGPoint(x: 0, y: 0)
    fileprivate var backgroundView = UIView()
    fileprivate var keyboardHeight:CGFloat = 0
    
    var searchText = String() {
        didSet{
            if searchText == "" {
                self.dataArray = self.optionArray
            }else{
                self.dataArray = optionArray.filter {
                    return $0.range(of: searchText, options: .caseInsensitive) != nil
                }
            }
            reSizeTable()
            selectedIndex = nil
            self.table.reloadData()
        }
    }
    
    @IBInspectable public var handleKeyboard: Bool = true {
        didSet{}
    }
    
    @IBInspectable var textFont: UIFont = UIFont.systemFont(ofSize: 17.0) { didSet{ updateValue() } }
    @IBInspectable var spinnerTextColor: UIColor = UIColor.black { didSet{ updateValue() } }
    @IBInspectable var lineColor: UIColor = UIColor.black { didSet{ updateValue() } }
    @IBInspectable var list: [String]  = [String]() { didSet{ updateValue() } }
    @IBInspectable var spinnerText: String = "" { didSet{ updateValue() } }
    @IBInspectable var placeHolder: String = "" { didSet{ updateValue() } }
    
    
    fileprivate func updateValue() {
        self.font = textFont
        self.textColor = spinnerTextColor
        if (spinnerText.isEmpty){
            self.placeholder = placeHolder
        }else{
            self.text = spinnerText
            self.textColor = spinnerTextColor
        }
        setNeedsDisplay()
    }
    
    @IBInspectable var dataArray: [String]  = [String]()
    fileprivate var optionArray: [String]  = [String]()
    
    func updateList(_ list:[String]) {
        if(list.count == 0){
            self.optionArray.removeAll()
            self.dataArray.removeAll()
        }
        
        self.optionArray = list
        self.dataArray = list
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        self.delegate = self
    }
    
    public required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        setupUI()
        self.delegate = self
    }
    
    //MARK: Closures
    fileprivate var TableWillAppearCompletion: () -> () = { }
    fileprivate var TableDidAppearCompletion: () -> () = { }
    fileprivate var TableWillDisappearCompletion: () -> () = { }
    fileprivate var TableDidDisappearCompletion: () -> () = { }
    
    func setupUI () {
        self.clearButtonMode = .never
        let size = self.frame.height
                let rightView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: size, height: size))
                self.rightView = rightView
                self.rightViewMode = .always
                let arrowContainerView = UIView(frame: rightView.frame)
                self.rightView?.addSubview(arrowContainerView)
                let center = arrowContainerView.center
                arrow = Arrow(origin: CGPoint(x: (center.x - (size/2)),y: (center.y - (size/4))),size: size/2)
                arrowContainerView.addSubview(arrow)

        self.backgroundView = UIView(frame: .zero)
        self.backgroundView.backgroundColor = .clear
        self.borderStyle = .roundedRect
        
        addGesture()
        if isSearchEnable && handleKeyboard{
            NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: nil) { (notification) in
                if self.isFirstResponder{
                    let userInfo:NSDictionary = notification.userInfo! as NSDictionary
                    let keyboardFrame:NSValue = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
                    let keyboardRectangle = keyboardFrame.cgRectValue
                    self.keyboardHeight = keyboardRectangle.height
                    if !self.isSelected{
                        if(self.innerPage){
                        self.showList()
                        }else{
                            self.showListInSeperateView()
                        }
                    }
                }
                
            }
            NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: nil) { (notification) in
                if self.isFirstResponder{
                    self.keyboardHeight = 0
                }
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func changeSelectedIndex(_ index:Int) {
        if ((dataArray.count > index) && index > -1) {
            selectedIndex = index
            self.text = dataArray[selectedIndex!]
            if (spinnerDelegate != nil) {
                spinnerDelegate.spinnerValue(self, index: self.selectedIndex!, value: text!, object: self.dataArray[self.selectedIndex!])
            }
        }else{
            self.text = ""
        }
    }
    
    fileprivate func addGesture (){
        let gesture =  UITapGestureRecognizer(target: self, action:  #selector(touchAction))
        if isSearchEnable{
            self.rightView?.addGestureRecognizer(gesture)
        }else{
            self.addGestureRecognizer(gesture)
        }
        let gesture2 =  UITapGestureRecognizer(target: self, action:  #selector(touchAction))
        self.backgroundView.addGestureRecognizer(gesture2)
    }
    
    func getConvertedPoint(_ targetView: UIView, baseView: UIView?)->CGPoint{
        var pnt = targetView.frame.origin
        if nil == targetView.superview{
            return pnt
        }
        var superView = targetView.superview
        while superView != baseView{
            pnt = superView!.convert(pnt, to: superView!.superview)
            if nil == superView!.superview{
                break
            }else{
                superView = superView!.superview
            }
        }
        return superView!.convert(pnt, to: baseView)
    }
    
    public func showList() {
        if parentController == nil{
            parentController = self.parentViewController
        }
        backgroundView.frame = parentController?.view.frame ?? backgroundView.frame
        pointToParent = getConvertedPoint(self, baseView: parentController?.view)
        parentController?.view.insertSubview(backgroundView, aboveSubview: self)
        TableWillAppearCompletion()
        if listHeight > rowHeight * CGFloat( dataArray.count) {
            self.tableheightX = rowHeight * CGFloat(dataArray.count)
        }else{
            self.tableheightX = listHeight
        }
        table = UITableView(frame: CGRect(x: pointToParent.x ,
                                          y: pointToParent.y + self.frame.height ,
                                          width: self.frame.width,
                                          height: self.frame.height))
        
        table.dataSource = self
        table.delegate = self
        table.alpha = 0
        table.separatorStyle = .none
        table.layer.cornerRadius = 3
        table.backgroundColor = UIColor.lightGray
        table.rowHeight = rowHeight
        //        parentController?.view.addSubview(shadow)
        parentController?.view.addSubview(table)
        self.isSelected = true
        let height = (self.parentController?.view.frame.height ?? 0) - (self.pointToParent.y + self.frame.height + 5)
        var y = self.pointToParent.y+self.frame.height+5
        if height < (keyboardHeight+tableheightX){
            y = self.pointToParent.y - tableheightX
        }
        UIView.animate(withDuration: 0.3,
                       delay: 0.0,
                       options: UIView.AnimationOptions.transitionFlipFromBottom,
                       animations: { () -> Void in
                        
                        self.table.frame = CGRect(x: self.pointToParent.x,
                                                  y: y,
                                                  width: self.frame.width,
                                                  height: self.tableheightX)
                        self.table.alpha = 1
                        self.arrow.position = .up
                       },
                       completion: { (finish) -> Void in
                        self.layoutIfNeeded()
                       })
    }
    
    public func hideList() {
        TableWillDisappearCompletion()
        UIView.animate(withDuration: 0.3,
                       delay: 0.0,
                       options: UIView.AnimationOptions.transitionFlipFromBottom,
                       animations: { () -> Void in
                        self.table.frame = CGRect(x: self.pointToParent.x,
                                                  y: self.pointToParent.y+self.frame.height,
                                                  width: self.frame.width,
                                                  height: 0)
                        self.arrow.position = .down
                       },
                       completion: { (didFinish) -> Void in
                        self.table.removeFromSuperview()
                        self.backgroundView.removeFromSuperview()
                        self.isSelected = false
                        self.resignFirstResponder()
                        self.TableDidDisappearCompletion()
                       })
    }
    
    @objc public func touchAction() {
        if(innerPage){
        self.isSelected ?  hideList() : showList()
        }else{
            self.endEditing(true)
            showListInSeperateView()
        }
    }
    
    @objc public func showListInSeperateView() {
        let alertController = SpinnerSearchView()
        alertController.itemArray = self.dataArray
        alertController.delegate = self
                        alertController.providesPresentationContextTransitionStyle = true
                        alertController.definesPresentationContext = true
                        alertController.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
                        alertController.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        self.parentViewController!.present(alertController, animated: true, completion: nil)
    }
    
    
    func reSizeTable() {
        if listHeight > rowHeight * CGFloat( dataArray.count) {
            self.tableheightX = rowHeight * CGFloat(dataArray.count)
        }else{
            self.tableheightX = listHeight
        }
        let height = (self.parentController?.view.frame.height ?? 0) - (self.pointToParent.y + self.frame.height + 5)
        var y = self.pointToParent.y+self.frame.height+5
        if height < (keyboardHeight+tableheightX){
            y = self.pointToParent.y - tableheightX
        }
        UIView.animate(withDuration: 0.1,
                       delay: 0.0,
                       options: UIView.AnimationOptions.transitionFlipFromBottom,
                       animations: { () -> Void in
                        self.table.frame = CGRect(x: self.pointToParent.x,
                                                  y: y,
                                                  width: self.frame.width,
                                                  height: self.tableheightX)
                       })
    }
    
    public func listWillAppear(completion: @escaping () -> ()) {
        TableWillAppearCompletion = completion
    }
    
    public func listDidAppear(completion: @escaping () -> ()) {
        TableDidAppearCompletion = completion
    }
    
    public func listWillDisappear(completion: @escaping () -> ()) {
        TableWillDisappearCompletion = completion
    }
    
    public func listDidDisappear(completion: @escaping () -> ()) {
        TableDidDisappearCompletion = completion
    }
    
}


extension SearchableSpinner : UITextFieldDelegate {
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        superview?.endEditing(true)
        return false
    }
    public func  textFieldDidBeginEditing(_ textField: UITextField) {
        self.dataArray = self.optionArray
        touchAction()
    }
    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return isSearchEnable
    }
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if(innerPage){
            if string != "" {
                self.searchText = self.text! + string
            }else{
                let subText = self.text?.dropLast()
                self.searchText = String(subText!)
            }
            if !self.isSelected {
                showList()
            }
            return true;
        }else{
            return false;
        }
       
    }
    
}

extension SearchableSpinner: UITableViewDelegate, UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "DropDownCell"
        
        var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: cellIdentifier)
        }
        
        cell!.textLabel!.text = "\(dataArray[indexPath.row])"
        cell!.selectionStyle = .none
        cell?.textLabel?.font = self.textFont
//        cell?.textLabel?.textAlignment = self.textAlignment
        cell?.textLabel?.numberOfLines = 0
        cell?.backgroundColor = .clear
        return cell!
    }
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndex = (indexPath as NSIndexPath).row
        let selectedText = self.dataArray[self.selectedIndex!]
        tableView.cellForRow(at: indexPath)?.alpha = 0
        UIView.animate(withDuration: 0.3,
                       animations: { () -> Void in
                        tableView.cellForRow(at: indexPath)?.alpha = 1.0
                       } ,
                       completion: { (didFinish) -> Void in
                        self.text = "\(selectedText)"
                        
                        tableView.reloadData()
                       })
        if hideOptionsWhenSelect {
            touchAction()
            self.endEditing(true)
        }
        if (spinnerDelegate != nil) {
            spinnerDelegate.spinnerValue(self, index: self.selectedIndex!, value: selectedText, object: self.dataArray[self.selectedIndex!])
        }
    }
}



//MARK: Arrow
enum Position {
    case left
    case down
    case right
    case up
}

class Arrow: UIView {
    let shapeLayer = CAShapeLayer()
     
    var position: Position = .down {
        didSet{
            switch position {
            case .left:
                self.transform = CGAffineTransform(rotationAngle: -CGFloat.pi/2)
                break
                
            case .down:
                self.transform = CGAffineTransform(rotationAngle: CGFloat.pi*2)
                break
                
            case .right:
                self.transform = CGAffineTransform(rotationAngle: CGFloat.pi/2)
                break
                
            case .up:
                self.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
                break
            }
        }
    }
    
    init(origin: CGPoint, size: CGFloat ) {
        super.init(frame: CGRect(x: origin.x, y: origin.y, width: size, height: size))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        
        let size = self.layer.frame.width
        let bezierPath = UIBezierPath()
        let qSize = size/4
        
        bezierPath.move(to: CGPoint(x: 0, y: qSize))
        bezierPath.addLine(to: CGPoint(x: size, y: qSize))
        bezierPath.addLine(to: CGPoint(x: size/2, y: qSize*3))
        bezierPath.addLine(to: CGPoint(x: 0, y: qSize))
        bezierPath.close()
        
        shapeLayer.path = bezierPath.cgPath
        shapeLayer.fillColor = UIColor.black.cgColor
        
        if #available(iOS 12.0, *) {
            self.layer.addSublayer (shapeLayer)
        } else {
            self.layer.mask = shapeLayer
        }
    }
}

extension UIView {
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
}
