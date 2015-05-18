describe "recorder controller" do
  tests RecorderController

  it "creates an AVAudio object when record is tapped" do
    tap "Record"
    controller.instance_variable_get("@recorder").should.be.kind_of AVAudioRecorder
    tap "Stop"
  end

  it "sets recording state to true" do
    tap "Record"
    controller.instance_variable_get("@recording").should.equal true
    tap "Stop"
  end

  it "stops recording when the stop button is tapped" do
    tap "Record"
    tap "Stop"
    controller.instance_variable_get("@recording").should.equal false
  end

  it "plays the recording when the Play Sound button is pressed" do
    tap "Play Sound"
    controller.instance_variable_get("@player").should.be.kind_of AVPlayer
  end

  it "resets the sample length sliders when the recording starts" do
    controller.instance_variable_get("@sample_length_min_slider").setValue(250)
    controller.instance_variable_get("@sample_length_max_slider").setValue(250)
    tap "Record"
    controller.instance_variable_get("@sample_length_min_slider").value.should.equal controller.instance_variable_get("@sample_length_min_slider").minimumValue
    controller.instance_variable_get("@sample_length_max_slider").value.should.equal controller.instance_variable_get("@sample_length_max_slider").maximumValue
    tap "Stop"
  end

end
