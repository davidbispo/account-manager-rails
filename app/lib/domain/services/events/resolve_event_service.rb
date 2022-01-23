module Services
  module Events
    class ResolveEventService
      attr_reader :event_type, :execution_params

      def initialize(event_type:, request_params:)
        @event_type = event_type
        @execution_params = request_params.except(:event_type)
      end

      def resolve
        Strategies::Events::EventProcessorStrategy.descendants.each do |strategy|
          if strategy.should_run_for?(event_type)
            return strategy.new(execution_params).execute.response
          end
        end
        raise ArgumentError, 'Invalid event type for Event Processor Strategy Resolution'
      end
    end
  end
end