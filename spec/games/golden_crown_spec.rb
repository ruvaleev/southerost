# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GoldenCrown do
  describe 'run' do
    subject(:service) { described_class.new }

    let(:message_double) { instance_double(Message) }

    before do
      allow(service).to receive(:request_input)
      service.run
    end

    it 'initializes kingdoms' do
      expect(Kingdom.all.count).to eq GREAT_HOUSES.count
    end

    it 'establish min_vassals_count_for_became_ruler to 2' do
      expect(Kingdom.class_variable_get('@@min_vassals_count_for_became_ruler')).to eq 2
    end

    it 'requests user input' do
      expect(service).to have_received(:request_input)
    end
  end
end
