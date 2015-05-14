class RecorderController < UIViewController
  def viewDidLoad
    super
    self.view.backgroundColor = UIColor.whiteColor

    # App Header
    @title = UILabel.alloc.initWithFrame(CGRectZero)
    @title.text = "RM Audio Recorder"
    @title.sizeToFit
    @title.center = [self.view.frame.size.width / 2, 40]
    self.view.addSubview(@title)

    # Record Button
    @record_button = UIButton.buttonWithType(UIButtonTypeSystem)
    @record_button.frame = CGRect.new([(self.view.frame.size.width / 2) - 20, 70], [40, 40])
    @record_button.layer.cornerRadius = 20
    @record_button.backgroundColor = UIColor.redColor
    self.view.addSubview(@record_button)
  end

  def start_recording
  end
end
