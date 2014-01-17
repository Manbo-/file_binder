class FileBinder
  class Disk
    def initialize(pathname)
      @pathname = pathname
    end

    def read(recursive: nil, extensions: nil, patterns: nil)
      glob_path = recursive ? "#{@pathname.realpath}/**/*" : "#{@pathname.realpath}/*"
      Pathname.glob(glob_path).reject do |entry|
        if !entry.directory? and extensions
          next true if entry.to_s !~ /\.#{Regexp.union(extensions.map(&:to_s))}$/
        end

        if patterns
          next true if entry.to_s !~ /#{Regexp.union(patterns)}/
        end
      end
    end
  end
end
