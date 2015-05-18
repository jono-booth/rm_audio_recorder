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

    view_center = self.view.frame.size.width / 2

    # Button positions
    main_button_position = CGRect.new([(view_center) - 20, 70], [40, 40])

    # Record Button
    @record_button = UIButton.buttonWithType(UIButtonTypeSystem)
    @record_button.accessibilityLabel = "Record"
    @record_button.setTitle("Save", forstate:UIControlStateNormal)
    @record_button.frame = main_button_position
    @record_button.backgroundColor = UIColor.redColor
    @record_button.layer.cornerRadius = 20
    @record_button.addTarget(self, action:"start_recording", forControlEvents:UIControlEventTouchUpInside)
    self.view.addSubview(@record_button)

    # Stop Button
    @stop_button = UIButton.buttonWithType(UIButtonTypeSystem)
    @stop_button.accessibilityLabel = "Stop"
    @stop_button.backgroundColor = UIColor.blackColor
    @stop_button.frame = main_button_position
    @stop_button.addTarget(self, action:"stop_recording", forControlEvents:UIControlEventTouchUpInside)

    # Sample Length
    @sample_length_label = UILabel.alloc.initWithFrame(CGRectZero)
    @sample_length_label.text = "Sample Length"
    @sample_length_label.sizeToFit
    @sample_length_label.center = [view_center, 140]
    self.view.addSubview(@sample_length_label)

    sample_length_position = [view_center - 165, 150], [165, 40]
    @sample_length_min_slider = UISlider.alloc.initWithFrame(sample_length_position)
    @sample_length_min_slider.addTarget(self, action:"adjust_start_position", forControlEvents:UIControlEventValueChanged)
    @sample_length_min_slider.maximumValue = 50
    @sample_length_min_slider.value = 0
    @sample_length_min_slider.minimumTrackTintColor = UIColor.blackColor
    @sample_length_min_slider.maximumTrackTintColor = UIColor.blackColor
    self.view.addSubview(@sample_length_min_slider)

    sample_length_position = [view_center - 5, 150], [165, 40]
    @sample_length_max_slider = UISlider.alloc.initWithFrame(sample_length_position)
    @sample_length_max_slider.maximumValue = 100
    @sample_length_max_slider.minimumValue = 50
    @sample_length_max_slider.setValue(@sample_length_max_slider.maximumValue)
    @sample_length_max_slider.minimumTrackTintColor = UIColor.blackColor
    @sample_length_max_slider.maximumTrackTintColor = UIColor.blackColor
    self.view.addSubview(@sample_length_max_slider)

    # Save Clip Button
    @save_button = UIButton.buttonWithType(UIButtonTypeSystem)
    @save_button.setTitle("Save As New", forState:UIControlStateNormal)
    @save_button.setTitleColor(UIColor.redColor, forState:UIControlStateNormal)
    @save_button.titleLabel.font = UIFont.systemFontOfSize(18)
    @save_button.sizeToFit
    @save_button.frame = CGRect.new([view_center - @save_button.frame.size.width/2, 180],@save_button.frame.size)
    @save_button.addTarget(self, action:"save_clip", forControlEvents:UIControlEventTouchUpInside)
    self.view.addSubview(@save_button)

    table_view_frame = [view_center - 160, 210], [320, self.view.frame.size.height - 210]
    @table = UITableView.alloc.initWithFrame(table_view_frame)
    @table.dataSource = self
    @table.delegate = self
    self.view.addSubview(@table)

    fetch_files

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

    @recorder = AVAudioRecorder.alloc.initWithURL new_file, settings:settings, error:nil
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
    self.view.addSubview(@record_button)
    @stop_button.removeFromSuperview
    @recorder.stop if @recorder
    fetch_files
    @table.reloadData
  end

  def play_recording filename
    @start_time = KCMTimeZero unless @start_time

    file = NSURL.fileURLWithPath(App.documents_path + '/' + filename)
    @player = AVPlayer.alloc.initWithURL file
    @player.seekToTime(@start_time, toleranceBefore:KCMTimeZero, toleranceAfter:KCMTimeZero)
    @player.play

    @duration = @player.currentItem.asset.duration
    @duration_in_seconds = CMTimeGetSeconds(@duration)
    @end_time = @duration unless @end_time

    @player.addPeriodicTimeObserverForInterval(CMTimeMake(1, 20), queue:nil, usingBlock:lambda do |time|
      value = CMTimeGetSeconds(@player.currentTime)
      stop_at_end_time(value)
    end)
    @timer = NSTimer.scheduledTimerWithTimeInterval(@reverb_time, target:self, selector:'reverb_track', userInfo:nil, repeats:false)
  end

  def save_clip
    if @player
      asset = @player.currentItem.asset

      @export_session = AVAssetExportSession.alloc.initWithAsset(asset, presetName:AVAssetExportPresetAppleM4A)
      @export_session.inspect
      @export_session.outputURL = new_file
      @export_session.outputFileType = AVFileTypeAppleM4A

      length = CMTimeGetSeconds(@end_time) - CMTimeGetSeconds(@start_time)
      duration = CMTimeMakeWithSeconds(length, @start_time.timescale)
      range = CMTimeRangeMake(@start_time, duration)

      @export_session.timeRange = range
      @export_session.exportAsynchronouslyWithCompletionHandler(Proc.new{
        case @export_session.status
        when AVAssetExportSessionStatusFailed
          p @export_session.error.localizedDescription
        end
        fetch_files
      })
    end
  end

  def adjust_start_position
    if @player
      start_time = (@sample_length_min_slider.value / 100) * @duration_in_seconds
      @start_time = CMTimeMakeWithSeconds(start_time, @duration.timescale)
    end
  end

  def adjust_end_position
    if @player
      end_time = (@sample_length_max_slider.value / 100) * @duration_in_seconds
      @end_time = CMTimeMakeWithSeconds(end_time, @duration.timescale)
    end
  end

  def stop_at_end_time value
    if value > ((@sample_length_max_slider.value / 100) * @duration_in_seconds)
      @player.pause if @player
      @reverb.pause if @reverb
    end
  end

  def new_file
    number = @recordings.size+1
    filename = App.documents_path + '/Recording_' + number.to_s + '.aif'
    NSURL.fileURLWithPath(filename)
  end

  def fetch_files
    @file_manager ||= NSFileManager.defaultManager
    @recordings = @file_manager.contentsOfDirectoryAtPath(App.documents_path, error:nil)
  end

  def tableView(tableView, numberOfRowsInSection: section)
    @recordings.size
  end

  def tableView(tableView, cellForRowAtIndexPath: indexPath)
    @cell_id ||= "CELL_IDENTIFIER"
    cell = tableView.dequeueReusableCellWithIdentifier(@cell_id) || begin
      UITableViewCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier: @cell_id)
    end
    cell.textLabel.text = @recordings[indexPath.row]
    cell
  end

  def tableView(tableView, didSelectRowAtIndexPath:indexPath)
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
    play_recording(@recordings[indexPath.row])
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
