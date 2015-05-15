describe "recorder controller" do
  tests RecorderController

  it "creates an AVAudio object when record is tapped" do
    tap "Record"
    controller.instance_variable_get("@recorder").should.be.kind_of AVAudioRecorder
  end

  it "sets recording state to true" do
    tap "Record"
    controller.instance_variable_get("@recording").should.equal true
  end

  it "stops recording when the stop button is tapped" do
    tap "Record"
    tap "Stop"
    controller.instance_variable_get("@recording").should.equal false
  end

  it "plays the recording when the Play Sound button is pressed" do
    tap "Play Sound"
    controller.instance_variable_get("@playing").should.equal true
  end

end
