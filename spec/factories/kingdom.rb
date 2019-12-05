# frozen_string_literal: true

FactoryBot.define do
  factory :kingdom, class: 'Kingdom' do
    name { GREAT_HOUSES.sample[:name] }
    emblem { GREAT_HOUSES.sample[:emblem] }
    king { FFaker::Name.first_name_male }

    initialize_with { new(name, emblem, king) }
  end
end
