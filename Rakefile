require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "solver"
    gem.summary = %Q{Numeric solver to exercise the Flt library}
    gem.description = %Q{This numeric solver is an example of the use of Flt}
    gem.email = "jgoizueta@gmail.com"
    gem.homepage = "http://github.com/jgoizueta/solver"
    gem.authors = ["Javier Goizueta"]
    gem.add_development_dependency "shoulda-context"
    gem.add_development_dependency "minitest"
    gem.add_dependency "flt", ">= 1.3.0"
    gem.required_ruby_version = '> 1.9.1'
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

begin
  require 'rcov/rcovtask'
  Rcov::RcovTask.new do |test|
    test.libs << 'test'
    test.pattern = 'test/**/test_*.rb'
    test.verbose = true
  end
rescue LoadError
  task :rcov do
    abort "RCov is not available. In order to run rcov, you must: sudo gem install spicycode-rcov"
  end
end

task :test => :check_dependencies

task :default => :test

require 'rdoc/task'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.main = 'README.rdoc'
  rdoc.title = "solver #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
