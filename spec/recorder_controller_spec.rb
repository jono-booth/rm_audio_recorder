describe "recorder controller" do
  tests RecorderController

  it "changes record button to a stop button when the record button is tapped" do
    tap "Record"
    controller.instance_variable_get("@recording").should.equal true
  end

  it "changes back to a record button when the stop button is pressed" do
    tap "Record"
    tap "Stop"
    controller.instance_variable_get("@recording").should.equal false
  end
end
