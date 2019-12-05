# frozen_string_literal: true

require 'spec_helper'

RSpec.describe MessageCompose do
  describe '#compose' do
    subject(:service) { described_class.new }

    it 'choosing file for parsing' do
      allow(service).to receive(:choose_file_for_parsing)
      service.compose
      expect(service).to have_received(:choose_file_for_parsing)
    end
    context 'when file is found' do
      let(:file) { "some \n fragment" }

      it 'returns sample of parsed file' do
        allow(File).to receive(:read).and_return(file)
        expect(file.include?(service.compose)).to be_truthy
      end
    end
    context 'when file is not found' do
      it 'returns nil' do
        allow(service).to receive(:choose_file_for_parsing).and_return(nil)
        expect(service.compose).to be nil
      end
    end
  end
end
