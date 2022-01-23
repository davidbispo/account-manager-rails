module Strategies
  module Events
    class EventProcessorStrategy
      def execute
        raise NotImplementedError
      end

      def response
        raise NotImplementedError
      end
    end
  end
end