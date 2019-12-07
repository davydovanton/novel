RSpec.describe Novel do
  it "has a version number" do
    expect(Novel::VERSION).not_to be nil
  end
end
