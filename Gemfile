# frozen_string_literal: true

source 'https://rubygems.org'

gem 'rake'
gem 'net-ssh'
gem 'net-sftp'
gem 'onlyoffice_digitalocean_wrapper'

# ed25519 adding support for net-ssh ed25219 key type library
# bcrypt_pbkdf is used to encode\decode the received key
# https://bugzilla.redhat.com/show_bug.cgi?id=1747751
gem 'bcrypt_pbkdf', '>= 1.0', '< 2.0'
gem 'ed25519', '>= 1.2', '< 2.0'

group :development do
  gem 'rubocop', require: false
  gem 'rubocop-performance', require: false
end
