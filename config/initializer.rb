# frozen_string_literal: true

require 'ffaker'
Dir[File.join('.', 'app', '*', '*.rb')].each { |file| require file }

GREAT_HOUSES = [
  { name: 'Space', emblem: 'Gorilla', king: 'Shan' },
  { name: 'Land', emblem: 'Panda', king: FFaker::Name.first_name_male },
  { name: 'Water', emblem: 'Octopus', king: FFaker::Name.first_name_male },
  { name: 'Ice', emblem: 'Mammoth', king: FFaker::Name.first_name_male },
  { name: 'Air', emblem: 'Owl', king: FFaker::Name.first_name_male },
  { name: 'Fire', emblem: 'Dragon', king: FFaker::Name.first_name_male }
].freeze
