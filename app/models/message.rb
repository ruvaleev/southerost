# frozen_string_literal: true

# Model for Messages between Kingdoms
class Message
  attr_accessor :from, :to, :body
  def initialize(from, to, body)
    @from = from
    @to = to
    @body = body
  end

  def send
    from.ask_for_allegiance(to, body)
  end
end
