#
# Cookbook: consul
# License: Apache 2.0
#
# Copyright (C) 2014, 2015 Bloomberg Finance L.P.
#
require 'poise'

module ConsulCookbook
  module Resource
    # @since 1.0.0
    class ConsulWatch < Chef::Resource
      include Poise(fused: true)
      provides(:consul_watch)
      default_action(:create)

      # @!attribute path
      # @return [String]
      attribute(:path, kind_of: String, default: lazy { "/etc/consul/#{name}.json" })

      # @!attribute user
      # @return [String]
      attribute(:user, kind_of: String, default: 'consul')

      # @!attribute group
      # @return [String]
      attribute(:group, kind_of: String, default: 'consul')

      # @!attribute type
      # @return [String]
      attribute(:type, equal_to: %w{checks event key keyprefix nodes service services})

      # @!attribute parameters
      # @return [Hash]
      attribute(:parameters, option_collector: true, default: {})

      def to_json
        JSON.pretty_generate(watches: [{ type: type }.merge(parameters)])
      end

      action(:create) do
        notifying_block do
          directory ::File.dirname(new_resource.path) do
            recursive true
            owner new_resource.user
            group new_resource.group
            mode '0755'
          end

          file new_resource.path do
            owner new_resource.user
            group new_resource.group
            content new_resource.to_json
            mode '0640'
          end
        end
      end

      action(:delete) do
        notifying_block do
          file new_resource.path do
            action :delete
          end
        end
      end
    end
  end
end
