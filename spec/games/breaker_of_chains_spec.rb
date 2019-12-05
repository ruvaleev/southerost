# frozen_string_literal: true

require 'spec_helper'

RSpec.describe BreakerOfChains do
  describe 'run' do
    subject(:service) { described_class.new }

    let(:ballot_double) { instance_double(Ballot) }
    let(:result_double) { instance_double(Struct.new(:ruler, :report)) }
    let(:breaker_of_chains_double) { instance_double(described_class) }

    before do
      allow(service).to receive(:gets).and_return('')
      allow(Ballot).to receive(:new).and_return(ballot_double)
      allow(ballot_double).to receive(:run).and_return(result_double)
      allow(result_double).to receive(:report)
      service.run
    end

    it 'initializes kingdoms' do
      expect(Kingdom.all.count).to eq GREAT_HOUSES.count
    end

    it 'establish min_vassals_count_for_became_ruler to 0' do
      expect(Kingdom.class_variable_get('@@min_vassals_count_for_became_ruler')).to eq 0
    end

    it 'asks for input kingdoms' do
      expect(service).to have_received(:gets)
    end
    it 'runs Ballot service' do
      expect(ballot_double).to have_received(:run)
    end
    it 'returns Ballot service' do
      expect(result_double).to have_received(:report)
    end
  end
end
