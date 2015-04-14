require_relative '../../spec_helper'

describe Sky::RewardsService do
  let(:eligibility_service) { double('Sky::DummyEligiblityService') }

  it 'is a Sky::RewardsService object' do
    expect(described_class.new(12_345_678, [])).to be_a(Sky::RewardsService)
  end

  describe '#rewards' do
    context 'for an eligible customer account' do
      before :each do
        allow(eligibility_service).to receive(:query)
          .with(12_345_678).and_return('CUSTOMER_ELIGIBLE')
      end

      context 'when the customer subscribes to SPORT' do
        it 'returns Champions League Ticket' do
          reward_service = described_class.new(12_345_678, ['SPORTS'])
          expect(reward_service.rewards(eligibility_service))
            .to eq(['CHAMPIONS_LEAGUE_FINAL_TICKET'])
        end
      end

      context 'when the customer subscribes to SPORT & KIDS' do
        it 'returns Champions League Ticket' do
          reward_service = described_class.new(12_345_678, %w(SPORTS KIDS))
          expect(reward_service.rewards(eligibility_service))
            .to eq(['CHAMPIONS_LEAGUE_FINAL_TICKET'])
        end
      end

      context 'when the customer subscribes to SPORT & NEWS' do
        it 'returns Champions League Ticket' do
          reward_service = described_class.new(12_345_678, %w(SPORTS NEWS))
          expect(reward_service.rewards(eligibility_service))
            .to eq(['CHAMPIONS_LEAGUE_FINAL_TICKET'])
        end
      end

      context 'when the customer subscribes to MUSIC' do
        it 'returns Karaoke Microphone' do
          reward_service = described_class.new(12_345_678, %w(MUSIC))
          expect(reward_service.rewards(eligibility_service))
            .to eq(['KARAOKE_PRO_MICROPHONE'])
        end
      end

      context 'when the customer subscribes to MUSIC & NEWS & KIDS' do
        it 'returns Karaoke Microphone' do
          reward_service = described_class.new(12_345_678, %w(MUSIC NEWS KIDS))
          expect(reward_service.rewards(eligibility_service))
            .to eq(['KARAOKE_PRO_MICROPHONE'])
        end
      end

      context 'when the customer subscribes to NEWS & KIDS' do
        it 'returns no rewards' do
          reward_service = described_class.new(12_345_678, %w(NEWS KIDS))
          expect(reward_service.rewards(eligibility_service)).to eq([])
        end
      end

      context 'when the customer subscribes to SPORT & MUSIC' do
        let(:reward_service) do
          described_class.new(12_345_678, %w(SPORTS MUSIC))
        end

        it 'returns two rewards' do
          expect(reward_service.rewards(eligibility_service).size).to eq(2)
        end

        it 'includes a Champions League Final Ticket' do
          expect(reward_service.rewards(eligibility_service))
            .to include('CHAMPIONS_LEAGUE_FINAL_TICKET')
        end

        it 'includes a Karaoke Pro Microphone' do
          expect(reward_service.rewards(eligibility_service))
            .to include('KARAOKE_PRO_MICROPHONE')
        end
      end

      context 'when the customer is subscribed to all packages' do
        let(:reward_service) do
          described_class.new(12_345_678, %w(SPORTS KIDS MUSIC NEWS MOVIES))
        end

        it 'returns three rewards' do
          expect(reward_service.rewards(eligibility_service).size).to eq(3)
        end

        it 'includes a Champions League Final Ticket' do
          expect(reward_service.rewards(eligibility_service))
            .to include('CHAMPIONS_LEAGUE_FINAL_TICKET')
        end

        it 'includes a Karaoke Pro Microphone' do
          expect(reward_service.rewards(eligibility_service))
            .to include('KARAOKE_PRO_MICROPHONE')
        end

        it 'includes the Pirates of the Carribean Collection' do
          expect(reward_service.rewards(eligibility_service))
            .to include('PIRATES_OF_THE_CARIBBEAN_COLLECTION')
        end
      end
    end

    context 'when the customer is ineligible' do
      before :each do
        allow(eligibility_service).to receive(:query)
          .with(12_345_678).and_return('CUSTOMER_INELIGIBLE')
      end

      it 'returns no rewards when the customer subscribes to NEWS & KIDS' do
        reward_service = described_class.new(12_345_678, %w(NEWS KIDS))
        expect(reward_service.rewards(eligibility_service)).to be_nil
      end

      it 'returns no rewards when the customer subscribes to MUSIC & SPORT' do
        reward_service = described_class.new(12_345_678, %w(MUSIC SPORT))
        expect(reward_service.rewards(eligibility_service)).to be_nil
      end
    end

    context 'when there is a technical failure exception' do
      let(:technical_failure_exception) do
        Sky::TechnicalFailureException.new
      end

      before do
        allow(eligibility_service).to receive(:query)
          .with(12_345_678).and_raise(technical_failure_exception)
      end

      it 'does not return any rewards' do
        reward_service = described_class.new(12_345_678, %w(MUSIC SPORT))
        expect(reward_service.rewards(eligibility_service)).to eq('')
      end
    end

    context 'when the account number is invalid' do
      let(:account_number_invalid) do
        Sky::InvalidAccountNumberException.new
      end

      before :each do
        allow(eligibility_service).to receive(:query)
          .with(345_789).and_raise(Sky::InvalidAccountNumberException.new)
      end

      it 'returns no rewards and informs the client a/c number is invalid' do
        reward_service = described_class.new(345_789, %w(MUSIC SPORT))
        expect(reward_service.rewards(eligibility_service))
          .to eq('INVALID_ACCOUNT_NUMBER')
      end
    end
  end
end
