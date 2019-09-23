//
//  PullUpMenu.swift
//  MusicPullUpMenuTest
//
//  Created by Alexander Eichhorn on 26.07.19.
//  Copyright © 2019 Losjet - Alexander Eichhorn. All rights reserved.
//

import UIKit

public class PullUpMenuController: UIViewController {
    
    public var items = [PullUpMenuItem]()
    
    public var numberOfColumns = 2
    
    // MARK: - View Decleration
    
    var backgroundView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .regular)
        let view = UIVisualEffectView(effect: blurEffect)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var contentView: UIView {
        return view//backgroundView.contentView
    }
    
    var vibrancyView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .regular)
        let vibrancyEffect = UIVibrancyEffect(blurEffect: blurEffect)
        let view = UIVisualEffectView(effect: vibrancyEffect)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var vibrantContentView: UIView {
        return vibrancyView.contentView
    }
    
    // temporary
    var dismissButton: AnimatablePullUpButton = {
        let button = AnimatablePullUpButton(frame: .zero, direction: .down)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.widthAnchor.constraint(equalToConstant: 40).isActive = true
        button.heightAnchor.constraint(equalTo: button.widthAnchor, multiplier: 0.75).isActive = true
        button.addTarget(self, action: #selector(dismissPressed), for: .touchUpInside)
        return button
    }()
    
    lazy var collectionView: DynamicCollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        let collectionView = DynamicCollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(MenuItemCell.self, forCellWithReuseIdentifier: "menuItem")
        collectionView.backgroundColor = .clear
        collectionView.contentInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        collectionView.delegate = self
        collectionView.dataSource = self
        return collectionView
    }()
    
    var interactionController: PullUpMenuInteractionController?
    
    // MARK: -
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        // set transition style
        self.transitioningDelegate = self
        self.modalPresentationStyle = .custom
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        // setup interactive transition
        interactionController = PullUpMenuInteractionController(isPresenting: false, viewController: self)
        
    }
    
    override public func loadView() {
        super.loadView()
        
        if #available(iOS 13.0, *) {
            view.overrideUserInterfaceStyle = .light
        }
        
        view.addSubview(backgroundView)
        backgroundView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        backgroundView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        backgroundView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        setupViews()
    }
    
    private func setupViews() {
        
        // vibrancy view
        contentView.addSubview(vibrancyView)
        vibrancyView.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
        vibrancyView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        vibrancyView.rightAnchor.constraint(equalTo: contentView.rightAnchor).isActive = true
        vibrancyView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        
        // collection view
        contentView.addSubview(collectionView)
        collectionView.bottomAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.bottomAnchor).isActive = true
        collectionView.leftAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leftAnchor).isActive = true
        collectionView.rightAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.rightAnchor).isActive = true
        
        // dismiss button
        vibrantContentView.addSubview(dismissButton)
        dismissButton.centerXAnchor.constraint(equalTo: vibrantContentView.centerXAnchor).isActive = true
        dismissButton.topAnchor.constraint(equalTo: vibrantContentView.safeAreaLayoutGuide.topAnchor, constant: 100).isActive = true
        
    }
    
    
    override public func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        collectionView.collectionViewLayout.invalidateLayout() // update size for item
    }
    
    @IBAction func dismissPressed(_ sender: Any?) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension PullUpMenuController: UICollectionViewDataSource {
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "menuItem", for: indexPath) as! MenuItemCell
        
        cell.menuItem = items[indexPath.row]
        
        return cell
    }
    
}

extension PullUpMenuController: UICollectionViewDelegate {
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        print("selected \(indexPath)")
    }
    
}

extension PullUpMenuController: UICollectionViewDelegateFlowLayout {
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.contentSize.width / CGFloat(numberOfColumns) - 8
        return CGSize(width: width > 0 ? width : 0, height: 55)
    }
    
}








class DynamicCollectionView: UICollectionView {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if !__CGSizeEqualToSize(self.bounds.size, self.intrinsicContentSize) {
            self.invalidateIntrinsicContentSize()
        }
    }
    
    override var intrinsicContentSize: CGSize {
        return contentSize.extended(by: contentInset)
    }
    
}
