require 'net/https'
require 'json'

class ApiClient
    def initialize(conf)
        @conf = conf
    end

    # Retrieves the technology (rel=hypervisor) link from the api
    # Params:
    #   +provider+:: the provisor (hypervisor) link to retrieve
    def get_technology_link(provider)
        request = Net::HTTP::Get.new("#{@conf.location}/config/hypervisortypes")
        request.add_field('accept','application/vnd.abiquo.hypervisortypes+json')
        puts "Searching for provider #{provider}..."
        response = send_request(request)
        provider_type = JSON.parse(response.body)["collection"].select{ |x| x["name"] == provider }[0]
        link = provider_type["links"].select{ |link| link["rel"] == "self" }[0]
        link['rel'] = 'hypervisortype'
        link
    end

    # Sets the creadentials to the enterprise
    # Params:
    #   +key+:: credentials key
    #   +access+:: credentials access
    #   +enterprise+:: enterprise where set the credentials
    #   +link+:: the provider link where the credentials belong
    def post_credentials(key, access, enterprise, link)
        ent_id = get_enterprise_id(enterprise)
        request = Net::HTTP::Post.new("#{@conf.location}/admin/enterprises/#{ent_id}/credentials")
        request.add_field('content-type', 'application/vnd.abiquo.publiccloudcredentials+json')
        request.add_field('accept', 'application/vnd.abiquo.publiccloudcredentials+json')
        request.body = "{ \"links\": [#{link.to_json}], "
        request.body << "\"key\": \"#{key}\", \"access\": \"#{access}\"}"
        puts "Posting credentials into enterprise #{enterprise}..."
        send_request(request).body
    end

    # Retrieves the credentials of an enterprise
    # Params:
    #   +enterprise+:: where retireve the credentials
    def get_credentials(enterprise)
        ent_id = get_enterprise_id(enterprise)
        request = Net::HTTP::Get.new("#{@conf.location}/admin/enterprises/#{ent_id}/credentials")
        request.add_field('accept', 'application/vnd.abiquo.publiccloudcredentialslist+json')
        puts "Retrieving credentials for enterprise #{enterprise}..."
        send_request(request).body
    end

    # Remove the credentials of a provider from an enterprise
    # Params:
    #   +provider+:: provider of the credentials to remove
    #   +ent_id+:: identifier of the enterprise which remove the credentials
    def delete_credentials(provider, enterprise)
        credentials = get_credentials(enterprise)
        coll = JSON.parse(credentials)["collection"]
        links = coll.collect{ |x| x["links"] }
        creds = links[0].select{ |link| link["rel"] == "edit" }[0]
        raise Exception.new("No credentials found for enterprise #{enterprise} and provider #{provider}".colorize(:red)) if creds.empty?
        puts "Deleting the credentials of the provider #{provider} from the enterprise #{enterprise}"
        send_request(Net::HTTP::Delete.new(creds["href"])).body
    end

    # Returns the provider names of the credentials attached to the given enterprise
    # Params:
    #   +enterprise+:: where get the credentials
    def list_credentials(enterprise)
        links = JSON.parse(get_credentials(enterprise))["collection"].collect{ |cred| cred["links"] }.zip
        match = links[0][0].select{ |link| link["rel"] == "hypervisortype" }
        match.collect{ |link| link["title"] }
    end


    # Send the request
    # Params:
    #   +request+:: the request to send
    def send_request(request)
        uri = URI.parse(@conf.location)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        request.basic_auth(@conf.user, @conf.password)
        response = http.request(request)
        puts "#{response.code} - #{response.message}"
        if not response.code =~ /2\d\d/
            if not response.body.nil? and not response.body.empty?
                json = JSON.parse(response.body)
                puts json
                codes = json["collection"].collect{ |x| x["code"] }
                messages = json["collection"].collect{ |x| x["messages"] }
                ex_message = ""
                codes.zip(messages).each do |code, message|
                    ex_message << "#{code} - #{message}\n"
                end
            else
                ex_message=""
            end
            raise Exception.new(ex_message.colorize(:red))
        end
        response
    end

    # Retrieves the list of all providers available to use.
    # Params:
    #   +remote+:: if <true> performs an api call and return all api configured providers,
    #              else returns all providers from config file.
    def get_providers(remote)
        if remote
            request = Net::HTTP::Get.new("#{@conf.location}/config/hypervisortypes")
            request.add_field('accept','application/vnd.abiquo.hypervisortypes+json')
            puts "Getting configured provider from api #{@conf.location}..."
            response = send_request(request)
            providers = JSON.parse(response.body)["collection"].collect{ |prov| "#{prov["name"]} #{prov["realName"]}" }
        else
            providers = @conf.conf.keys
            providers.delete('Api')
        end
        providers.sort
    end

    # Given an enterprise name returns the enterprise id
    # Params:
    #   +enterprise_name+:: The name of the enterprise where get the id
    def get_enterprise_id(enterprise_name)
        request = Net::HTTP::Get.new("#{@conf.location}/admin/enterprises")
        request.add_field('accept', 'application/vnd.abiquo.enterprises+json')
        puts "Searching for enterprise #{enterprise_name}..."
        response = send_request(request)
        ids = JSON.parse(response.body)["collection"].select{ |x| x["name"] == enterprise_name }.collect{ |x| x["id"] }
        enterprise_id = if ids.empty? then nil else ids[0] end
        raise Exception.new("Enterprise #{enterprise_name} not found".colorize(:red)) if enterprise_id.nil?
        enterprise_id
    end
    
end
