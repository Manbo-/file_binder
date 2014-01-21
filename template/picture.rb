class Picture < FileBinder
  path "/path/to/picture"
  recursive true
  extensions FileBinder::Extensions::PICTURE
end

