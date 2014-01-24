class FileBinder
  class Collection < Array
    def initialize(pathname, recursive, extensions, patterns)
      @pathname = pathname
      entries = Pathname.glob(glob_path(recursive)).reject do |entry|
        if extensions and !entry.directory?
          next true if entry.to_s !~ /\.#{Regexp.union(extensions.map(&:to_s))}$/
        end

        if patterns
          next true if entry.to_s !~ /#{Regexp.union(patterns)}/
        end
      end
      super(entries)
    end

    def files
      reject(&:directory?)
    end

    def directories
      select(&:directory?)
    end

    def videos
      select{ |entry| entry.to_s =~ /\.#{Regexp.union(Extensions::VIDEO)}$/ }
    end
    alias movies videos

    def pictures
      select{ |entry| entry.to_s =~ /\.#{Regexp.union(Extensions::PICTURES)}$/ }
    end
    alias photos pictures
    alias images pictures

    def docs
      select{ |entry| entry.to_s =~ /\.#{Regexp.union(Extensions::DOCS)}$/ }
    end

    private

    def glob_path(recursive)
      @pathname.realpath.to_s + (recursive ? "/**/*" : "/*")
    end
  end
end
