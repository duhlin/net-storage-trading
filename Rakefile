require 'rake/extensiontask'
require 'rake/testtask'

#:build
["adler32", "nst_server"].each do |m|
  Rake::ExtensionTask.new( m ) do |t|
    t.lib_dir = "lib"
  end
end


#:test
Rake::TestTask.new do |t|
  t.test_files = Dir['spec/*.rb']
end

desc "Run tests"
task :default => [:compile, :test]
