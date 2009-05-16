require 'rubygems'
require 'rake/gempackagetask'
require 'rake/testtask'

require 'lib/chirpy/version'

task :default => :test

spec = Gem::Specification.new do |s|
  s.name             = 'chirpy'
  s.version          = Chirpy::Version.to_s
  s.has_rdoc         = true
  s.extra_rdoc_files = %w(README.rdoc)
  s.rdoc_options     = %w(--main README.rdoc)
  s.summary          = "A simple API wrapper for Twitter"
  s.author           = 'Andrew Smith'
  s.email            = 'andrew.caleb.smith@gmail.com'
  s.homepage         = 'http://github.com/ashrewdmint/chirpy'
  s.files            = %w(README.rdoc Rakefile) + Dir.glob("{lib,test}/**/*")
  # s.executables    = ['chirpy']
  
  s.add_dependency('hpricot', '~> 0.8.1')
  s.add_dependency('rest-client', '~> 0.9.2')
  s.add_dependency('htmlentities', '~> 4.0.0')
end

Rake::GemPackageTask.new(spec) do |pkg|
  pkg.gem_spec = spec
end

Rake::TestTask.new do |t|
  t.libs << 'test'
  t.test_files = FileList["test/**/*_test.rb"]
  t.verbose = true
end

desc 'Generate the gemspec to serve this Gem from Github'
task :github do
  file = File.dirname(__FILE__) + "/#{spec.name}.gemspec"
  File.open(file, 'w') {|f| f << spec.to_ruby }
  puts "Created gemspec: #{file}"
end