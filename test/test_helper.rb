require "simplecov"
SimpleCov.start

require_relative 'server_mock/api_mock.rb'

ms = ApiMockServer.new
puts "Starting mock server"
server_mock = Thread.new do
    ms.run
end
server_mock.abort_on_exception = true

while ms.started != true do
end
