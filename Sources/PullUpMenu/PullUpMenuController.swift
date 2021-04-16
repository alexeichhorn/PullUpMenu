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
    
    public lazy var animator = PullUpAnimator(menuController: self)
    
    // MARK: - View Decleration
    
    private static var blurStyle: UIBlurEffect.Style {
        if #available(iOS 13.0, *) {
            return .systemUltraThinMaterialDark
        } else {
            return .regular
        }
    }
    
    var backgroundView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: blurStyle)
        let view = UIVisualEffectView(effect: blurEffect)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var contentView: UIView {
        return view//backgroundView.contentView
    }
    
    var vibrancyView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: blurStyle)
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
    
    var interactionController: PullUpInteractiveAnimator?
    
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
        self.modalPresentationStyle = .custom
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        // setup interactive transition
        interactionController = PullUpInteractiveAnimator(menuController: self)
        
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
        
        // popover style
        if modalPresentationStyle == .popover {
            dismissButton.isHidden = true
        }
    }
    
    
    override public func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        collectionView.collectionViewLayout.invalidateLayout() // update size for item
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // update popover size
        if modalPresentationStyle == .popover {
            preferredContentSize = collectionView.bounds.size
        }
    }
    
    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if traitCollection.horizontalSizeClass == .regular && modalPresentationStyle != .popover {
            dismiss(animated: false)
        } else if presentingViewController?.traitCollection.horizontalSizeClass == .compact && modalPresentationStyle == .popover {
            dismiss(animated: false)
        }
    }
    
    @IBAction func dismissPressed(_ sender: Any?) {
        animator.close()
    }
    
    /// present menu controller full screen above given view controller
    public func present(in vc: UIViewController, animated: Bool = true, sourceView: UIView? = nil, sourceRect: CGRect? = nil) {
        
        if traitCollection.horizontalSizeClass == .regular,
            let sourceView = sourceView, let sourceRect = sourceRect {
            
            modalPresentationStyle = .popover
            popoverPresentationController?.sourceView = sourceView
            popoverPresentationController?.sourceRect = sourceRect
            popoverPresentationController?.permittedArrowDirections = [.down]
            popoverPresentationController?.backgroundColor = .black
            vc.present(self, animated: true, completion: nil)
            return
        }
        
        vc.view.addSubview(view)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        view.topAnchor.constraint(equalTo: vc.view.topAnchor).isActive = true
        view.rightAnchor.constraint(equalTo: vc.view.rightAnchor).isActive = true
        view.bottomAnchor.constraint(equalTo: vc.view.bottomAnchor).isActive = true
        view.leftAnchor.constraint(equalTo: vc.view.leftAnchor).isActive = true
        
        vc.addChild(self)
        
        if animated {
            view.alpha = 0
            collectionView.preloadCells {
                self.view.alpha = 1
                self.animator.open()
            }
        }
    }
    
    public override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        if modalPresentationStyle == .popover {
            super.dismiss(animated: flag, completion: completion)
        } else {
            animator.close()
        }
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
    
    private var cellsLoaded: Bool {
        return (dataSource?.collectionView(self, numberOfItemsInSection: 0) ?? 0) <= visibleCells.count
    }
    
    func preloadCells(_ completion: @escaping () -> Void, timeout: Int = 10) {
        if cellsLoaded || timeout <= 0 {
            completion()
            return
        }
        
        layoutIfNeeded()
        DispatchQueue.main.async { [weak self] in
            self?.preloadCells(completion, timeout: timeout-1)
        }
    }
    
}
