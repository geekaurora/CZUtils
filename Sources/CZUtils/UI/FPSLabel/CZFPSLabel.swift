import UIKit

public class CZFPSLabel: UILabel {
  public enum Constant {
    public static let size = CGSize(width: 55, height: 20)
    public static let backgroundColor = UIColor(white: 0.1, alpha: 1)
  }
  private var displayLinkMonitor: CADisplayLinkMonitor!
  
  public override init(frame theFrame: CGRect) {
    var frame = theFrame
    if theFrame.size == .zero {
      frame.size = Constant.size
    }
    super.init(frame: frame)
    setupViews()
    
    // Initialize CADisplayLinkMonitor.
    displayLinkMonitor = CADisplayLinkMonitor()
    displayLinkMonitor.delegate = self
  }

  public required init?(coder: NSCoder) { fatalError() }
  
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
  
  public override func sizeThatFits(_ size: CGSize) -> CGSize {
    Constant.size
  }
}

// MARK: - CADisplayLinkMonitorDelegate

extension CZFPSLabel: CADisplayLinkMonitorDelegate {
  public func displayFrameDidUpdate(link: CADisplayLink, fps: Double?) {
    guard let fps = fps else {
      return
    }
    updateText(fps: fps)
  }
}

// MARK: - Private methods

private extension CZFPSLabel {
  func setupViews() {
    font = UIFont(name: "Menlo", size: 14)
    backgroundColor = Constant.backgroundColor
    textColor = UIColor(red: 200.0 / 255.0, green: 0, blue: 0, alpha: 1)
    roundCorner(3)
  }
  
  func updateText(fps: Double) {
    let fpsInt = Int(round(fps))
    text = "\(fpsInt) FPS"
    
    let progress = fps / 60.0;
    let color = UIColor(hue: CGFloat(0.27 * (progress - 0.2)), saturation: 1, brightness: 1, alpha: 1)
    self.textColor = color
  }
}
