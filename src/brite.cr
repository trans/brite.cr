require "json"
require "yaml"
require "crustache"
require "markdown"

module Brite

  VERSION = "0.0.1"

  # Command line interface.

  class BuildCommand

    def initialize
      @posts = [] of String
    end

    def run
      parse
      build
    end

    def parse
      OptionParser.new do |opts|
        opts.separator
        opts.separator "  Usage: brite [options]"
        opts.separator
        opts.separator "  Options:"
        opts.separator

        opts.on("-h", "--help", "Display help") do
	        puts opts.to_s
	        exit
        end

        opts.on("-v", "--version", "Display version") do
	        puts VERSION
	        exit
        end

        #opts.on("-c", "--with-content", "Include full content") do
	      #  @include_content = true
        #end

        opts.separator
        opts.separator
      end.parse!

      locals = ARGV.dup
      if locals.empty?
        files = Dir.glob("**/index.md")
        @posts = files.map { |file| File.dirname(file) }
      else
        @posts = locals.map do |local|
          if File.file?(local)
            File.dirname(local)
          else
            local  # assume it must be a directory, okay?
          end
        end
      end
    end

    def build
      builders = @posts.map do |dir|
        Builder.new(dir)
      end

      builders.each do |builder|
        builder.validate
      end

      builders.each do |b|
        builder.build
      end
    end

  end

  # Builder class builds a single post/page.

  class Builder  

    def initialize(dir : String)
      @directory = dir

      @markup_file = File.join(dir, "index.md")
      @data_file = find_data_file(dir)

      if @data_file == ""
        raise "No data file for #{dir}."
      end

      @data = load_data(@data_file)
    end

    def load_data(file : String)
      text = File.read(file)

      if File.extname(file) == ".json"
        json = JSON.parse(text)
        json.to_h
      else
        yaml = YAML.parse(text)
        yaml.to_h
      end
    end

    def validate
      unless layout_file
        raise "No layout file for #{directory}"
      end 
    end

    def build
      save(render, File.join(directory, "index.html"))
    end

    def render
      markup = File.read(markup_file)
      layout = File.read(layout_file)

      render(markup, layout)
    end

    def render(markup, layout)
      html = Markdown.to_html(markup)

      # TODO cache this by layout file for speed up
      template = Crustache.parse(layout)

      data = @data.dup
      data["content"] = html

    	Crustache.render(template, data)
    end

    def save(content : String, file : String)
      #File.write(content, file)
    end

    def directory
      @directory
    end

    def markup_file
      @markup_file
    end

    def layout_file
      layout_name = @data["layout"] || "post"
      find_layout_file(dir, layout_name)
    end

	  # Find layout relative to directory.
	  def find_layout_file(dir, layout_name)
	    pwd = File.expand_path(".")
	    dir = File.dirname(File.expand_path(file))
	    while(dir != pwd && dir != "/")
        lay = File.join(dir, "theme", layout_name + ".html")  # extension?
		    if File.exists?()
		      return lay
		    end
		    dir = File.dirname(dir)
	    end
      return nil
	  end

    #
    def find_data_file(dir : String) : String
      ["index.json", "index.yaml", "index.yml"].each do |file|
        path = File.join(dir, file)
        return path if File.file?(path)
      end
      return ""
    end

  end

end

brite = Brite::BuildCommand.new
brite.build


