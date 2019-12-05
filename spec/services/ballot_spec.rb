# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Ballot do
  describe '#run' do
    let(:all_kingdoms) { build_list(:kingdom, 6) }
    let(:service) { described_class.new(all_kingdoms) }

    before { allow(service).to receive(:hold_ballot) }

    it 'holds ballot if can_finish_ballot? returns false' do
      allow(service).to receive(:can_finish_ballot?).and_return(false)
      service.run
      expect(service).to have_received(:hold_ballot).at_least(:once)
    end
    it "doesn't hold ballot if can_finish_ballot? returns true" do
      allow(service).to receive(:can_finish_ballot?).and_return(true)
      service.run
      expect(service).not_to have_received(:hold_ballot)
    end
    it 'returns Struct object' do
      expect(service.run.class.superclass).to be Struct
    end

    context 'when pretenders are present' do
      let!(:all_kingdoms) { build_list(:kingdom, 6) }
      let!(:pretenders) { all_kingdoms.first(2) }
      let!(:not_pretenders) { all_kingdoms.last(4) }
      let!(:report) { described_class.new(pretenders).run.report }

      it "not pretenders doesn't participate in ballot" do
        not_pretenders.each do |not_pretender|
          expect(report.join.include?("#{not_pretender.name} sends message to")).to be_falsy
        end
      end
    end
  end

  describe '#hold_ballot' do
    let(:all_kingdoms) { build_list(:kingdom, rand(2..10)) }
    let(:pretendents) { all_kingdoms.first(rand(2..all_kingdoms.count)) }
    let(:message) { build(:message, from: all_kingdoms.sample, to: all_kingdoms.sample) }
    let(:expected_message_count) { (pretendents.count * Kingdom.all.count) - pretendents.count }
    let(:new_service) { described_class.new(pretendents) }

    before do
      allow(Message).to receive(:new).and_return(message)
      allow(message).to receive(:send)
      new_service.send('hold_ballot')
    end

    it 'prepares messages to all existed kingdoms from every pretendent' do
      expect(Message).to have_received(:new).exactly(expected_message_count).times
    end
    it 'only 6 of messages will be selected to be sent' do
      expect(message).to have_received(:send).exactly(6).times
    end
    it 'resets Kingdoms' do
      allow(Kingdom).to receive(:reset)
      new_service.run
      expect(Kingdom).to have_received(:reset).at_least(:once)
    end
  end

  describe '#can_finish_ballot?' do
    let(:all_kingdoms) { build_list(:kingdom, 6) }
    let(:service) { described_class.new(all_kingdoms) }
    let(:report) { service.instance_variable_get(:@report) }
    let(:can_finish_ballot?) { service.send('can_finish_ballot?') }

    it 'gets resume from Kingdom class' do
      expect { can_finish_ballot? }.to change { report.include?(Kingdom.resume) }.from(false).to(true)
    end
    it 'returns false if ruler is absent' do
      expect(can_finish_ballot?).to eq false
    end
    context 'when only one leader' do
      let!(:first_leader) { build(:kingdom, vassals: all_kingdoms.first(3), ruler: true) }
      it 'returns true' do
        expect(can_finish_ballot?).to eq true
      end
    end
    context 'when few leaders' do
      let!(:first_leader) { build(:kingdom, vassals: all_kingdoms.first(3), ruler: true) }
      let!(:second_leader) { build(:kingdom, vassals: all_kingdoms.last(3)) }
      let(:service) { described_class.new([first_leader, second_leader]) }
      it 'returns false' do
        expect(can_finish_ballot?).to eq false
      end
      it 'returns message with reason of repeating ballot' do
        expect do
          can_finish_ballot?
        end.to change { report.include?('BALLOTS MUST BE REPEAT BETWEEN LEADERS') }.from(false).to(true)
      end
    end
  end
end
