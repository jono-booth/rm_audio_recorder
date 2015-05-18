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
    play_button_position = CGRect.new([(self.view.frame.size.width / 2) - 50, 110], [100, 40])
    @play_button = UIButton.buttonWithType(UIButtonTypeSystem)
    @play_button.setTitle("Play Sound", forState:UIControlStateNormal)
    @play_button.sizeToFit
    @play_button.frame = play_button_position
    @play_button.addTarget(self, action:"play_recording", forControlEvents:UIControlEventTouchUpInside)
    self.view.addSubview(@play_button)

    # Sample Length
    sample_length_position = [(self.view.frame.size.width / 2) - 165, 180], [165, 40]
    @sample_length_min_slider = UISlider.alloc.initWithFrame(sample_length_position)
    @sample_length_min_slider.addTarget(self, action:"adjust_start_position", forControlEvents:UIControlEventValueChanged)
    @sample_length_min_slider.maximumValue = 50
    @sample_length_min_slider.value = 0
    @sample_length_min_slider.minimumTrackTintColor = UIColor.blackColor
    @sample_length_min_slider.maximumTrackTintColor = UIColor.blackColor
    self.view.addSubview(@sample_length_min_slider)

    sample_length_position = [(self.view.frame.size.width / 2) - 5, 180], [165, 40]
    @sample_length_max_slider = UISlider.alloc.initWithFrame(sample_length_position)
    @sample_length_max_slider.maximumValue = 100
    @sample_length_max_slider.minimumValue = 50
    @sample_length_max_slider.setValue(@sample_length_max_slider.maximumValue)
    @sample_length_max_slider.minimumTrackTintColor = UIColor.blackColor
    @sample_length_max_slider.maximumTrackTintColor = UIColor.blackColor
    self.view.addSubview(@sample_length_max_slider)

    @sample_length_label = UILabel.alloc.initWithFrame(CGRectZero)
    @sample_length_label.text = "Sample Length"
    @sample_length_label.sizeToFit
    @sample_length_label.center = [self.view.frame.size.width / 2, 170]
    self.view.addSubview(@sample_length_label)

    # Reverb Volume Slider
    reverb_slider_position = [(self.view.frame.size.width / 2) - 160, 250], [320, 40]
    @reverb_slider = UISlider.alloc.initWithFrame(reverb_slider_position)
    @reverb_slider.addTarget(self, action:"adjust_reverb", forControlEvents:UIControlEventValueChanged)
    @reverb_slider.maximumValue = 1
    @reverb_volume = 0
    self.view.addSubview(@reverb_slider)

    @reverb_volume_label = UILabel.alloc.initWithFrame(CGRectZero)
    @reverb_volume_label.text = "Reverb Volume"
    @reverb_volume_label.sizeToFit
    @reverb_volume_label.center = [self.view.frame.size.width / 2, 240]
    self.view.addSubview(@reverb_volume_label)

    # Reverb Time Slider
    reverb_time_slider_position = [(self.view.frame.size.width / 2) - 160, 310], [320, 40]
    @reverb_time_slider = UISlider.alloc.initWithFrame(reverb_time_slider_position)
    @reverb_time_slider.addTarget(self, action:"adjust_reverb_time", forControlEvents:UIControlEventValueChanged)
    @reverb_time_slider.maximumValue = 1
    @reverb_time = 0.2
    @reverb_time_slider.value = @reverb_time
    self.view.addSubview(@reverb_time_slider)

    @reverb_time_label = UILabel.alloc.initWithFrame(CGRectZero)
    @reverb_time_label.text = "Reverb Time"
    @reverb_time_label.sizeToFit
    @reverb_time_label.center = [self.view.frame.size.width / 2, 300]
    self.view.addSubview(@reverb_time_label)

  end

  def start_recording
    @sample_length_min_slider.setValue(@sample_length_min_slider.minimumValue)
    @sample_length_max_slider.setValue(@sample_length_max_slider.maximumValue)

    self.view.addSubview(@stop_button)
    @record_button.removeFromSuperview

    err_ptr = Pointer.new :object
    @session = AVAudioSession.sharedInstance
    @session.setCategory AVAudioSessionCategoryPlayAndRecord, error:err_ptr
    return handleAudioError(err_ptr[0]) if err_ptr[0]

    @recorder = AVAudioRecorder.alloc.initWithURL local_file, settings:settings, error:nil
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
    @player = AVPlayer.alloc.initWithURL(local_file)
    @player.seekToTime(@seek_to_start_time, toleranceBefore:KCMTimeZero, toleranceAfter:KCMTimeZero) if @seek_to_start_time
    @player.play
    @player.addPeriodicTimeObserverForInterval(CMTimeMake(1, 20), queue:nil, usingBlock:lambda do |time|
      stop_at_end_time()
    end)
    @timer = NSTimer.scheduledTimerWithTimeInterval(@reverb_time, target:self, selector:'reverb_track', userInfo:nil, repeats:false)
  end

  def reverb_track
    @reverb = AVPlayer.alloc.initWithURL(local_file)
    @reverb.setVolume @reverb_volume
    @reverb.play
  end

  def adjust_reverb
    @reverb_volume = @reverb_slider.value
    p @reverb_slider.value
    @reverb.setVolume @reverb_volume if @reverb
  end

  def adjust_reverb_time
    @reverb_time = @reverb_time_slider.value
  end

  def adjust_start_position
    if @player
      duration = @player.currentItem.asset.duration
      duration_in_seconds = CMTimeGetSeconds(@player.currentItem.asset.duration)
      start_time = (@sample_length_min_slider.value / 100) * duration_in_seconds
      @seek_to_start_time = CMTimeMakeWithSeconds(start_time, duration.timescale)
    end
  end

  def stop_at_end_time
    duration_in_seconds = CMTimeGetSeconds(@player.currentItem.asset.duration)
    value = CMTimeGetSeconds(@player.currentTime)
    if value > ((@sample_length_max_slider.value / 100) * duration_in_seconds)
      @player.pause
      @reverb.pause
    end
  end

  def local_file
    NSURL.fileURLWithPath(App.documents_path + "/record.aif")
  end

  def settings
    @settings ||= {
      AVFormatIDKey: KAudioFormatLinearPCM,
      AVNumberOfChannelsKey: 1,
      AVEncoderBitRateKey: 16,
      AVSampleRateKey: 44100.0
    }
  end

end
