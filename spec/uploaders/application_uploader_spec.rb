require "rails_helper"

RSpec.describe ApplicationUploader do
  it "can execute magick" do
    expect(MiniMagick.cli_version).to be_present
  end
end
