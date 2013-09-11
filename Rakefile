require 'rake/extensiontask'
require 'rake/testtask'

#:build
Rake::ExtensionTask.new "adler32" do |t|
  t.lib_dir = "lib"
end

#:test
Rake::TestTask.new do |t|
  t.test_files = Dir['spec/*.rb']
end

desc "Run tests"
task :default => [:compile, :test]
