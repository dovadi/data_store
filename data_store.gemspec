# -*- encoding: utf-8 -*-
require File.expand_path('../lib/data_store/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ['Frank Oxener']
  gem.email         = ['frank.oxener@gmail.com']
  gem.description   = %q{DataStore is designed to store real time data but still manage the growth of your dataset and still keeping historical data}
  gem.summary       = %q{DataStore for storing real time data}
  gem.homepage      = 'https://github.com/dovadi/data_store'

  gem.licenses    = ['MIT']
  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = 'data_store'
  gem.require_paths = ['lib']
  gem.version       = DataStore::VERSION

  gem.add_dependency('sequel')
  gem.add_dependency('celluloid')

  if RUBY_PLATFORM == 'java'
    gem.add_dependency('jdbc-mysql')
    gem.add_dependency('jdbc-sqlite3')
    gem.add_dependency('jdbc-postgres')
  else
     gem.add_dependency('mysql2')
     gem.add_dependency('sqlite3')
     gem.add_dependency('pg')
  end

end
