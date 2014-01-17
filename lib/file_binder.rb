require "pathname"
require "file_binder/version"

class FileBinder
  class << self
    attr_reader :pathname
    
    def inherited(binder)
      binder.instance_variable_set(:@recursive, false)
    end

    def bind(path)
      @pathname = Pathname.new(path)
      raise "missing destination file operand" unless @pathname.exist?
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

    def files
      entries.reject(&:directory?)
    end

    def directories
      entries.select(&:directory?)
    end

    def command(name, command)
      define_singleton_method name do
        command[entries]
      end
    end

    def entries
      glob_entries.reject do |entry|
        if !entry.directory? and @extensions
          next true if entry.to_s !~ /\.#{Regexp.union(@extensions.map(&:to_s))}$/
        end

        if @patterns
          next true if entry.to_s !~ /#{Regexp.union(@patterns)}/
        end
      end
    end

    def glob_entries
      if @recursive
        Pathname.glob("#{@pathname.realpath}/**/*")
      else
        Pathname.glob("#{@pathname.realpath}/*")
      end
    end
  end
end
