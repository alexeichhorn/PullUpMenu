//
//  PullUpMenuItemCell.swift
//  
//
//  Created by Alexander Eichhorn on 22.09.19.
//

import UIKit

extension PullUpMenuController {
    
    class MenuItemCell: UICollectionViewCell, PullUpMenuItemDelegate {
        
        weak var menuItem: PullUpMenuItem? {
            didSet {
                imageView.image = menuItem?.image
                titleLabel.text = menuItem?.title
                subtitleLabel.text = menuItem?.subtitle
                isActive = menuItem?.isActive ?? false
                menuItem?.delegate = self
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
            vibrancyView.contentView.backgroundColor = UIColor(white: 1.0, alpha: isActive ? 1.0 : 0.2 )
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
        
        
        
        // MARK: - Menu Item Delegate
        
        func menuItemIsActiveDidChange() {
            DispatchQueue.main.async {
                self.isActive = self.menuItem?.isActive ?? false
            }
        }
    }
    
}
