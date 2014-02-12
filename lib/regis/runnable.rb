module Regis
  
  # Mixin that provides a state machine for running state.
  module Runnable

    def initialize
      _self = self
      @started_at = nil
      @stopped_at = nil
      @state_condition = ConditionVariable.new
      @mutex = Mutex.new
      @runnable_state = Statemachine.build do
        state :stopped do
          event :start!, :starting
          on_entry :enter_stopped
        end      
        state :starting do
          event :started!, :running
          event :failed!, :failed
          event :stop!, :stopping
          on_entry :enter_starting
        end
        state :running do
          event :stop!, :stopping
          event :starting!, :starting
          on_entry :enter_started
        end
        state :stopping do
          event :stopped!, :stopped
          on_entry :enter_stopping
        end
        state :failed do
          on_entry :enter_failed
        end
        context _self
      end
    end

    def start!
      if [:stopped, :failed].include?(@runnable_state.state)
        @runnable_state.start!
      end
    end

    def stop!
      if [:starting, :running].include?(@runnable_state.state)
        @runnable_state.stop!
      end
    end

    def run_state
      @runnable_state.state
    end

    def wait_for_state_change!
      @mutex.synchronize { @state_condition.wait(@mutex) }
    end

    attr_reader :started_at
    attr_reader :stopped_at

    protected

      attr_reader :runnable_state

      def on_starting
      end

      def on_started
      end

      def on_stopping
      end

      def on_stopped
      end

      def on_failed
      end

    private

      def signal_state_change!
        @mutex.synchronize { @state_condition.signal }
      end

      def enter_starting
        signal_state_change!
        on_starting
      end

      def enter_started
        signal_state_change!
        @stopped_at = nil
        @started_at = Time.now
        on_started
      end

      def enter_stopping
        signal_state_change!
        on_stopping
      end

      def enter_stopped
        signal_state_change!
        @stopped_at = Time.now
        @started_at = nil
        on_stopped
      end

      def enter_failed
        signal_state_change!
        on_failed
      end

  end

end