# frozen_string_literal: true

require 'factory_bot'
require 'capybara'
require 'rspec/retry'
require './config/initializer.rb'

Dir[File.join('.', 'spec', 'factories', '*.rb')].each { |file| require file }

RSpec.configure do |config|
  config.verbose_retry = false
  config.display_try_failure_messages = true
  config.around :each do |ex|
    ex.run_with_retry retry: 20 unless ex.run_with_retry
  end
  config.include FactoryBot::Syntax::Methods

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end
  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
  config.shared_context_metadata_behavior = :apply_to_host_groups
end
