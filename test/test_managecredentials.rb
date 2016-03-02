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
        $stdout = StringIO.new
        ManageCredentials.start(['list_providers', '--remote'])
        expected = "Getting configured provider from api "
        expected << "http://localhost:4567/api...\n"
        expected << "200 - OK\n"
        expected << "[\"amazon \", \"digitalocean \"]".green
        expected << "\n"
        assert_equal(expected, $stdout.string)
    end

    def test_list_providers_from_file
        $stdout = StringIO.new
        ManageCredentials.start(['list_providers'])
        expected = "[\"amazon\", \"rackspace\"]".green
        expected << "\n"
        assert_equal(expected, $stdout.string)
    end

    def test_show_location
        $stdout = StringIO.new
        ManageCredentials.start(['show_location'])
        expected = "Current location http://localhost:4567/api".cyan
        expected << "\n"
        assert_equal(expected, $stdout.string)
    end

    def test_set_location
        f = File.new("deleteme.yml","w")
        f.puts("Api:\n  location: old")
        f.close
        ManageCredentials.conf = Conf.new("deleteme.yml")

        $stdout = StringIO.new
        ManageCredentials.start(['set_location','https://locationtest/api'])
        expected = "Location setted to https://locationtest/api".green
        expected << "\n"
        assert_equal(expected, $stdout.string)

        content = File.open("deleteme.yml", "rb").read
        expected_file_content = ""
        expected_file_content << "---\n"
        expected_file_content << "Api:\n"
        expected_file_content << "  location: https://locationtest/api\n"
        assert_equal(expected_file_content, content)
    ensure
        ManageCredentials.conf = Conf.new('test/server_mock/conf_test.yml')
        File.delete("deleteme.yml") if File.exist?("deleteme.yml")
    end

    def test_list_credentials_from_enterprise
        $stdout = StringIO.new
        ManageCredentials.start(['list','enterprise 1'])
        expected = "Searching for enterprise enterprise 1...\n"
        expected << "200 - OK\n"
        expected << "Retrieving credentials for enterprise enterprise 1...\n"
        expected << "200 - OK\n"
        expected << "[\"amazon\"]".green
        expected << "\n"
        assert_equal(expected, $stdout.string)
    end

    def test_printkeys
        f = File.new("deleteme.yml","w")
        content = "Api:\n"
        content << "  location: http://location/api\n"
        content << "amazon:\n"
        content << "  id: amazon-id\n"
        content << "  key: amazon-key"
        f.puts(content)
        f.close
        ManageCredentials.conf = Conf.new("deleteme.yml")

        $stdout = StringIO.new
        ManageCredentials.start(['printkeys', 'amazon'])
        expected = "id\n"
        expected << "amazon-id".cyan
        expected << "\nkey\n"
        expected << "amazon-key".cyan
        expected << "\n"
        assert_equal(expected, $stdout.string)
    ensure
        ManageCredentials.conf = Conf.new('test/server_mock/conf_test.yml')
        File.delete("deleteme.yml") if File.exist?("deleteme.yml")
    end

    def test_a_release
        $stdout = StringIO.new
        ManageCredentials.start(['release', 'amazon', 'enterprise 1'])
        expected = "Searching for enterprise enterprise 1...\n"
        expected << "200 - OK\n"
        expected << "Retrieving credentials for enterprise enterprise 1...\n"
        expected << "200 - OK\n"
        expected << "Deleting the credentials of the provider amazon from the enterprise enterprise 1\n"
        expected << "204 - No content\n\n"
        assert_equal(expected, $stdout.string)
    end
end
