require_relative '../lib/manage_credentials.rb'
require 'test/unit'
require 'stringio'
require 'colorize'

ManageCredentials.conf = Conf.new('test/server_mock/conf_test.yml')

class ManageCredentialsFailTest < Test::Unit::TestCase

    def test_403_list_credentials
        $stdout = StringIO.new
        begin
            ManageCredentials.start(['list','enterprise error'])
            assert_equal("Exception should be thrown", "Nothing")
        rescue Exception => ex
            assert_equal("API-00 - Unauthorized\n".red, ex.message)
            expected = "Current location http://localhost:4567/api".cyan
            expected << "\n"
            expected << "Searching for enterprise enterprise error...\n"
            expected << "200 - OK\n"
            expected << "Retrieving credentials for enterprise enterprise error...\n"
            expected << "403 - Forbidden\n"
            assert_equal(expected, $stdout.string)
        end
    end

    def test_403_list_credentials
        $stdout = StringIO.new
        begin
            ManageCredentials.start(['list','enterprise nobody'])
            assert_equal("Exception should be thrown", "Nothing")
        rescue Exception => ex
            assert_equal("", ex.message)
            expected = "Current location http://localhost:4567/api".cyan
            expected << "\n"
            expected << "Searching for enterprise enterprise nobody...\n"
            expected << "200 - OK\n"
            expected << "Retrieving credentials for enterprise enterprise nobody...\n"
            expected << "403 - Forbidden\n"
            assert_equal(expected, $stdout.string)
        end
    end

    def test_ent_not_found
        $stdout = StringIO.new
        begin
            ManageCredentials.start(['list', 'nonexistent'])
        rescue Exception => ex
            assert_equal("Enterprise nonexistent not found".red, ex.message)
            expected = "Current location http://localhost:4567/api".cyan
            expected << "\n"
            expected << "Searching for enterprise nonexistent...\n"
            expected << "200 - OK\n"
            assert_equal(expected, $stdout.string)
        end
    end
end
