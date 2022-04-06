# frozen_string_literal: true

# Describe
class SshClient
  # @param [Object] host
  # @param [Object] user
  # @param [Object] options
  # @param [Proc] block
  # @return [Array, Net::SSH::Authentication]
  def connect(host, user, options, &block)
    Net::SSH.start(host, user, options, &block)
  end

  class << self
    # @param [Object] session
    # @param [Object] path_to_script
    # @return [TrueClass]
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

    # @param [Object] session
    # @param [Object] script
    # @param [String] shell
    # @return [Object]
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
