require 'test/unit'
require 'fileutils'

class Test_list_repository < Test::Unit::TestCase

	#list repository list the repository content.
	def setup
		@src_dir = "spec/transport/fixtures"
	end

	#It's displayed as relative path to the repository
	def test_relative
		p = IO.popen("lib/transport/list_repository.rb #{@src_dir}", "r")
		assert_equal( p.readline.strip, "dot.png" )
	end

	#It's recurse on subdirectories
	def test_subdirs
		p = IO.popen("lib/transport/list_repository.rb #{@src_dir}", "r")
		assert p.find{|line| line.start_with? "subdir"}
	end

	#Files are sorted
	def test_sorted
		p = IO.popen("lib/transport/list_repository.rb #{@src_dir}", "r")
		assert p.each_cons(2).all? { |a, b| (a <=> b) <= 0 }
	end
end

