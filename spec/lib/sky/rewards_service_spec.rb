require_relative "../../spec_helper"

describe Sky::RewardsService do

  let(:eligibility_service) { double("Sky::DummyEligiblityService") }

  it "is a Sky::RewardsService object" do
    expect(described_class.new(eligibility_service, 12345678)).to be_a(Sky::RewardsService)
  end

  describe "#rewards" do
    context "when the customer is eligible" do
      before :each do
        allow(eligibility_service).to receive(:query).with(12345678).and_return("CUSTOMER_ELIGIBLE")
      end

      it "returns Champions League ticket when the customer subscribes to SPORT" do
        reward_service = described_class.new(12345678,['SPORTS'])
        expect(reward_service.rewards(eligibility_service)).to eq("CHAMPIONS_LEAGUE_FINAL_TICKET")
      end

      it "returns Champions League ticket when the customer subscribes to SPORT & KIDS" do
        reward_service = described_class.new(12345678,['SPORTS', 'KIDS'])
        expect(reward_service.rewards(eligibility_service)).to eq("CHAMPIONS_LEAGUE_FINAL_TICKET")
      end

      it "returns Champions League ticket when the customer subscribes to SPORT & NEWS" do
        reward_service = described_class.new(12345678,['SPORTS', 'NEWS'])
        expect(reward_service.rewards(eligibility_service)).to eq("CHAMPIONS_LEAGUE_FINAL_TICKET")
      end

      it "returns two rewards when the customer subscribes to SPORT & MUSIC" do
        reward_service = described_class.new(12345678,['SPORTS', 'MUSIC'])
        expect(reward_service.rewards(eligibility_service)).to eq("CHAMPIONS_LEAGUE_FINAL_TICKET, KARAOKE_PRO_MICROPHONE")
      end

      it "returns three rewards when the customer subscribes to all packages" do
        reward_service = described_class.new(12345678,['SPORTS','KIDS','MUSIC','NEWS','MOVIES'])
        expect(reward_service.rewards(eligibility_service)).to eq("CHAMPIONS_LEAGUE_FINAL_TICKET, KARAOKE_PRO_MICROPHONE, PIRATES_OF_THE_CARIBBEAN_COLLECTION")
      end

      it "returns Karaoke Microphone when the customer subscribes to MUSIC" do
        reward_service = described_class.new(12345678,['MUSIC'])
        expect(reward_service.rewards(eligibility_service)).to eq("KARAOKE_PRO_MICROPHONE")
      end

      it "returns Karaoke Microphone when the customer subscribes to MUSIC & NEWS & KIDS" do
        reward_service = described_class.new(12345678,['MUSIC', 'NEWS', 'KIDS'])
        expect(reward_service.rewards(eligibility_service)).to eq("KARAOKE_PRO_MICROPHONE")
      end

      it "returns no rewards when the customer subscribes to NEWS & KIDS" do
        reward_service = described_class.new(12345678,['NEWS', 'KIDS'])
        expect(reward_service.rewards(eligibility_service)).to eq("")
      end
    end

    context "when the customer is ineligible" do
      before :each do
        allow(eligibility_service).to receive(:query).with(12345678).and_return("CUSTOMER_INELIGIBLE")
      end

      it "returns no rewards when the customer subscribes to NEWS & KIDS" do
        reward_service = described_class.new(12345678,['NEWS', 'KIDS'])
        expect(reward_service.rewards(eligibility_service)).to be_nil
      end

      it "returns no rewards when the customer subscribes to MUSIC & SPORT" do
        reward_service = described_class.new(12345678,['MUSIC', 'SPORT'])
        expect(reward_service.rewards(eligibility_service)).to be_nil
      end
    end

    context "when there is a technical faliure exception" do
      let(:technical_faliure_exception) { Sky::TechnicalFaliureException.new }

      before :each do
        allow(eligibility_service).to receive(:query).with(12345678).and_raise(technical_faliure_exception)
      end

      it "does not return any rewards" do
        reward_service = described_class.new(12345678,['MUSIC', 'SPORT'])
        expect(reward_service.rewards(eligibility_service)).to be_nil
      end
    end

    context "when the account number is invalid" do
      let(:account_number_invalid) { Sky::InvalidAccountNumberException.new }

      before :each do
        allow(eligibility_service).to receive(:query).with('NaN').and_raise(account_number_invalid)
      end

      it "does not return any rewards and informs the client a/c number is invalid" do
        reward_service = described_class.new('NaN', ['MUSIC', 'SPORT'])
        expect(reward_service.rewards(eligibility_service)).to eq("INVALID_ACCOUNT_NUMBER")
      end
    end
  end
end
