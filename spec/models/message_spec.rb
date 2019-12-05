# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Message do
  let(:message) { build(:message) }
  let(:sender_double) { instance_double(Kingdom) }

  describe '#send' do
    before do
      allow(message).to receive(:from).and_return(sender_double)
      allow(sender_double).to receive(:ask_for_allegiance)
    end

    it "calls sender's 'ask_for_allegiance' with approprate body and sender" do
      message.send
      expect(message.from).to have_received(:ask_for_allegiance)
        .with(message.to, message.body)
    end
  end
end
