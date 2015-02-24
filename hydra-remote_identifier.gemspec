# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'hydra/remote_identifier/version'

Gem::Specification.new do |spec|
  spec.name          = "hydra-remote_identifier"
  spec.version       = Hydra::RemoteIdentifier::VERSION
  spec.authors       = ["Jeremy Friesen"]
  spec.email         = ["jeremy.n.friesen@gmail.com"]
  spec.description   = %q{Handles the registration and minting of remote identifiers (i.e. DOI, ARK, ORCID)}
  spec.summary       = %q{Handles the registration and minting of remote identifiers (i.e. DOI, ARK, ORCID)}
  spec.homepage      = "https://github.com/jeremyf/hydra-remote_identifier"
  spec.license       = "APACHE2"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'activesupport', '>= 3.2.13', '< 5.0'
  spec.add_dependency 'rest-client', '~> 1.7.3'

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency 'rspec', "~>2.14"
  spec.add_development_dependency 'rspec-its'
end
