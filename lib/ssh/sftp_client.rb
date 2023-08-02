# frozen_string_literal: true

require_relative '../management'

# Class for interaction with net/sftp
class SFTPClient
  attr_reader :sftp

  # The standard means of starting a new SFTP connection
  # @param [Object] host Remote host to connect to
  # @param [Object] user User to connect as
  # @param [Object] options Options to pass to the underlying SFTP client
  # @param [Proc] block Block to execute on the new SFTP connection
  # @return [Net::SFTP::Connection::Session] Returns a new SFTP connection
  def initialize(host, user, options, timeout: 200, &block)
    sleep_between_tries = 15
    (timeout / sleep_between_tries).times do |try|
      return @sftp = Net::SFTP.start(host, user, options, &block)
    rescue StandardError
      logger.info("SFTP connection refused on `#{host}` Waiting for #{try * sleep_between_tries} of #{timeout}")
      sleep sleep_between_tries
    end
    raise('SFTP connection failed')
  end

  # Uploads the file to the server
  # @param [Net::SFTP::Connection::Session] session The SFTP connection to execute the command on
  # @param [String] local Path to local file
  # @param [String] remote Path to remote file
  def upload_file(session, local, remote)
    session.upload!(local, remote)
  end

  # Get a list of files from a remote folder on the server
  # @param [Net::SFTP::Connection::Session] session The SFTP connection to execute the command on
  # @param [String] path_to_dir Path to folder
  # @return [Array] File names array
  def files_list_array(session, path_to_dir)
    name_array = []
    session.dir.foreach(path_to_dir) do |entry|
      name_array.append(entry.name)
    end
    name_array
  end

  # Download the file to the server
  # @param [Net::SFTP::Connection::Session] session The SFTP connection to execute the command on
  # @param [String] local Path to local file
  # @param [String] remote Path to remote file
  def download_file(session, remote, local)
    session.download!(remote, local)
  end
end
