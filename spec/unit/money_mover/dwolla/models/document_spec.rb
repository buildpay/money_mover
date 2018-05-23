require 'spec_helper'

describe MoneyMover::Dwolla::Document do
  let(:file_content_type) { double 'file content type' }
  let(:file) { double 'file', content_type: file_content_type }
  let(:documentType) { double 'document type' }

  let(:attrs) do
    {
      file: file,
      documentType: documentType
    }
  end

  subject { described_class.new attrs }

  it { should validate_presence_of(:file) }
  it { should validate_presence_of(:documentType) }

  describe '#to_params' do
    let(:file_upload_io) { double 'file upload io' }
    before do
      allow(Faraday::UploadIO).to receive(:new).with(file, file_content_type) { file_upload_io }
    end

    it 'returns expected values' do
      expect(subject.to_params).to eq({
        documentType: documentType,
        file: file_upload_io
      })
    end
  end
end
