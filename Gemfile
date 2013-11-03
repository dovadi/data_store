source 'https://rubygems.org'

gemspec

platforms :jruby do
  gem 'jdbc-mysql'
  gem 'jdbc-sqlite3'
  gem 'jdbc-postgres'
end

platforms :ruby do
  gem 'mysql2'
  gem 'sqlite3'
  gem 'pg'
end

group :test, :development do
  gem 'rake'
  gem 'shoulda'
  gem 'mocha', require: 'mocha/setup'
  gem 'guard'
  gem 'guard-test'
  gem 'rb-fsevent'
  gem 'pry'
  platforms :ruby do
    gem 'yard'
    gem 'redcarpet'
  end
end
