# frozen_string_literal: true '

require 'net/ssh'
require 'logger'

def logger
  @logger = Logger.new($stdout)
end

def ssh(host, user, &block)
  @ssh ||= Net::SSH.start(host, user, &block)
end

# Describer
class RemoteControlHelper

  private

  # @param [Object] session
  # @param [String] line_number
  # @param [Object] desired
  # @param [Object] replaceable
  # @param [Object] file
  # @return [TrueClass]
  def sed(session, line_number = '', desired, replaceable, file)
    sed_script = "#{line_number}s,#{desired},#{replaceable},"
    response = session.exec! "sed -i #{sed_script} #{file}; echo done"
    logger.info "Sed #{file} is #{response.rstrip}"
  end

  # @param [Object] session
  # @param [Object] commands
  # @param [String] shell
  # @return [Object]
  def execute_in_shell!(session, commands, shell = 'bash')
    channel = session.open_channel do |ch|
      ch.exec("#{shell} -l") do |ch2, success|
        # Set the terminal type
        ch2.send_data 'export TERM=vt100n'
        # Output each command as if they were entered on the command line
        [commands].flatten.each do |command|
          ch2.send_data "#{command}n"
        end
        # Remember to exit or we'll hang!
        ch2.send_data 'exitn'
        @request_execute_in_shell = success
        # Configure to listen to ch2 data so you can grab stdout
      end
    end
    channel.wait
    @request_execute_in_shell
  end
end

  public

  # @param [Object] host
  # @param [Object] docserver_version
  # @return [Array, Net::SSH::Authentication]
  def configuration_project(host, docserver_version, spec)
    ssh(host, StaticData::DEFAULT_USER) do |ssh|
      matches = ssh.exec! 'git clone https://github.com/ONLYOFFICE-QA/convert-service-testing.git'
      logger.info matches.rstrip

      sed(ssh,'4', "\\\"\\\"", "\\\"#{StaticData.s3_public_key}\\\"",
          'convert-service-testing/Dockerfile')
      sed(ssh,'5', "\\\"\\\"", "\\\"#{StaticData.s3_private_key}\\\"",
          'convert-service-testing/Dockerfile')
      sed(ssh,'6', "\\\"\\\"", "\\\"#{StaticData.get_palladium_token}\\\"",
          'convert-service-testing/Dockerfile')
      sed(ssh,'7', "\\\"\\\"", "\\\"#{StaticData.get_jwt_key}\\\"",
          'convert-service-testing/Dockerfile')

      sed(ssh, 'latest', docserver_version, 'convert-service-testing/.env')
      sed(ssh, '\\\'\\\'', spec, 'convert-service-testing/.env')

      matches = ssh.exec! 'cd convert-service-testing/; docker-compose up -d'
      logger.info matches.rstrip

      ssh.close unless ssh.closed?
    end
  end

  # @param [Object] host
  # @param [Object] user
  # @param [Object] script
  def run_bash_script(host, user, script)
    ssh(host, user) do |ssh|
      request = execute_in_shell!(ssh, script)
      logger.info "Script installed? #{request}"
      ssh.close unless ssh.closed?
    end
  end
