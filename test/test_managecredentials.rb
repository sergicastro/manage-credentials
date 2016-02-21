require_relative '../lib/manage_credentials.rb'
require_relative 'server_mock/api_mock.rb'
require 'test/unit'
require 'stringio'
require 'colorize'

ms = ApiMockServer.new
puts "Starting mock server"
server_mock = Thread.new do
    ms.run
end
server_mock.abort_on_exception = true

while ms.started != true do
end

ManageCredentials.conf = Conf.new('test/server_mock/conf_test.yml')

class ManageCredentialsTest < Test::Unit::TestCase

    def test_list_providers_remote
        foo = StringIO.new
        $stdout = foo
        ManageCredentials.start(['list_providers', '--remote'])
        expected = "Getting configured provider from api "
        expected << "http://localhost:4567/api...\n"
        expected << "200 - OK\n"
        expected << "[\"amazon \"]".green
        expected << "\n"
        assert_equal(expected, $stdout.string)
    end
end
