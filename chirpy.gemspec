# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{chirpy}
  s.version = "0.8.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Andrew Smith"]
  s.date = %q{2009-05-16}
  s.email = %q{andrew.caleb.smith@gmail.com}
  s.extra_rdoc_files = ["README.rdoc"]
  s.files = ["README.rdoc", "Rakefile", "lib/chirpy", "lib/chirpy/base.rb", "lib/chirpy/version.rb", "lib/chirpy.rb", "test/test_helper.rb", "test/unit", "test/unit/chirpy_test.rb"]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/ashrewdmint/chirpy}
  s.rdoc_options = ["--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{A simple API wrapper for Twitter}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<hpricot>, ["~> 0.8.1"])
      s.add_runtime_dependency(%q<rest-client>, ["~> 0.9.2"])
      s.add_runtime_dependency(%q<htmlentities>, ["~> 4.0.0"])
    else
      s.add_dependency(%q<hpricot>, ["~> 0.8.1"])
      s.add_dependency(%q<rest-client>, ["~> 0.9.2"])
      s.add_dependency(%q<htmlentities>, ["~> 4.0.0"])
    end
  else
    s.add_dependency(%q<hpricot>, ["~> 0.8.1"])
    s.add_dependency(%q<rest-client>, ["~> 0.9.2"])
    s.add_dependency(%q<htmlentities>, ["~> 4.0.0"])
  end
end
