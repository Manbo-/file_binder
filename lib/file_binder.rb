require "listen"
require "pathname"
require "forwardable"

require "file_binder/listen"
require "file_binder/extensions"
require "file_binder/version"

class FileBinder
  class << self
    attr_reader :pathname, :listener

    def bind(path)
      @pathname = Pathname.new(path).realpath
      raise "missing destination file operand" unless @pathname.exist?
    end

    def recursive(boolean)
      @recursive = !!boolean
    end

    def extensions(*extensions)
      @extensions = extensions
    end

    def listen(opts = {}, &callback)
      @listener = Listener.new(@pathname, opts, &callback)
    end

    Listener::CALLBACKS.each do |name|
      define_method "#{name}_on" do |&callback|
        @listener ||= Listener.new(@pathname)
        @listener.send("#{name}_on", callback)
      end
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
      raise "oh my god '#{name}'" if bad_singleton_method_name?(name)
      define_singleton_method name do
        command[entries]
      end
    end

    def entries
      @entries ||= reload
    end

    def reload
      path = @pathname.realpath.to_s + (@recursive ? "/**/*" : "/*")
      @entries = Pathname.glob(path).reject do |entry|
        if @extensions and !entry.directory?
          next true if entry.to_s !~ /\.#{Regexp.union(@extensions.map(&:to_s))}$/
        end

        if @patterns
          next true if entry.to_s !~ /#{Regexp.union(@patterns)}/
        end
      end
    end

    private

    def bad_singleton_method_name?(method_name)
      singleton_methods.include?(method_name.to_sym)
    end
  end
end

