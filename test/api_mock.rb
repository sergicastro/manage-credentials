require 'json'
require_relative './server.rb'

class ApiMockServer
    attr_reader :started
    
    def initialize
        @started = nil
    end

    def run
        server = Server.new

        rbyr = RbyR.new
        rbyr.def_request('GET', '/api/config/hypervisortypes', '',
                         'application/vnd.abiquo.hypervisortypes+json')
        collection = []
        collection << {:name => "amazon"}
        types = {:collection => collection}
        dto = JSON.generate(types)
        rbyr.def_response('200','OK', dto, 'application/vnd.abiquo.hypervisortypes+json')

        server.add_RbyR(rbyr)

        @started=true
        server.run
    end
end
