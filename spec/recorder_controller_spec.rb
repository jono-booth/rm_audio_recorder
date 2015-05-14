describe "recorder controller" do
  tests RecorderController

  it "changes record button to a stop button when the record button is tapped" do
    tap "Record"
    controller.instance_variable_get("@recording").should.equal true
  end
end
