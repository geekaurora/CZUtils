import UIKit

public class CZFPSLabel: UILabel {
  private enum Constant {
    static let size = CGSize(width: 55, height: 20)
  }
  
  private var link: CADisplayLink!
  
  private var _lastTime: TimeInterval = 0
  private var _count: Int = 0
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
    // dbgPrintWithFunc(self, "link = \(link)")
    
    if (_lastTime == 0) {
      _lastTime = link.timestamp;
        return;
    }
    
    _count += 1;
    var delta = link.timestamp - _lastTime;
    if (delta < 1) {
      return;
    }
    _lastTime = link.timestamp;
    let fps = Double(_count) / Double(delta);
    _count = 0;
    
    let progress = fps / 60.0;
    
//    UIColor *color = [UIColor colorWithHue:0.27 * (progress - 0.2) saturation:1 brightness:0.9 alpha:1];
//    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%d FPS",(int)round(fps)]];
//    [text yy_setColor:color range:NSMakeRange(0, text.length - 3)];
//    [text yy_setColor:[UIColor whiteColor] range:NSMakeRange(text.length - 3, 3)];
//    text.yy_font = _font;
//    [text yy_setFont:_subFont range:NSMakeRange(text.length - 4, 1)];
//
//    self.attributedText = text;
    

    let fpsInt = Int(round(fps))
    self.text = "\(fpsInt) FPS"
  }
  
  public override func sizeThatFits(_ size: CGSize) -> CGSize {
    return Constant.size
  }
  
}
