module Sky
  class RewardsService

    attr_reader :account_number, :portfolio

    def initialize(account_number, portfolio=[])
      @account_number = account_number
      @portfolio = portfolio
    end

    def rewards(service)
      begin
        eligible_rewards if service.query(account_number) == "CUSTOMER_ELIGIBLE"
      rescue Exception => e
        # raised = e.class
      ensure
       return "INVALID_ACCOUNT_NUMBER" if e && e.is_a?(Sky::InvalidAccountNumberException)
      end
    end

    private

    def eligible_rewards
      rewards = portfolio.inject({}) {|hash, value| hash[value] = available_rewards[value]; hash}
      rewards.delete_if { |key, value| value == "N/A" }
      rewards.values.join(', ')
    end

    def available_rewards
      {
        "SPORTS"  => "CHAMPIONS_LEAGUE_FINAL_TICKET",
        "KIDS"    => "N/A",
        "MUSIC"   => "KARAOKE_PRO_MICROPHONE",
        "NEWS"    => "N/A",
        "MOVIES"  => "PIRATES_OF_THE_CARIBBEAN_COLLECTION"
      }
    end
  end
end
