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
        cell.isActive = indexPath.row == 0
        
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
        let width = collectionView.contentSize.width/2 - 8
        return CGSize(width: width > 0 ? width : 0, height: 55)
    }
    
}



// MARK: - UI of Cell

extension PullUpMenuController {
    
    class MenuItemCell: UICollectionViewCell {
        
        weak var menuItem: PullUpMenuItem? {
            didSet {
                imageView.image = menuItem?.image
                titleLabel.text = menuItem?.title
                subtitleLabel.text = menuItem?.subtitle
            }
        }
        
        lazy var vibrancyView: UIVisualEffectView = {
            let blurEffect = UIBlurEffect(style: vibrancyBlurStyle)
            let vibrancyEffect = UIVibrancyEffect(blurEffect: blurEffect)
            let view = UIVisualEffectView(effect: vibrancyEffect)
            self.contentView.insertSubview(view, at: 0)
            
            view.translatesAutoresizingMaskIntoConstraints = false
            view.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
            view.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
            view.rightAnchor.constraint(equalTo: contentView.rightAnchor).isActive = true
            view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
            
            return view
        }()
        
        private var vibrancyBlurStyle: UIBlurEffect.Style = .regular {
            didSet {
                let blurEffect = UIBlurEffect(style: vibrancyBlurStyle)
                vibrancyView.effect = UIVibrancyEffect(blurEffect: blurEffect)
                setupBackground()
            }
        }
        
        lazy var imageView: UIImageView = {
            let imageView = UIImageView()
            self.contentView.addSubview(imageView)
            
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 16).isActive = true
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16).isActive = true
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16).isActive = true
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor).isActive = true
            
            imageView.tintColor = .white
            imageView.contentMode = .scaleAspectFit
            
            return imageView
        }()
        
        lazy private var labelStackView: UIStackView = {
            let stackView = UIStackView()
            self.contentView.addSubview(stackView)
            
            stackView.translatesAutoresizingMaskIntoConstraints = false
            stackView.leftAnchor.constraint(equalTo: imageView.rightAnchor, constant: 16).isActive = true
            stackView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -8).isActive = true
            stackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
            stackView.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor, constant: 4).isActive = true
            stackView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -4).isActive = true
            
            stackView.axis = .vertical
            stackView.alignment = .leading
            stackView.spacing = 0//4
            stackView.distribution = UIStackView.Distribution.equalCentering
            
            return stackView
        }()
        
        lazy var titleLabel: UILabel = {
            let label = UILabel()
            labelStackView.insertArrangedSubview(label, at: 0)
            
            label.textColor = .white
            label.font = UIFont.systemFont(ofSize: 18.0, weight: .semibold)
            label.minimumScaleFactor = 0.5
            label.adjustsFontSizeToFitWidth = true
            label.baselineAdjustment = .alignCenters
            setupBackground()
            
            return label
        }()
        
        lazy var subtitleLabel: UILabel = {
            let label = UILabel()
            labelStackView.insertArrangedSubview(label, at: labelStackView.arrangedSubviews.count)
            
            label.textColor = .white
            label.font = UIFont.systemFont(ofSize: 14.0, weight: .regular)
            
            return label
        }()
        
        private func setupBackground() {
            vibrancyView.contentView.backgroundColor = UIColor(white: 1.0, alpha: 0.2)
            vibrancyView.contentView.layer.cornerRadius = 16
        }
        
        
        var isActive: Bool = false {
            didSet {
                vibrancyBlurStyle = isActive ? .dark : .regular
                titleLabel.textColor = isActive ? menuItem?.tintColor : .white
                subtitleLabel.textColor = titleLabel.textColor
                imageView.tintColor = isActive ? menuItem?.tintColor : .white
                updateBackground()
            }
        }
        
        private func updateBackground() {
            vibrancyView.contentView.backgroundColor = UIColor(white: 1.0, alpha: isActive ? (isHighlighted ? 0.8 : 1.0) : (isHighlighted ? 0.5 : 0.2) )
        }
        
        
        
        
        // MARK: - UITouch Delegate
        
        private let animationDuration: TimeInterval = 0.8
        private let animationCurve: UITimingCurveProvider = UISpringTimingParameters(dampingRatio: 0.5)
        private var animator = UIViewPropertyAnimator()
        
        override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            
            let duration = TimeInterval(animator.isRunning ? animator.fractionComplete : 1) * animationDuration
            animator = UIViewPropertyAnimator(duration: duration, timingParameters: UISpringTimingParameters(dampingRatio: 0.5))
            animator.addAnimations {
                self.vibrancyView.contentView.backgroundColor = UIColor(white: 1.0, alpha: self.isActive ? 0.8 : 0.5)
                self.contentView.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            }
            animator.startAnimation()
        }
        
        override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
            menuItem?.touchUpInsideHandler?()
            touchesFinished(touches, with: event)
        }
        
        override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
            touchesFinished(touches, with: event)
        }
        
        private func touchesFinished(_ touches: Set<UITouch>, with event: UIEvent?) {
            
            let duration = TimeInterval(animator.isRunning ? animator.fractionComplete : 1) * animationDuration
            animator = UIViewPropertyAnimator(duration: duration, timingParameters: UISpringTimingParameters(damping: 0.4, response: 0.2))
            animator.addAnimations {
                self.vibrancyView.contentView.backgroundColor = UIColor(white: 1.0, alpha: self.isActive ? 1.0 : 0.2)
                self.contentView.transform = .identity
            }
            animator.startAnimation()
        }
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
