# PullUpMenu

PullUpMenu for iOS implemented in Swift.

To show PullUpMenu, use class `PullUpMenuController` like this:
```
let menuController = PullUpMenuController()
menuController.items = [
  PullUpMenuItem(title: "Item", image: UIImage(named: "item"))
]
menuController.present(in: self)
```
To show `PullUpMenuController` in popover style on a larger screen, present it like this:
```
menuController.present(in: self, sourceView: button, sourceRect: button.bounds)
```
Even if you specify a `sourceView` and `sourceRect`, the PullUpMenu only shows in popover mode, when appropriate, that is whenever the horizontal size class is regular. It will switch between modes as the available space changes.
<br><br>


A `PullUpMenuItem` always needs a `title`, but can have optionally a `subtitle`, `image`, `tintColor`, `touchUpInsideHandler` and `isActive` property. E.g.
```
PullUpMenuItem(title: "Item", subtitle: "Subtitle", image: UIImage(named: "item"), tintColor: .red, isActive: true, touchUpInsideHandler: { in
  // do stuff when pressed
})
```

## Interactive Animation

To add support for interactive opening of the `PullUpMenuController`, you should add something like this to your base view controller:
```
var interactiveController: PullUpInteractiveAnimator?

override func viewDidLoad() {
  super.viewDidLoad()
  
  interactiveController = PullUpInteractiveAnimator(viewController: self, menuGenerator: {
      let menuController = PullUpMenuController()
      // add data to menu here
      return menuController
  })
}
```


## Important

When using `PullUpMenuItem.touchUpInsideHandler`, you should never use a strong refrence to the corresponding `PullUpMenuController` or the view controller it is presented on. This could lead to memory leaks. 
Recommended way:
```
PullUpMenuItem(title: "Item", touchUpInsideHandler: { [unowned self, unowned menuController] in
  self.doStuff()
  menuController.doStuff()
})
```
