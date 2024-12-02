module FactoryBot
  class << self
    # An Array of strings specifying locations that should be searched for
    # factory definitions. By default, factory_bot will attempt to require
    # "factories", "test/factories" and "spec/factories". Only the first
    # existing file will be loaded.
    attr_accessor :definition_file_paths

    attr_accessor :lazy_load_definitions
  end

  self.definition_file_paths = %w[factories test/factories spec/factories]

  def self.find_definitions
    absolute_definition_file_paths = definition_file_paths.map { |path| File.expand_path(path) }

     @files_to_load = absolute_definition_file_paths.uniq.lazy.flat_map do |path|
      files = []
      files << "#{path}.rb" if File.exist?("#{path}.rb")

      if File.directory? path
        Dir[File.join(path, "**", "*.rb")].sort.each do |file|
          files << file
        end
      end

      files
    end

    load_all_definition_files unless lazy_load_definitions
  end

  # @api private
  def self.load_all_definition_files
    loop do
      break unless load_next_definition_file
    end
  end

  # @api private
  def self.load_next_definition_file
    load(@files_to_load.next)
    true
  rescue StopIteration
    false
  end
end
