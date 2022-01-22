module Strategies
  module Events
    class EventProcessorStrategy
      def resolve
        raise NotImplementedError
      end

      def response
        raise NotImplementedError
      end
    end
  end
end