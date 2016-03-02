require 'colorize'
require_relative 'api_client.rb'

class BusinessService
    def initialize(conf)
        @conf = conf
        @client = ApiClient.new(conf)
    end

    def add(provider, enterprise)
        raise Exception.new("Provider #{provider} not found in configuration file") if @conf.conf[provider].nil?

        key = @conf.conf[provider]['key']
        access = @conf.conf[provider]['id']
        link = @client.get_technology_link(provider)

        raise Exception.new("No link found for provider: #{provider}".colorize(:red)) if link.nil?
        puts "#{@client.post_credentials(key, access, enterprise, link)}".colorize(:green)
    end

    def list_providers(remote)
        puts "#{@client.get_providers(remote)}".colorize(:green)
    end

    def release(provider, enterprise)
        puts "#{@client.delete_credentials(provider, enterprise)}".colorize(:green)
    end

    def list(enterprise)
        puts "#{@client.list_credentials(enterprise)}".colorize(:green)
    end
    
    def print(provider)
        if provider != nil
            puts "id", "#{@conf.conf[provider]["id"]}".colorize(:cyan)
            puts "key", "#{@conf.conf[provider]["key"]}".colorize(:cyan)
        end
    end

    def set_location(new_location)
        @conf.put(['Api', 'location'], new_location)
        puts "Location setted to #{new_location}".colorize(:green)
    end
    
    def show_location
        puts "Current location #{@conf.location}".colorize(:cyan)
    end
end
