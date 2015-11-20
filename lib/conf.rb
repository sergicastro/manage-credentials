require 'yaml'

class Conf
    def initialize
        @file_path = "#{ENV["HOME"]}/cloud_credentials.yml"
        @conf = YAML.load_file(@file_path)
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

    def put(key, value)
        if not key.is_a?(Array) then key = [key] end
        @conf.each do |k,v|
            search_iterate(key, value, k, v, 0)
        end
        File.open(@file_path, "w") { |f| YAML.dump(@conf, f) }
    end

    private
    def search_iterate(key_to_match, value_to_set, k, v, i)
        if k == key_to_match[i]
            if not v.nil? and v.is_a?(Hash)
                v.each do |k1, v1|
                    if search_iterate(key_to_match, value_to_set, k1, v1, i+1)
                        v[k1] = value_to_set
                    end
                end
            else
                return true
            end
        end
    end
end
