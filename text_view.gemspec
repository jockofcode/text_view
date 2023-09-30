Gem::Specification.new do |spec|
  spec.name          = 'text_view'
  spec.version       = '0.1.0'
  spec.summary       = 'TextView: A Robust Text Rendering Library for Curses-based Applications'
  spec.description   = "TextView is a feature-rich text rendering library designed for building Curses-based applications with enhanced user interfaces. Whether you're building a text editor, terminal-based GUIs, or advanced CLI tools, TextView simplifies the process of creating and managing text windows, position handling, and real-time updates. With easy-to-use APIs and a modular design, TextView makes it effortless to integrate sophisticated text handling capabilities into your projects."
  spec.authors       = ['Branden Giacoletto']
  spec.email         = 'jockofcode@gmail.com'
  spec.files         = `git ls-files`.split("\n")
  spec.homepage      = 'https://github.com/jockofcode/text_view'
  spec.license       = 'MIT'
  spec.add_runtime_dependency 'curses', '~> 1.4'
  spec.add_development_dependency 'rspec', '~> 3.10'
end
