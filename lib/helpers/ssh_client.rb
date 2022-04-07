# frozen_string_literal: true

require_relative '../management'

# Class for interaction with net/ssh
# https://www.rubydoc.info/github/net-ssh/net-ssh/Net/SSH
class SshClient
  # Initializing ssh connection method
  # @param [String] host remote server host
  # @param [String] user user on whose behalf the access will be granted
  # @param [Object] options The options are described in the module documentation
  # @param [Proc] block Instructions for interacting with an ssh connection.
  #                     The connection is closed when the block is executed.
  # @return [Array, Net::SSH::Authentication] https://www.rubydoc.info/github/net-ssh/net-ssh/Net/SSH/Authentication
  def connect(host, user, options, &block)
    Net::SSH.start(host, user, options, &block)
  end

  class << self
    # Method for running bash scripts
    # @param [Net::SSH::Connection::Session] session Open session access object (see doc)
    # @param [String] path_to_script Path to string
    # @return [TrueClass] After the script transfer is complete, it returns true or false
    def run(session, path_to_script)
      request = execute_in_shell!(session, File.read(path_to_script.to_s))
      if request
        logger.info "#{File.basename(path_to_script.to_s)} installed"
      else
        logger.error "#{File.basename(path_to_script.to_s)} is not installed"
      end
      request
    end

    private

    # A method for strictly executing bash scripts via ssh, taking terminal type into account
    #
    # @option send_data 'export TERM=vt100n'
    # The value of the TERM environmental variable determines what terminal emulation will be used
    # to display characters to your screen.
    # For Macintoshes and IBM compatibles, "vt100" is usually the correct emulation. For Xterminals, use "xterm".
    #
    # @param [Net::SSH::Connection::Session] session Open session access object (see doc)
    # @param [String] script The line containing the shell script
    # @param [String] shell Shell type (bash by default)
    # @return [TrueClass] After the script transfer is complete, it returns true or false
    def execute_in_shell!(session, script, shell = 'bash')
      channel = session.open_channel do |ch|
        ch.exec("#{shell} -l") do |ch2, success|
          raise 'could not execute command' unless success
          # Set the terminal type
          ch2.send_data 'export TERM=vt100n'
          # Output each command as if they were entered on the command line
          [script].flatten.each do |command|
            ch2.send_data "#{command}n"
          end
          # Remember to exit or we'll hang!
          ch2.send_data 'exitn'
          # Configure to listen to ch2 data so you can grab stdout
        end
      end
      channel.wait
    end
  end
end
