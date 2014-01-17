class FileBinder
  class Cache
    def initialize(pathname, filename)
      @pathname, @filename = pathname, filename
    end

    def read(recursive: nil, extensions: nil, patterns: nil)
      if File.exist?(@filename)
        YAML.load_file(@filename)
      else
        entries = Disk.new(@pathname).read(recursive: recursive, extensions: extensions, patterns: patterns)
        save(entries) and entries
      end
    end

    def save(entries)
      open(@filename, "w").write(YAML.dump(entries))
    end

    def drop
      FileUtils.rm(@filename)
    end
  end
end
