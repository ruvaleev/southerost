# frozen_string_literal: true

# Service for run ballots between kingdoms
class Ballot
  attr_accessor :pretenders, :messages_bucket

  Result = Struct.new(:ruler, :report)

  def initialize(pretenders)
    @pretenders = pretenders
    @messages_bucket = []
    @report = []
    @iteration_count = 0
    @max_iteration_count = 20
  end

  def run
    ((@iteration_count += 1) && hold_ballot) until can_finish_ballot? || (@iteration_count >= @max_iteration_count)
    Result.new(Kingdom.ruler, @report)
  end

  private

  def hold_ballot
    reset_before_ballot
    pretenders.each { |sender| generate_message(sender) }
    send_sample_messages
  end

  def can_finish_ballot?
    @report << Kingdom.resume
    return false if Kingdom.ruler.nil?

    leaders = define_leaders

    return true if leaders.count == 1

    @pretenders = leaders
    @report << 'BALLOTS MUST BE REPEAT BETWEEN LEADERS'
    @report << "Kingdoms #{leaders.map(&:name).join(', ')} have the same number of supporters"
    false
  end

  def define_leaders
    leaders = []
    Kingdom.all.sort_by! { |k| k.vassals.count }.reverse.each do |kingdom|
      kingdom.vassals.count < Kingdom.ruler.vassals.count ? break : leaders << kingdom
    end
    leaders
  end

  def reset_before_ballot
    Kingdom.reset
    @messages_bucket = []
  end

  def generate_message(sender)
    Kingdom.all.each do |receiver|
      messages_bucket << Message.new(sender, receiver, MessageCompose.new.compose) unless receiver.eql?(sender)
    end
  end

  def send_sample_messages
    @report << 'MESSAGES:'
    messages_bucket.sample(6).each do |message|
      @report << report_about_send(message)
      @report << report_about_respond(message)
    end
  end

  def report_about_send(message)
    "#{message.from.name} sends message to #{message.to.name} (emblem #{message.to.emblem}): #{message.body}"
  end

  def report_about_respond(message)
    "#{message.to.name} responds: #{message.send}"
  end
end
