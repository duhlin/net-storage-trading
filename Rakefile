require 'rake/extensiontask'
require 'rake/testtask'

BOOST_INC = ENV["BOOST_INCLUDE_DIR"]
BOOST_LIB = ENV["BOOST_LIB_DIR"]
STDERR.puts "Warning: environment variable BOOST_INCLUDE_DIR not set" unless BOOST_INC
STDERR.puts "Warning: environment variable BOOST_LIB_DIR not set" unless BOOST_LIB


#:build
["adler32", "nst_server"].each do |m|
  Rake::ExtensionTask.new( m ) do |t|
    t.lib_dir = "lib"
    t.config_options << "--with-boost-include=\"#{BOOST_INC}\"" if BOOST_INC
    t.config_options << "--with-boost-lib=\"#{BOOST_LIB}\"" if BOOST_LIB
  end
end


#:test
Rake::TestTask.new do |t|
  t.test_files = Dir['spec/**/*.rb']
end

desc "Run tests"
task :default => [:compile, :test]
