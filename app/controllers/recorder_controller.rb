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

    # Main Button position
    button_position = CGRect.new([(self.view.frame.size.width / 2) - 20, 70], [40, 40])

    # Record Button
    @record_button = UIButton.buttonWithType(UIButtonTypeSystem)
    @record_button.frame = button_position
    @record_button.layer.cornerRadius = 20
    @record_button.backgroundColor = UIColor.redColor
    @record_button.addTarget(self, action:"start_recording", forControlEvents:UIControlEventTouchUpInside)
    self.view.addSubview(@record_button)

    # Stop Button
    @stop_button = UIButton.buttonWithType(UIButtonTypeSystem)
    @stop_button.frame = button_position
    @stop_button.backgroundColor = UIColor.blackColor
  end

  def start_recording
    # Show stop button
    self.view.addSubview(@stop_button)
  end
end
