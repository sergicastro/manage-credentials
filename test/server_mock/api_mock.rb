require 'json'
require_relative './server.rb'

class ApiMockServer
    attr_reader :started
    
    def initialize
        @started = nil
    end

    def run
        server = Server.new

        server.add_RbyR(hypervisortypes)
        server.add_RbyR(enterprises)
        server.add_RbyR(credentials)
        server.add_RbyR(credentials_delete)
        server.add_RbyR(credentials_post)

        @started=true
        server.run
    end

    def hypervisortypes
        rbyr = RbyR.new
        rbyr.def_request('GET', '/api/config/hypervisortypes', '',
                         'application/vnd.abiquo.hypervisortypes+json')
        collection = []
        collection << {:name => "amazon", :links => [{:rel => "self", href: "/api/confg/hypervisortpyes/amazon"}]}
        collection << {:name => "digitalocean", :links => [{:rel => "self", href: "/api/confg/hypervisortpyes/digitalocean"}]}
        types = {:collection => collection}
        dto = JSON.generate(types)
        rbyr.def_response('200','OK', dto, 'application/vnd.abiquo.hypervisortypes+json')
        return rbyr
    end

    def enterprises
        rbyr = RbyR.new
        rbyr.def_request('GET', '/api/admin/enterprises', '',
                        'application/vnd.abiquo.enterprises+json')
        collection = []
        collection << {:name => "enterprise 1", :id => 1}
        collection << {:name => "enterprise 2", :id => 2}
        rbyr.def_response('200', 'OK', JSON.generate({:collection => collection}),
                         'appliaction/vnd.abiquo.enterprises+json')
        return rbyr
    end

    def credentials
        rbyr = RbyR.new
        rbyr.def_request('GET', '/api/admin/enterprises/1/credentials', '',
                        'application/vnd.abiquo.publiccloudcredentialslist+json')
        creds = []
        creds << {links: [{rel: "hypervisortype", title: "amazon"}, {rel: "edit", href: "/api/admin/enterprises/1/credentials/1"}]}
        creds << {links: [{rel: "hypervisortype", title: "digitalocean"}, {rel: "edit", href: "/api/admin/enterprises/1/credentials/2"}]}
        rbyr.def_response('200', 'OK', JSON.generate({:collection => creds}),
                         'application/vnd.aiquo.publiccloudcredentials+json')
        return rbyr
    end

    def credentials_delete
        rbyr = RbyR.new
        rbyr.def_request('DELETE', '/api/admin/enterprises/1/credentials/1', '', '')
        rbyr.def_response('204', 'No content', '', '')
        return rbyr
    end

    def credentials_post
        rbyr = RbyR.new
        rbyr.def_request('POST', '/api/admin/enterprises/1/credentials',
                         # 'application/vnd.abiquo.publiccloudcredentialjson',
                         '',
                         'application/vnd.abiquo.publiccloudcredentials+json')
        cred = {name: "amazon"}
        rbyr.def_response('201', 'Created', JSON.generate(cred),
                         'application/vnd.abiquo.publiccloudcredentialslist+json')
        return rbyr
    end
end
