# frozen_string_literal: true

# First task (PROBLEM 1: A Golden Crown)
class GoldenCrown < Base
  def run
    initialize_kingdoms(min_vassals_count_for_became_ruler: 2)
    request_input
  end

  private

  def request_input
    loop do
      puts '***'
      puts Kingdom.resume
      puts '***'
      puts 'For exit type "EXIT", for continue - anything else'
      command = gets.to_s.chomp
      break if command.downcase.eql?('exit')

      request_kingdom_input
      request_message_input
    end
  end

  def request_kingdom_input
    loop do
      puts 'Whom do you want to send message to? (input number of Kingdom from 1 to 5)'
      GREAT_HOUSES[1..-1].each_with_index do |kingdom, index|
        puts "#{index + 1}: #{kingdom[:name]} (emblem #{kingdom[:emblem]})"
      end
      @kingdom_index = gets.to_i
      break if (1..5).include?(@kingdom_index)
    end
  end

  def request_message_input
    kingdom = instance_variable_get("@#{GREAT_HOUSES[@kingdom_index][:name].downcase}")
    puts "What message shall we send to #{kingdom.name} Kingdom? (emblem #{kingdom.emblem})"
    message_body = gets.to_s
    message = Message.new(@space, kingdom, message_body)
    puts message.send
  end
end
