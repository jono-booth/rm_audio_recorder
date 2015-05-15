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

    # Button positions
    main_button_position = CGRect.new([(self.view.frame.size.width / 2) - 20, 70], [40, 40])
    play_button_position = CGRect.new([(self.view.frame.size.width / 2) - 50, 110], [100, 40])

    # Record Button
    @record_button = UIButton.buttonWithType(UIButtonTypeSystem)
    @record_button.accessibilityLabel = "Record"
    @record_button.backgroundColor = UIColor.redColor
    @record_button.frame = main_button_position
    @record_button.layer.cornerRadius = 20
    @record_button.addTarget(self, action:"start_recording", forControlEvents:UIControlEventTouchUpInside)
    self.view.addSubview(@record_button)

    # Stop Button
    @stop_button = UIButton.buttonWithType(UIButtonTypeSystem)
    @stop_button.accessibilityLabel = "Stop"
    @stop_button.backgroundColor = UIColor.blackColor
    @stop_button.frame = main_button_position
    @stop_button.addTarget(self, action:"stop_recording", forControlEvents:UIControlEventTouchUpInside)

    # Play Button
    @play_button = UIButton.buttonWithType(UIButtonTypeSystem)
    @play_button.setTitle("Play Sound", forState:UIControlStateNormal)
    @play_button.sizeToFit
    @play_button.frame = play_button_position
    @play_button.addTarget(self, action:"play_recording", forControlEvents:UIControlEventTouchUpInside)
    self.view.addSubview(@play_button)
  end

  def start_recording
    self.view.addSubview(@stop_button)
    @record_button.removeFromSuperview

    err_ptr = Pointer.new :object

    session = AVAudioSession.sharedInstance
    session.setCategory AVAudioSessionCategoryRecord, error:err_ptr

    return handleAudioError(err_ptr[0]) if err_ptr[0]

    @recorder = AVAudioRecorder.alloc.initWithURL local_file, settings:settings, error:err_ptr
    @recorder.setMeteringEnabled(true)
    @recorder.delegate = self;

    if @recorder.prepareToRecord
      @recording = true
      @recorder.record
    else
      raise "prepareToRecord " unless err_ptr[0]
      return handleAudioError(err_ptr[0])
    end

  end

  def stop_recording
    @recording = false
    self.view.addSubview(@record_button)
    @stop_button.removeFromSuperview
    @recorder.stop if @recorder
  end

  def play_recording
    BW::Media.play(local_file) do |media_player|
      @playing = true
#      media_player.view.frame = [[10, 100], [100, 100]]
#      self.view.addSubview media_player.view
    end
  end

  def local_file
    NSURL.fileURLWithPath(App.documents_path + "/record.caf")
  end

  def settings
    @settings ||= {
      :AVFormatIDKey => KAudioFormatLinearPCM,
      :AVNumberOfChannelsKey => 1,
      :AVEncoderBitRateKey => 2,
      :AVSampleRateKey => nil
    }
  end

end
