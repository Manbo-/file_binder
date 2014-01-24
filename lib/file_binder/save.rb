class FileBinder
  module Save
    def save(filename)
      open(filename, "w") do |f|
        f.write(YAML.dump(@entries))
      end
    end

    def load(filename)
      @entries = YAML.load_file(filename)
    end
  end
end

