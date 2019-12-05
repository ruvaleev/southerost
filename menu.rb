# frozen_string_literal: true

require_relative 'config/initializer.rb'

loop do
  puts 'Select the task:'
  puts '1 - Golden Crown'
  puts '2 - Breaker of Chains'
  puts '3 - Exit'
  v = gets.to_i

  if v == 1
    GoldenCrown.new.run
  elsif v == 2
    BreakerOfChains.new.run
  elsif v == 3
    puts 'Good bye!'
    exit
  else
    puts 'Please enter digit from 1 to 3'
  end
end
