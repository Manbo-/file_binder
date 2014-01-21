class Video < FileBinder
  path "/path/to/video"
  recursive true
  extensions FileBinder::Extensions::VIDEO
end
