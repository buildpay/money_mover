module MoneyMover
  module Dwolla
    class Document < BaseModel
      attr_accessor :file, :documentType
      validates_presence_of :file, :documentType

      def to_params
        {
          documentType: documentType,
          file: Faraday::UploadIO.new(file, file.content_type)
        }
      end
    end
  end
end
