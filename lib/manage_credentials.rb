require 'thor'
require_relative 'conf.rb'
require_relative 'business_service.rb'

class ManageCredentials < Thor

    desc "add <provider> <enterprise>", "Adds the credentials for <provider> into the <enterprise>"
    def add(provider, enterprise)
        BusinessService.new(Conf.new).add(provider, enterprise)
    end

    option :remote, :type => :boolean
    desc "list_providers [remote]", "Lists the config file providers. --remote option will list the remote ones"
    def list_providers
        BusinessService.new(Conf.new).list_providers(options.remote)
    end

    desc "release <provider> <enterprise>", "Release the credentials for <provider> from the <enterprise>"
    def release(provider, enterprise)
        BusinessService.new(Conf.new).release(provider, enterprise)
    end

    desc "list <enterprise>", "List the attached credientials of the <enterprise>"
    def list(enterprise)
        BusinessService.new(Conf.new).list(enterprise)
    end

    desc "printkeys <provider>", "Print the provider keys"
    def printkeys(provider)
        BusinessService.new(Conf.new).print(provider)
    end
end
