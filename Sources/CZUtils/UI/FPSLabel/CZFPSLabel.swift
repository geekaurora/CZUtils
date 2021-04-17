import UIKit

public class CZFPSLabel: UILabel {
  private enum Constant {
    static let size = CGSize(width: 55, height: 20)
  }
  private var link: CADisplayLink!
  private var lastTime: TimeInterval = 0
  private var frames: Int = 0
  
  public override init(frame theFrame: CGRect) {
    var frame = theFrame
    if theFrame.size == .zero {
      frame.size = Constant.size
    }
    super.init(frame: frame)
    setupViews()
    
    self.link = CADisplayLink(target: self, selector: #selector(tick(_:)))
    link.add(to: .main, forMode: .common)
  }

  public required init?(coder: NSCoder) { fatalError() }
  
  deinit {
    link.invalidate()
  }
  
  // MARK: - CADisplayLink
  
  @objc func tick(_ link: CADisplayLink) {
    guard lastTime != 0 else {
      lastTime = link.timestamp
      return
    }
    
    frames += 1
    let timeDelta = link.timestamp - lastTime
    if timeDelta < 1 {
      return
    }
    
    lastTime = link.timestamp
    let fps = Double(frames) / Double(timeDelta)
    frames = 0
    updateText(fps: fps)
  }
  
  // MARK: - Display
  
  /// Displays self on`view` - align leading / bottom to `view`.
  public func display(on view: UIView) {
    if superview == nil {
      view.addSubview(self)
    }
    translatesAutoresizingMaskIntoConstraints = false
    
    NSLayoutConstraint.activate([
      self.alignLeading(to: view.safeAreaLayoutGuide, constant: 5),
      self.alignBottom(to: view.safeAreaLayoutGuide, constant: 5)
    ])
  }
}

// MARK: - Private methods

private extension CZFPSLabel {
  func setupViews() {
    font = UIFont(name: "Menlo", size: 14)
    backgroundColor = UIColor(white: 0.9, alpha: 1)
    textColor = .black
    roundCorner(3)
  }
  
  func updateText(fps: Double) {
    let fpsInt = Int(round(fps))
    text = "\(fpsInt) FPS"
  }
}
