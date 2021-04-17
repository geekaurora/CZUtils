import UIKit

public class CZFPSLabel: UIView {
  private var link: CADisplayLink!
  
  public override init(frame: CGRect) {
    super.init(frame: frame)

    self.link = CADisplayLink(target: self, selector: #selector(tick(_:)))
    link.add(to: .main, forMode: .common)
    
    backgroundColor = .red
  }
  
  public required init?(coder: NSCoder) {
    fatalError()
  }
  
  deinit {
    link.invalidate()
  }
  
  @objc func tick(_ link: CADisplayLink) {
    // dbgPrintWithFunc(self, "link = \(link)")
  }
  
}
