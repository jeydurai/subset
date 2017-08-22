# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "subset/version"

Gem::Specification.new do |spec|
  spec.name          = "subset"
  spec.version       = Subset::VERSION
  spec.authors       = ["jeyaraj"]
  spec.email         = ["jeyaraj.durairaj@gmail.com"]

  spec.summary       = %q{Extract summarised data from booking_dump}
  spec.description   = %q{Specific to the needs, it subsets data from ent_dump_from_finance collection}
  spec.homepage      = "TODO: Put your gem's website or public repo URL here."
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  #if spec.respond_to?(:metadata)
    #spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"
  #else
    #raise "RubyGems 2.0 or newer is required to protect against " \
      #"public gem pushes."
  #end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.files = Dir.glob("{bin,lib}/**/*")
  spec.bindir        = "bin"
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.15"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "rubyXL", "~> 3.3", ">= 3.3.26"
  spec.add_development_dependency "roo", "~> 2.7", ">= 2.7.0"
  spec.add_development_dependency "mongo", "~> 2.4", ">= 2.4.1"
  spec.add_development_dependency "awesome_print", "~> 1.8", ">= 1.8.0"
end
