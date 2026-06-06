# frozen_string_literal: true

module Pal
  module Commands
    module CommandHelpers
      def guild_key(event)
        if event.respond_to?(:server) && event.server
          event.server.id
        else
          event.channel.id
        end
      end

      def option_value(event, name)
        return nil unless event.respond_to?(:options)

        option = event.options[name] || event.options[name.to_sym]
        option.respond_to?(:value) ? option.value : option
      end
    end
  end
end
