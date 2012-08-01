Gem::Specification.new do |s|
	s.name             = "libdvdread"
	s.version          = "0.0.0"
	s.authors          = ["Szabolcs Seláf"]
	s.email            = ["selu@selu.org"]
	s.homepage         = "http://github.com/selu/libdvdread"
	s.summary          = %q{Ruby bindings for libdvdread using FFI}

	s.files            = `git ls-files`.split("\n")
	s.test_files       = `git ls-files -- {test,spec,features}/*`.split("\n")
	s.executables      = `git ls-files -- bin/*`.split("\n").map{|f| File.basename(f)}
	s.require_paths    = ["lib"]

	s.add_runtime_dependency 'ffi', '~> 1.1.2'

	s.add_development_dependency 'yard'
end
