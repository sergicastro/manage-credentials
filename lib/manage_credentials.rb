require 'thor'
require_relative 'conf.rb'
require_relative 'business_service.rb'


class ManageCredentials < Thor

    def self.conf=conf_instance
        @@conf = conf_instance
    end

    desc "add <provider> <enterprise>", "Adds the credentials for <provider> into the <enterprise>"
    def add(provider, enterprise)
        BusinessService.new(@@conf).add(provider, enterprise)
    end

    option :remote, :type => :boolean
    desc "list_providers [remote]", "Lists the config file providers. --remote option will list the remote ones"
    def list_providers
        BusinessService.new(@@conf).list_providers(options.remote)
    end

    desc "release <provider> <enterprise>", "Release the credentials for <provider> from the <enterprise>"
    def release(provider, enterprise)
        BusinessService.new(@@conf).release(provider, enterprise)
    end

    desc "list <enterprise>", "List the attached credientials of the <enterprise>"
    def list(enterprise)
        BusinessService.new(@@conf).list(enterprise)
    end

    desc "printkeys <provider>", "Print the provider keys"
    def printkeys(provider)
        BusinessService.new(@@conf).print(provider)
    end

    desc "set_location <new_location>", "Sets the new api location"
    def set_location(new_location)
        BusinessService.new(@@conf).set_location(new_location)
    end

    desc "show_location", "Shows the current api location"
    def show_location
        BusinessService.new(@@conf).show_location
    end
end
