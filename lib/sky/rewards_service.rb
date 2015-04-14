module Sky
  class RewardsService
    def initialize(account_number, portfolio = [])
      @account_number = account_number
      @portfolio = portfolio
    end

    def rewards(service)
      # begin
        eligible_rewards if eligible?(service)
      # rescue => error
      #   require 'pry'; binding.pry
      #   puts error
      # end
    end

    private

    attr_reader :account_number, :portfolio

    def available_rewards
      {
        'SPORTS'  => 'CHAMPIONS_LEAGUE_FINAL_TICKET',
        'KIDS'    => 'N/A',
        'MUSIC'   => 'KARAOKE_PRO_MICROPHONE',
        'NEWS'    => 'N/A',
        'MOVIES'  => 'PIRATES_OF_THE_CARIBBEAN_COLLECTION'
      }
    end

    def eligible_rewards
      portfolio.each_with_object([]) do |value, array|
        array << available_rewards[value] unless 
          available_rewards[value] == 'N/A'
      end
    end

    def eligible?(service)
      service.query(account_number) == 'CUSTOMER_ELIGIBLE'
    end
  end
end
