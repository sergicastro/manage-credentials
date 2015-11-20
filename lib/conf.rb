require 'yaml'

class Conf
    def initialize
        @conf = YAML.load_file("#{ENV["HOME"]}/cloud_credentials.yml")
    end

    def conf
        @conf
    end

    def location
        @conf['Api']['location']
    end

    def user
        @conf['Api']['user']
    end

    def password
        @conf['Api']['password']
    end
end
