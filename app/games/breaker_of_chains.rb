# frozen_string_literal: true

# Second task (PROBLEM 2: Breaker of Chains)
class BreakerOfChains < Base
  def run
    initialize_kingdoms
    request_pretenders
    run_ballot
  end

  private

  def request_pretenders
    loop do
      puts "Enter names of pretenders, one of this: #{Kingdom.all.map(&:name).join(', ')}"
      puts 'If no one kingdoms will be not provided, Ballot service will be run with all kingdoms'
      @kingdoms = gets.to_s
      break if /[^a-zA-Z,\n,\s]/.match(@kingdoms).nil?
    end
  end

  def run_ballot
    pretenders = extract_pretenders
    puts "Ballot will be run between: #{pretenders.map(&:name).join(', ')}"
    puts Ballot.new(pretenders).run.report
  end

  def extract_pretenders
    pretenders = []
    @kingdoms.split.each { |kingdom| pretenders << instance_variable_get("@#{kingdom.downcase}") }
    pretenders.compact.size > 1 ? pretenders.compact : Kingdom.all
  end
end
