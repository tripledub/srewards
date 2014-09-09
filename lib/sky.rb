Dir[File.dirname(__FILE__) + '/sky/*.rb'].each do |file|
  require file
end

module Sky
  class InvalidAccountNumberException < StandardError; end
  class TechnicalFaliureException < StandardError; end
end
