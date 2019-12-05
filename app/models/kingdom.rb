# frozen_string_literal: true

# Model of Kingdoms of Southerost
class Kingdom
  @@min_vassals_count_for_became_ruler ||= 0 # rubocop:disable Style/ClassVars

  attr_accessor :name, :emblem, :king, :ruler, :vassals, :sovereign
  def initialize(name, emblem, king)
    @name = name
    @emblem = emblem
    @king = king
    @ruler = false
    @sovereign = nil
    @vassals = []
  end

  def ask_for_allegiance(recipient, message = nil)
    message ||= MessageCompose.new('ballot').compose
    recipient.send_response(self, message)
  end

  def send_response(recipient, message)
    proposal_accepted?(message) ? make_alliance_with(recipient) : reject(recipient) # @reject_reason
  end

  def can_become_ruler?
    !ruler && vassals.count > (Kingdom.ruler&.vassals&.count || @@min_vassals_count_for_became_ruler)
  end

  def make_ruler
    Kingdom.ruler.ruler = false unless Kingdom.ruler.nil?
    self.ruler = true
  end

  def self.all
    result = []
    ObjectSpace.each_object(self) { |k| result << k }
    result
  end

  def self.ruler
    result = nil
    Kingdom.all.each { |k| result = k if k.ruler }
    result
  end

  def self.reset
    ObjectSpace.each_object(self) do |k|
      k.vassals = []
      k.ruler = false
      k.sovereign = nil
    end
  end

  def self.resume
    result = ['RESUME:']
    Kingdom.all.each { |kingdom| result << kingdom.kingdom_resume }

    result << if Kingdom.ruler.nil?
                'There is no Ruler in Southeros'
              else
                "The Ruler is #{Kingdom.ruler.name.capitalize} Kingdom"
              end
    result
  end

  def self.find_or_create(name, emblem, king)
    Kingdom.all.find { |kingdom| kingdom.name == name } || Kingdom.new(name, emblem, king)
  end

  def kingdom_resume
    "Kingdom #{name} (King #{king}, Emblem #{emblem}): " + [vassals_string, sovereign_string].join(', ')
  end

  def vassals_string
    vassal_names = vassals.each_with_object([]) { |v, array| array << v.name }
    vassal_names.empty? ? 'has no vassals' : "has #{vassal_names.count} vassals: #{vassal_names.join(', ')}"
  end

  def sovereign_string
    sovereign.nil? ? 'has no sovereign' : "sovereign is #{sovereign.name.capitalize} Kingdom"
  end

  private

  def proposal_accepted?(message)
    if inappropriate_emblem?(message)
      assign_reject_reason("You don't know our emblem?")
    elsif ruler
      assign_reject_reason('How dare you to propose it to Ruler?!')
    elsif sovereign
      assign_reject_reason("We are already commited to #{sovereign&.name}")
    else
      true
    end
  end

  def inappropriate_emblem?(message)
    message_for_checking = message.downcase
    emblem.downcase.each_char { |l| return true if message_for_checking.slice!(l).nil? }
    false
  end

  def assign_reject_reason(reason)
    @reject_reason = reason
    false
  end

  def reject(recipient)
    [MessageCompose.new('refuse', self, recipient).compose, @reject_reason].compact.join(' | ')
  end

  def make_alliance_with(recipient)
    recipient.vassals << self
    self.sovereign = recipient

    [MessageCompose.new('accept', self, recipient).compose, make_ruler_if_possible(recipient)].compact.join(' | ')
  end

  def make_ruler_if_possible(recipient)
    return unless recipient.can_become_ruler?

    recipient.make_ruler
    "We have new Ruler - Kingdom #{recipient.name}"
  end
end
