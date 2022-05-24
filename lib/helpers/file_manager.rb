# frozen_string_literal: true

require_relative '../management'

# class for interacting with files
class FileManager
  # The method overwrites a substring in the pattern
  # and writes a log and returns the result
  # @param [String] data
  # @param [Regexp] pattern
  # @param [String] changes
  # @return [String] data with changes
  def overwrite(data, pattern, changes)
    data = data.sub(pattern, changes.to_s)
    logger.info("overwriting #{pattern} with #{changes}")
    data
  end

  # Writes the tokens by reading the paths from the local machine
  # matching the found values in order
  #
  # The path array must be organized as:
  # An array, each element of which is a hash containing two values
  #
  # [{ dir: 'dir_relative_HOME', file: 'file name' }, ... , ...]
  #
  # If the number of matches does not equal the number of paths,
  # then the method will return the original data
  #
  # @param [String] data data to be written
  # @param [Regexp] pattern pattern to be replaced
  # @param [String] home global directory
  # @param [Array] arr_paths array of paths
  # @return [String] data with changes
  def writes_tokens_by_path_array(data, pattern, arr_paths, home = Dir.home)
    if data.scan(pattern).length == arr_paths.length
      arr_paths.each do |path|
        token = File.read("#{home}/#{path[:dir]}/#{path[:file]}").rstrip
        data = data.sub(pattern, wrap_in_double_quotes(token))
        logger.info("#{path[:file]} written")
      end
    end
    data
  end

  # @param [String] string string to be wrapped
  # @return [String (frozen)] string wrapped in double quotes
  def wrap_in_double_quotes(string)
    %("#{string}")
  end
end
