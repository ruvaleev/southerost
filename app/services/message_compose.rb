# frozen_string_literal: true

require 'byebug'
# Service for generating messages between kingdoms
class MessageCompose
  attr_reader :sender, :recipient, :type

  def initialize(type = 'ballot', sender = nil, recipient = nil)
    @type = type
    @sender = sender
    @recipient = recipient
  end

  def compose
    file_path = choose_file_for_parsing(type)
    return if file_path.nil?

    string = File.read(file_path).split("\n").sample
    recipient.nil? || sender.nil? ? string : prepare_message(string)
  end

  private

  def choose_file_for_parsing(type)
    {
      'ballot' => 'messages/ballots_messages.txt',
      'accept' => 'messages/alliance_accept_messages.txt',
      'refuse' => 'messages/alliance_refuse_messages.txt'
    }[type]
  end

  def prepare_message(string)
    {
      recipient_name: recipient.name,
      recipient_king: recipient.king,
      sender_name: sender.name,
      sender_king: sender.king
    }.each { |key, value| string.gsub!("%{#{key}}%", value) }
    string
  end
end
