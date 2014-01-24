# FileBinder
[![Build Status](https://travis-ci.org/Manbo-/file_binder.png)](https://travis-ci.org/Manbo-/file_binder)

## Installation
    $ git clone https://github.com/Manbo-/file_binder.git
    $ cd ./file_binder
    $ rake install

## Usage
    require "file_binder"
    
    class VideoBox < FileBinder
      bind "/path/to/video_dir1", "/path/to/video_dir2"
      recursive true # default false
      extensions :avi, :wmv, :flv
      pattern /video/

      command :large, ->(videos) do
        videos.select{ |video| !video.directory? and video.size > 999999 }
      end

      # https://github.com/guard/listen      
      listen force_polling: true, latency: 0.5 do |modified, added, removed|
        reload
      end
    
      modified_on do |changes|
        ..
      end

      added_on do |changes|
        ..
      end

      removed_on do |changes|
        ..
      end
    end
    
    VideoBox.files
    VideoBox.directories
    VideoBox.entries
    VideoBox.large

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
