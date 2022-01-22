require 'rails_helper'

RSpec.describe Strategies::Events::TransferStrategy do
  describe ".ancestors" do
    it 'extends from EventProcessorStrategy' do
      expect(described_class.ancestors).to include(Strategies::Events::EventProcessorStrategy)
    end
  end
end