# frozen_string_literal: true

FactoryBot.define do
  factory :message, class: 'Message' do
    from { FactoryBot.build(:kingdom) }
    to { FactoryBot.build(:kingdom) }
    body { 'some body' }

    initialize_with { new(from, to, body) }
  end
end
