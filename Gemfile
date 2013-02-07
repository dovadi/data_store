source 'https://rubygems.org'

# Specify your gem's dependencies in data_store.gemspec
gemspec

gem 'rake'
gem 'sequel'

platforms :jruby do
  gem 'jdbc-mysql'
  gem 'jdbc-sqlite3'
  gem 'jdbc-postgres', '9.1.901' #9.2 throws an error NameError: missing class or uppercase package name (`org.postgresql.Driver')
end

platforms :ruby do
  gem 'mysql2'
  gem 'sqlite3'
  gem 'pg'
end

gem 'celluloid'

group :test, :development do
  gem 'shoulda'
  gem 'mocha'
  gem 'guard'
  gem 'guard-test'
  gem 'rb-fsevent'
  gem 'pry'
  platforms :ruby do
    gem 'yard'
    gem 'redcarpet'
  end
end
