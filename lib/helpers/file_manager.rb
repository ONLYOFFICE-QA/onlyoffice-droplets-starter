# frozen_string_literal: true

require_relative '../management'

# class for interacting with files
class FileManager
  # Methods to overwrite string
  #
  # If changes is a [String] then the first match in the pattern is found and overwritten
  #
  # However, if there is an [Array], then the number of matches
  # found in the data is calculated and compared to the number
  # of elements in the array
  #
  # @param [String] data - data to overwrite
  # @param [Regexp] pattern - pattern to overwrite
  # @param [String, Array[String]] changes - changes to overwrite
  # @return [String] data with changes
  def overwrite(data, pattern, changes)
    case changes
    when String
      data = data.sub(pattern, "\"#{changes}\"")
      logger.info("overwriting #{pattern} with #{changes}")
    when Array
      if data.scan(pattern).length == changes.length
        changes.each do |path|
          data = data.sub(pattern, "\"#{File.read("#{Dir.home}/#{path[:dir]}/#{path[:file]}").rstrip}\"")
          logger.info("#{path[:file]} is written")
        end
      end
    else
      raise 'Changes data type is not supported by the method'
    end
    data
  end
end
