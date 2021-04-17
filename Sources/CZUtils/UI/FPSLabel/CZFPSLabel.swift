import UIKit

public class CZFPSLabel: UILabel {
  private enum Constant {
    static let size = CGSize(width: 55, height: 20)
  }
  
  private var link: CADisplayLink!
  
  private var lastTime: TimeInterval = 0
  private var count: Int = 0
  private var _llll: TimeInterval = 0
  private var subFont: UIFont?
  
  public override init(frame: CGRect) {
    super.init(frame: frame)
    font = UIFont(name: "Menlo", size: 14)
    
    self.link = CADisplayLink(target: self, selector: #selector(tick(_:)))
    link.add(to: .main, forMode: .common)
    backgroundColor = .red
    
    self.text = "60 fps"
  }
  
  public required init?(coder: NSCoder) {
    fatalError()
  }
  
  deinit {
    link.invalidate()
  }
  
  @objc func tick(_ link: CADisplayLink) {
    guard lastTime != 0 else {
      lastTime = link.timestamp
      return
    }
    count += 1
    let delta = link.timestamp - lastTime
    if delta < 1 {
      return
    }
    lastTime = link.timestamp
    let fps = Double(count) / Double(delta)
    count = 0
    updateText(fps: fps)
  }
  
  public override func sizeThatFits(_ size: CGSize) -> CGSize {
    return Constant.size
  }
  
}

// MARK: - Private methods

private extension CZFPSLabel {
  func updateText(fps: Double) {
    // let progress = fps / 60.0    
    //    UIColor *color = [UIColor colorWithHue:0.27 * (progress - 0.2) saturation:1 brightness:0.9 alpha:1]
    //    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%d FPS",(int)round(fps)]]
    //    [text yy_setColor:color range:NSMakeRange(0, text.length - 3)]
    //    [text yy_setColor:[UIColor whiteColor] range:NSMakeRange(text.length - 3, 3)]
    //    text.yy_font = _font
    //    [text yy_setFont:_subFont range:NSMakeRange(text.length - 4, 1)]
    //
    //    self.attributedText = text
    
    let fpsInt = Int(round(fps))
    text = "\(fpsInt) FPS"
  }
}
