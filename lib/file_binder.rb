require "listen"
require "pathname"
require "forwardable"
require "yaml"

require "file_binder/collection"
require "file_binder/listen"
require "file_binder/save"
require "file_binder/extensions"
require "file_binder/version"

class FileBinder
  class << self
    attr_reader :pathnames, :listener

    extend Forwardable
    def_delegators :entries, :files, :directories

    def inherited(binder)
      binder.instance_variable_set(:@pathnames, [])
    end

    def bind(*pathes)
      pathes.each do |path|
        pathname = Pathname.new(path)
        raise "missing destination file operand" unless pathname.exist?
        @pathnames << pathname.realpath
      end
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

    def listen(opts = {}, &callback)
      @listener = Listener.new(@pathnames, opts, &callback)
    end

    Listener::CALLBACKS.each do |name|
      define_method "#{name}_on" do |&callback|
        @listener ||= Listener.new(@pathnames)
        @listener.send("#{name}_on", callback)
      end
    end

    def entries
      @entries ||= reload
    end

    def reload
      @entries = Collection.new(@pathnames, @recursive, @extensions, @patterns)
    end

    def command(name, command)
      raise "oh my god '#{name}'" if bad_singleton_method_name?(name)
      define_singleton_method name do
        command[entries]
      end
    end

    include FileBinder::Save

    private

    def bad_singleton_method_name?(method_name)
      singleton_methods.include?(method_name.to_sym)
    end
  end
end

