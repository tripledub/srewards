Dir[File.dirname(__FILE__) + '/sky/*.rb'].each do |file|
  require file
end

module Sky
  class InvalidAccountNumberException < StandardError
    def to_s
      'INVALID_ACCOUNT_NUMBER'
    end
  end

  class TechnicalFailureException < StandardError
    def to_s
      ''
    end
  end
end
