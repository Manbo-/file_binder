require "pathname"

require "yaml"
require "fileutils"
require 'forwardable'

require "file_binder/disk"
require "file_binder/cache"
require "file_binder/version"

class FileBinder
  class << self
    attr_reader :pathname

    extend Forwardable
    def_delegators :@storage, :read, :drop

    def inherited(binder)
      binder.instance_variable_set(:@recursive, false)
    end

    def bind(path)
      @pathname = Pathname.new(path)
      raise "missing destination file operand" unless @pathname.exist?
      @storage ||= Disk.new(@pathname)
    end

    def recursive(boolean)
      @recursive = !!boolean
    end

    def extensions(*extensions)
      @extensions = extensions
    end

    def pattern(*patterns)
      @patterns = patterns
    end

    def cache(pathname, filename = nil)
      if filename
        pathname = Pathname.new(pathname)
      else
        filename = pathname
        pathname = @pathname
      end
      @storage = Cache.new(pathname, filename)
    end

    def save
      @storage.save(entries)
    end

    def files
      entries.reject(&:directory?)
    end

    def directories
      entries.select(&:directory?)
    end

    def entries
      @entries ||= reload
    end

    def reload
      @entries = @storage.read(recursive: @recursive, extensions: @extensions, patterns: @patterns)
    end

    def command(name, command)
      define_singleton_method name do
        command[entries]
      end
    end
  end
end
