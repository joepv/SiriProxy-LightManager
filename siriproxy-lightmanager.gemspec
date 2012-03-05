# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name        = "siriproxy-lightmanager"
  s.version     = "0.9.0" 
  s.authors     = ["Joep Verhaeg"]
  s.email       = ["info@joepverhaeg.nl"]
  s.homepage    = "http://www.joepverhaeg.nl"
  s.summary     = %q{Lightmanager Siri Proxy Plugin}
  s.description = %q{Custom plugin for my home light scenes and to get experience with Ruby/SiriProxy. }

  s.rubyforge_project = "siriproxy-lightmanager"

  s.files         = `git ls-files 2> /dev/null`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/* 2> /dev/null`.split("\n")
  s.executables   = `git ls-files -- bin/* 2> /dev/null`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  # s.add_runtime_dependency "rest-client"
end
