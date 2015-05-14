class RecorderController < UIViewController
  def viewDidLoad
    super
    self.view.backgroundColor = UIColor.whiteColor

    # App Header
    @label = UILabel.alloc.initWithFrame(CGRectZero)
    @label.text = "RM Audio Recorder"
    @label.sizeToFit
    @label.center = [self.view.frame.size.width / 2, 40]
    self.view.addSubview(@label)

    # Record Button
    record_button = UIView.alloc.initWithFrame(CGRect.new([(self.view.frame.size.width / 2) - 20, 70], [40, 40]))
    record_button.layer.cornerRadius = 20
    record_button.backgroundColor = UIColor.redColor
    self.view.addSubview(record_button)
  end
end
