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

A `PullUpMenuItem` always needs a `title`, but can have optionally a `subtitle`, `image`, `tintColor`, `touchUpInsideHandler` and `isActive` property. E.g.
```
PullUpMenuItem(title: "Item", subtitle: "Subtitle", image: UIImage(named: "item"), tintColor: .red, isActive: true, touchUpInsideHandler: { in
  // do stuff when pressed
})
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
