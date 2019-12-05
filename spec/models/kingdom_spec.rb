# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Kingdom do
  describe '#ask_for_allegiance' do
    let(:sender) { build(:kingdom) }
    let(:recipient) { build(:kingdom) }
    let(:message_compose_double) { instance_double(MessageCompose) }
    let(:message) { 'some composed message' }

    before do
      allow(MessageCompose).to receive(:new).with('ballot').and_return(message_compose_double)
      allow(message_compose_double).to receive(:compose).and_return(message)
      allow(recipient).to receive(:send_response).with(sender, message)
    end

    context 'when message is not given' do
      before { sender.ask_for_allegiance(recipient) }

      it 'composes new message' do
        expect(message_compose_double).to have_received(:compose)
      end

      it 'recipient responds to message' do
        expect(recipient).to have_received(:send_response).with(sender, message)
      end
    end

    context 'when message is provided' do
      before { sender.ask_for_allegiance(recipient, message) }

      it "doesn't composes new message" do
        expect(message_compose_double).to_not have_received(:compose)
      end

      it 'recipient responds to message with provided message' do
        expect(recipient).to have_received(:send_response).with(sender, message)
      end
    end
  end

  describe '#send_response' do
    let(:sender) { build(:kingdom) }
    let(:recipient) { build(:kingdom) }
    let(:correct_message) { "#{FFaker::Lorem.sentence}#{recipient.emblem.split('').sort_by { rand }.join}" }
    let(:incorrect_message) { FFaker::Lorem.sentence.delete(recipient.emblem.downcase[0]) }

    context 'when proposal accepted' do
      before do
        allow(recipient).to receive(:make_alliance_with).with(sender)
        sender.ask_for_allegiance(recipient, correct_message)
      end
      it 'makes alliance' do
        expect(recipient).to have_received(:make_alliance_with).with(sender)
      end
    end

    context 'when proposal declined' do
      let(:sovereign) { build(:kingdom) }
      before { GC.start }
      it 'rejects when wrong emblem' do
        sender.ask_for_allegiance(recipient, incorrect_message)
        expect(recipient.instance_variable_get(:@reject_reason)).to eq "You don't know our emblem?"
      end

      it 'rejects when wrong emblem' do
        recipient.ruler = true
        sender.ask_for_allegiance(recipient, correct_message)
        expect(recipient.instance_variable_get(:@reject_reason)).to eq 'How dare you to propose it to Ruler?!'
      end

      it 'rejects when wrong emblem' do
        recipient.sovereign = sovereign
        sender.ask_for_allegiance(recipient, correct_message)
        expect(recipient.instance_variable_get(:@reject_reason))
          .to eq "We are already commited to #{sovereign&.name}"
      end
    end
  end

  describe '#can_become_ruler?' do
    let(:ruler_vassals) { build_list(:kingdom, 3) }
    let!(:ruler) { build(:kingdom, ruler: true, vassals: ruler_vassals) }
    let(:kingdom_vassals) { build_list(:kingdom, 3) }
    let(:kingdom) { build(:kingdom, vassals: kingdom_vassals) }
    let(:stronger_vassals) { build_list(:kingdom, 4) }
    let(:strong_kingdom) { build(:kingdom, vassals: stronger_vassals) }

    it 'returns false if the kingdom is the ruler already' do
      expect(ruler.can_become_ruler?).to be_falsy
    end

    it "returns false if the ruler's vassals quantity is more or equal to kingdom's" do
      kingdom.can_become_ruler?
      expect(kingdom.can_become_ruler?).to be_falsy
    end

    it "returns true if the kingdom's vassals quantity is more than ruler's" do
      expect(strong_kingdom.can_become_ruler?).to be_truthy
    end
  end

  describe '#make_ruler' do
    let!(:ruler) { build(:kingdom, ruler: true) }
    let(:kingdom) { build(:kingdom) }

    before { kingdom.make_ruler }

    it 'former ruler became not ruler' do
      expect(ruler.ruler).to be_falsy
    end
    it 'the kingdom became new ruler' do
      expect(kingdom.ruler).to be_truthy
    end
  end

  describe '#proposal_accepted?' do
    let(:kingdom) { build(:kingdom) }
    let(:sovereign) { build(:kingdom) }
    let(:correct_message) { "#{FFaker::Lorem.sentence}#{kingdom.emblem.split('').sort_by { rand }.join}" }
    let(:incorrect_message) { FFaker::Lorem.sentence.delete(kingdom.emblem.downcase[0]) }

    context 'when all checks are passed' do
      it 'returns true' do
        expect(kingdom.send('proposal_accepted?', correct_message)).to eq true
      end
    end

    context "when message is not contains the recipient's emblem" do
      it 'returns false' do
        expect(kingdom.send('proposal_accepted?', incorrect_message)).to eq false
      end
      it 'updates reject reason' do
        kingdom.send('proposal_accepted?', incorrect_message)
        expect(kingdom.instance_variable_get(:@reject_reason)).to eq "You don't know our emblem?"
      end
    end

    context 'when recipient is the ruler' do
      before { kingdom.ruler = true }

      it 'returns false' do
        expect(kingdom.send('proposal_accepted?', correct_message)).to eq false
      end
      it 'updates reject reason' do
        kingdom.send('proposal_accepted?', correct_message)
        expect(kingdom.instance_variable_get(:@reject_reason)).to eq 'How dare you to propose it to Ruler?!'
      end
    end

    context 'when recipient already has a sovereign' do
      before { kingdom.sovereign = sovereign }

      it 'returns false' do
        expect(kingdom.send('proposal_accepted?', correct_message)).to eq false
      end
      it 'updates reject reason' do
        kingdom.send('proposal_accepted?', correct_message)
        expect(kingdom.instance_variable_get(:@reject_reason))
          .to eq "We are already commited to #{sovereign&.name}"
      end
    end
  end

  describe '#inappropriate_emblem?' do
    let(:recipient) { build(:kingdom) }
    let(:correct_message) { "#{FFaker::Lorem.sentence}#{recipient.emblem.split('').sort_by { rand }.join}" }
    let(:incorrect_message) { FFaker::Lorem.sentence.delete(recipient.emblem.downcase[0]) }

    it "returns true if message doesn't contain at least 1 letter from recipient's emblem" do
      expect(recipient.send('inappropriate_emblem?', incorrect_message)).to be_truthy
    end

    it "rerurns false if message contains recipient's emblem" do
      expect(recipient.send('inappropriate_emblem?', correct_message)).to be_falsy
    end
  end

  describe '.all' do
    let(:all_kingdoms) { build_list(:kingdom, 3) }
    before { GC.start }
    it 'returns all existed kingdoms' do
      expect(described_class.all.count).to eq all_kingdoms.count
    end
  end

  describe '.ruler' do
    context 'when ruler exists' do
      let!(:kingdom) { build(:kingdom, ruler: true) }
      it 'returns the ruler' do
        expect(described_class.ruler).to eq kingdom
      end
    end
    context 'when ruler absent' do
      before { described_class.reset }
      it 'returns nil' do
        expect(described_class.ruler).to eq nil
      end
    end
  end

  describe '.reset' do
    let(:vassals) { build_list(:kingdom, 3, sovereign: ruler) }
    let!(:ruler) { build(:kingdom, ruler: true) }
    before do
      ruler.vassals = vassals
      described_class.reset
    end

    it 'resets vassals for every kingdom' do
      expect(described_class.all.map(&:vassals).flatten.empty?).to be_truthy
    end
    it 'resets sovereign for every kingdom' do
      expect(described_class.all.map(&:sovereign).compact.empty?).to be_truthy
    end
    it 'resets ruler flag for every kingdom' do
      expect(described_class.all.map(&:ruler).uniq).to eq [false]
    end
  end

  describe '.resume' do
    let!(:ruler) { build(:kingdom, ruler: true) }
    let(:vassals) { build_list(:kingdom, 3, sovereign: ruler) }
    before { ruler.vassals = vassals }
    it 'returns info about current ruler' do
      expect(described_class.resume.include?("The Ruler is #{Kingdom.ruler.name.capitalize} Kingdom")).to be_truthy
    end
    it 'returns info about every kingdom' do
      result = described_class.all.map(&:name).map do |name|
        described_class.resume.join.include?("Kingdom #{name}")
      end.uniq
      expect(result).to eq [true]
    end
    it 'contains info about vassals' do
      string = %(has #{vassals.count} vassals: #{vassals.map(&:name).join(', ')}, has no sovereign)
      expect(described_class.resume.join.include?(string)).to be_truthy
    end
    it 'contains info about sovereigns' do
      expect(described_class.resume.join.include?("sovereign is #{ruler.name.capitalize} Kingdom")).to be_truthy
    end
  end

  describe '.find_or_create' do
    subject(:find_or_create) { described_class.find_or_create(name, emblem, king) }

    let(:name) { FFaker::Lorem.word }
    let(:emblem) { FFaker::Lorem.word }
    let(:king) { FFaker::Name.first_name_male }

    context 'when kingdom is absent' do
      it 'creates new kingdom' do
        expect { find_or_create }.to change { Kingdom.all.count }.by(1)
      end

      it 'returns new kingdom' do
        expect(find_or_create).to be_a(Kingdom)
      end
    end
    context 'when kingdom is present' do
      let!(:existed_kingdom) { build(:kingdom, name: name) }

      it "doesn't create new kingdom" do
        expect { find_or_create }.not_to change { Kingdom.all.count }
      end

      it 'returns found kingdom' do
        expect(find_or_create).to be existed_kingdom
      end
    end
  end
end
