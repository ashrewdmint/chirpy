require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "chirpy"
    gem.summary = "A simple Twitter client for Ruby, written using Hpricot and RestClient."
    gem.description = "Lets you easily interact with Twitter's API; post status updates, search Twitter, and more!"
    gem.email = "andrew.caleb.smith@gmail.com"
    gem.homepage = "http://github.com/ashrewdmint/chirpy"
    gem.authors = ["Andrew Smith"]
    
    # Dependencies
    
    gem.add_dependency('hpricot', '~> 0.8.1')
    gem.add_dependency('rest-client', '~> 0.9.2')
    gem.add_dependency('htmlentities', '~> 4.0.0')
  end

rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler"
end

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/*_test.rb'
  test.verbose = true
end

begin
  require 'rcov/rcovtask'
  Rcov::RcovTask.new do |test|
    test.libs << 'test'
    test.pattern = 'test/**/*_test.rb'
    test.verbose = true
  end
rescue LoadError
  task :rcov do
    abort "RCov is not available. In order to run rcov, you must: sudo gem install spicycode-rcov"
  end
end


task :default => :test

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  if File.exist?('VERSION.yml')
    config = YAML.load(File.read('VERSION.yml'))
    version = "#{config[:major]}.#{config[:minor]}.#{config[:patch]}"
  else
    version = ""
  end

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "chirpy #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

