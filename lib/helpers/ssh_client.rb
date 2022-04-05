# frozen_string_literal: true

require 'net/ssh'
require 'net/sftp'
require 'stringio'

# Describe
class SshClient

  # @param [Object] host
  # @param [Object] user
  # @param [Object] options
  # @param [Proc] block
  #
  # @return [Array, Net::SSH::Authentication]
  def connect(host, user, options, &block)
    Net::SSH.start(host, user, options, &block)
  end
end
