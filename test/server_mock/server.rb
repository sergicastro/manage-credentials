require 'socket'

class Server
    def initialize
        @rbyrs = []
    end

    def add_RbyR(rbyr)
        @rbyrs << rbyr
    end

    def read_request(socket)
        request = []
        while line = socket.gets
            request << line
            break if line =~ /^\s*$/
        end
        return request
    end

    def send_response(socket, rbyr)
        socket.print "HTTP/1.1 #{rbyr.rs_status} #{rbyr.rs_message}\r\n" \
            "Content-Type: #{rbyr.rs_contenttype}\r\n" \
            "Content-Length: #{rbyr.rs_body.bytesize}\r\n" \
            "Connection: close\r\n"
        socket.print "\r\n"
        socket.print rbyr.rs_body
    end

    def run
        server = TCPServer.new('localhost', 4567)

        loop do
            socket = server.accept
            request = read_request(socket)
            rbyr = @rbyrs.select {|r| r.match_request?(request)}[0]
            if rbyr.nil?
                raise Exception.new("No mock request found for: #{request} in #{@rbyrs}")
            end
            send_response(socket, rbyr)
            socket.close
        end
    end 
end

class RbyR
    attr_reader :rs_body
    attr_reader :rs_status
    attr_reader :rs_message
    attr_reader :rs_contenttype

    @rq_method
    @rq_path
    @rq_contenttype
    @rq_accepttype
    @rs_status
    @rs_message
    @rs_body
    @rs_contenttype

    def def_request(method, path, contenttype = '', accepttype = '')
        @rq_method = method
        @rq_path = path
        @rq_contenttype = contenttype
        @rq_accepttype =  accepttype
    end

    def def_response(status = '200', message = 'OK', body = '', contenttype = '')
        @rs_status = status
        @rs_message = message
        @rs_body = body
        @rs_contenttype = contenttype
    end

    def match_request? request
        method, path = request[0].match(/(\w{3,6}) (.*) HTTP\/1.1/i).captures
        contenttype = request.select {|line| line.start_with?("Content-Type:")}[0]
        accept = request.select {|line| line.start_with?("Accept:")}[0]

        path = path.match(/(http:\/\/.*:\d{3,4})?(\/.*)/).captures[1]
        if contenttype.nil?
            contenttype = @rq_contenttype
        end

        return @rq_method == method && @rq_path == path &&
            accept.include?(if @rq_accepttype.nil? then "" else @rq_accepttype end) &&
            contenttype.include?(if @rq_contenttype.nil? then "" else @rq_contenttype end)
    end
end
