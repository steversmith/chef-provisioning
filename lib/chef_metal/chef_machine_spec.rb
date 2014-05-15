require 'chef_metal'
require 'cheffish'
require 'cheffish/cheffish_server_api'
require 'chef_metal/machine_spec'

module ChefMetal
  #
  # Specification for a machine. Sufficient information to find and contact it
  # after it has been set up.
  #
  class ChefMachineSpec < MachineSpec
    def initialize(node, chef_server)
      super(node)
      @chef_server = chef_server
    end

    #
    # Get a MachineSpec from the chef server.
    #
    def self.get(name, chef_server)
      if !chef_server
        raise "No chef server passed to ChefMachineSpec.get(name)"
      end
      chef_api = Cheffish::CheffishServerAPI.new(chef_server)
      ChefMachineSpec.new(chef_api.get("/nodes/#{name}"), chef_server)
    end

    #
    # Globally unique identifier for this machine. Does not depend on the machine's
    # location or existence.
    #
    def id
      ChefMachineSpec.id_from(chef_server, name)
    end

    def self.id_from(chef_server, name)
      "#{chef_server[:chef_server_url]}/nodes/#{name}"
    end

    #
    # Save this node to the server.  If you have significant information that
    # could be lost, you should do this as quickly as possible.  Data will be
    # saved automatically for you after allocate_machine and ready_machine.
    #
    def save(action_handler)
      # Save the node to the server.
      _self = self
      _chef_server = _self.chef_server
      ChefMetal.inline_resource(action_handler) do
        chef_node _self.name do
          chef_server _chef_server
          raw_json _self.node
        end
      end
    end

    protected

    attr_reader :chef_server

    #
    # Chef API object for the given Chef server
    #
    def chef_api
      Cheffish::CheffishServerAPI.new(chef_server)
    end
  end
end
