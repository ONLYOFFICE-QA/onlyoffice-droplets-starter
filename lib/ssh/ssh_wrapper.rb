# frozen_string_literal: true

require 'English'
require_relative '../management'

# Class for interaction with net/ssh
# https://www.rubydoc.info/github/net-ssh/net-ssh/Net/SSH
class SshWrapper
  attr_reader :ssh

  # The standard means of starting a new SSH connection
  #
  # https://www.rubydoc.info/github/net-ssh/net-ssh/Net/SSH#start-class_method
  # @param [Object] host Remote host to connect to
  # @param [Object] user User to connect as
  # @param [Object] options Options to pass to the underlying SSH client
  # @param [Proc] block Block to execute on the new SSH connection
  # @return [Net::SSH::Connection::Session] Returns a new SSH connection
  def initialize(host, user, options, &block)
    @ssh = Net::SSH.start(host, user, options, &block)
  end

  # Execute a command on the remote host with log to stdout
  # @param [Net::SSH::Connection::Session] session The SSH connection to execute the command on
  # @param [String] command The command to execute
  # @return [Object] Returns the output of the command
  def exec_with_logs!(session, command)
    session.exec!(command) do |_ch, stream, data|
      $stdout << data if stream == :stdout
    end
  end

  # @param [Object] remote_path
  # @param [Object] host_path
  # @param [Object] user
  # @param [Object] ip
  #
  # @return [Object] recursion
  def sftp_get(remote_path, host_path, user, ip)
    system("echo \"get #{remote_path} #{host_path}\" | sftp #{user}@#{ip}")
    sleep 5 # Timeout between commands to not be banned by sftp
    sftp_get(remote_path, host_path, user, ip) unless $CHILD_STATUS.success?
  end

  # @param [Object] host_path
  # @param [Object] remote_path
  # @param [Object] user
  # @param [Object] ip
  #
  # @return [Object] recursion
  def sftp_put(host_path, remote_path, user, ip)
    system("echo \"put #{host_path} #{remote_path}\" | sftp #{user}@#{ip}")
    sleep 5 # Timeout between commands to not be banned by sftp
    sftp_put(host_path, remote_path, user, ip) unless $CHILD_STATUS.success?
  end

  # A method for strictly executing bash scripts via ssh, taking terminal type into account
  #
  # @option send_data 'export TERM=vt100n'
  # The value of the TERM environmental variable determines what terminal emulation will be used
  # to display characters to your screen.
  # For Macintoshes and IBM compatibles, "vt100" is usually the correct emulation. For Xterminals, use "xterm".
  #
  # @param [Net::SSH::Connection::Session] session The SSH connection to execute the command on
  # @param [String] script The script to execute
  # @param [String] shell Shell type (bash by default)
  # @return [Object] Returns the output of the command
  def exec_in_shell!(session, script, shell = 'bash')
    channel = session.open_channel do |ch|
      ch.exec("#{shell} -l") do |ch2, success|
        raise 'could not execute command' unless success

        # "on_data" is called when the process writes something to stdout
        ch2.on_data do |_c, data|
          $stdout.print data
        end
        # "on_extended_data" is called when the process writes something to stderr
        ch2.on_extended_data do |_c, _type, data|
          $stderr.print data
        end
        # Set the terminal type
        ch2.send_data("export TERM=vt100\n")
        # Output each command as if they were entered on the command line
        [script].flatten.each do |command|
          ch2.send_data "#{command}\n"
        end
        # Remember to exit or we'll hang!
        ch2.send_data "exit\n"
      end
    end
    channel.wait
  end
end
