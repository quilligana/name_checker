require "spec_helper"

describe NameChecker::FacebookChecker, "check" do
  it "should return negative if the name is too short" do
    VCR.use_cassette("facebook/too_short") do
      availability = NameChecker::FacebookChecker.check("jsda")
      availability.should be_unavailable
    end
  end

  it "should return positive the name is available" do
    VCR.use_cassette("available_facebook") do
      availability = NameChecker::FacebookChecker.check("sdfjksdh")
      availability.should be_available
    end
  end

  it "should return negtive if the name is taken" do
    VCR.use_cassette("unavailable_facebook") do
      availability = NameChecker::FacebookChecker.check("davidtuite")
      availability.should be_unavailable
    end
  end

  it "should non choke on weird chars" do
    VCR.use_cassette("weird_chars_facebook") do
      availability = NameChecker::FacebookChecker.check("rememberly")
      availability.should be_unavailable
    end
  end

  context "server returns 500 response" do
    let(:response) { stub(code: 500, headers: {}) }
    before { NameChecker::FacebookChecker.stub(:get) { response } }

    it "should return unknown if there is an error" do
      availability = NameChecker::FacebookChecker.check("dsjfh")
      availability.should be_unknown
    end

    it "should log the error if there is a server error" do
      Logging.logger.should_receive(:warn)
      NameChecker::FacebookChecker.check("kdfjss")
    end
  end
end
