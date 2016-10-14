require "json"
require "yaml"
require "crustache"
require "markdown"
require "option_parser"  # TODO: Replace with Clik when it is ready.

module Brite

  VERSION = "0.0.1"
  CONFIG_FILE = "config.yml"

  def self.run
    config = load_config

    case ARGV.pop
    when "build"
      BuildCommand.run(config)
      #IndexCommand.run(config)
    when "index"
      IndexCommand.run(config)
    else
      puts "Ouch!"
    end
  end

  def self.load_config
    text = File.read(CONFIG_FILE)
    Config.from_yaml(text)
  end

  ## 
  # Master configuration for site.
  #
  class Config
    YAML.mapping(
      title: String,
      about: String,
      url: String,
      ttl: { type: String, nilable: true },
      #ext: {type: String, nilable: true},
      layouts: { type: Array(String), nilable: true }
    )
  end

  ##
  # Build command class to build all site posts/pages.
  #
  class BuildCommand
    @config : Config

    def self.run(config : Config)
      builder = new(config)
      builder.run
    end

    def initialize(config : Config)
      @config = config
      @posts = [] of String
    end

    def run
      parse
      build
    end

    def parse
      OptionParser.new do |opts|
        opts.separator
        opts.separator "  Usage: brite build [options]"
        opts.separator
        opts.separator "  Options:"
        opts.separator

        opts.on("-h", "--help", "Display help") do
	        puts opts.to_s
	        exit
        end

        opts.on("-v", "--version", "Display version") do
	        puts "Brite Site v#{VERSION}"
	        exit
        end

        #opts.on("-c", "--with-content", "Include full content") do
	      #  @include_content = true
        #end

        opts.separator
        opts.separator
      end.parse!

      # TODO: should we really allow building individual files?
      # TODO: Does OptionParser remove options from this or do we need another way?
      locals = ARGV.dup
      layouts = @config.layouts || ["post", "page"]

      @posts = collect_posts(locals, layouts)
    end

    #
    def collect_posts(locals : Array(String), layouts : Array(String))
      if locals.empty?
        # if no specifics then look for all posts/pages
        layouts.map { |layout| Dir.glob("**/*.#{layout}") }.flatten
      else
        locals.map { |local|
          if File.file?(local)
            # TODO: should we catch this error here or when it tries to find the layout?
            unless layouts.any? { |layout| File.extname(local) == ".#{layout}" }
              raise "#{local} does not have a configured layout"
            end
            local
          else
            layouts.map do |layout|
              # assume it must be a directory, okay?
              Dir.glob(File.join(local, "*.#{layout}"))
            end
          end
        }.flatten
      end
    end

    #
    def build
      site_data = make_site_data

      builders = @posts.map do |file|
        Builder.new(file, site_data)
      end

      builders.each do |builder|
        builder.validate
      end

      builders.each do |builder|
        builder.build
      end
    end

    def make_site_data
      site_data = Hash(String, String).new
      site_data["title"] = @config.title
      site_data["url"] = @config.url
      site_data
    end
  end

  ##
  # Builder class builds a single post/page.
  #
  class Builder  
    @directory : String
    @markup_file : String
    @layout_name : String
    @data_file : String
    @is_yaml : Bool
    @renderer : CrustacheOnYAML | CrustacheOnJSON
    @site_data : Hash(String, String)

    def initialize(file : String, site_data : Hash(String, String))
      @markup_file = file
      @site_data = site_data

      # We get the layout name from the document extension
      # although all documents are markdown format.
      # Technically we could use `{name}.{layout}.md` if we wanted
      # to be precice, but I don't think it is necessary.
      #@layout_name = File.extname(file.chomp(".md")).sub(".", "")
      @layout_name = File.extname(file).sub(".", "")

      @directory = File.dirname(file)

      @data_file = find_data_file(file)

      if @data_file == ""
        raise "No data file for #{file}."
      end

      @is_yaml = (File.extname(@data_file) != ".json")

      if @is_yaml
        @renderer = CrustacheOnYAML.new(@data_file)
      else
        @renderer = CrustacheOnJSON.new(@data_file)
      end
    end

    def validate
      unless layout_file
        raise "No layout file for #{@markup_file}"
      end 
    end

    def build
      outfile = page_name + ".html"
      save(render, outfile) #File.join(directory, outfile))
    end

    def render
      markup = File.read(markup_file)
      layout = File.read(layout_file)

      render(markup, layout)
    end

    def render(markup, layout)
      html = Markdown.to_html(markup)

      @renderer.render(layout, html)

      # TODO cache this by layout file for speed up
      #template = Crustache.parse(layout)
      #if @is_yaml     
      #  data = @data #.dup
      #  #data["content"] = YAML::Any.new(html)
      #	Crustache.render(template, data)
      #else
      #  data = @data #.dup
      #  data["content"] = html #JSON::Type.new(html)
      #	Crustache.render(template, data)
      #end
    end

    def save(content : String, file : String)
      STDERR.puts file
      File.write(file, content)
    end

    def directory
      @directory
    end

    def markup_file
      @markup_file
    end

    def layout_file : String
      #layout_name = @renderer.layout_name
      find_layout_file(@directory, @layout_name)
    end
    #if File.extname(file) == ".json"

    # Find layout relative to directory.
    def find_layout_file(dir, layout_name) : String
      pwd = File.expand_path(".")
      dir = dir.dup #File.dirname(File.expand_path(file))
      while(dir != pwd && dir != "/")
        lay = File.join(dir, "theme", layout_name.to_s + ".html")  # extension?
        if File.exists?(lay)
          return lay
        end
        dir = File.dirname(dir)
      end
      return ""
    end

    #
    def find_data_file(dir : String) : String
      ["index.json", "index.yaml", "index.yml"].each do |file|
        path = File.join(dir, file)
        return path if File.file?(path)
      end
      return ""
    end

    #
    def page_name
      @markup_file.chomp(File.extname(@markup_file))
    end
  end #Builder

  ##
  # Crustache template rendering via YAML metadata.
  #
  class CrustacheOnYAML
    @data_file : String
    @data : Hash(YAML::Type, YAML::Type)

    def initialize(data_file : String)
      @data_file = data_file
      @data = load_data(data_file)
    end

    def load_data(file : String)
      text = File.read(file)
      #hash = Hash(String, YAML::Any).new
      yaml = YAML.parse(text)
      return yaml.as_h
      #  #yaml.each do |k,v|
      #  #  hash[k.to_s] = v
      #  #end
    end

    def layout_name
      @data["layout"] || "post"
    end

    def render(layout : String, content : String)
      data = @data
      data["content"] = content #YAML::Any.new(html)
      template = Crustache.parse(layout)
     	Crustache.render(template, data)
    end
  end

  ##
  # Crustache template rendering via JSON metadata.
  #
  class CrustacheOnJSON
    @data_file : String
    @data : Hash(String, JSON::Type)

    def initialize(data_file : String)
      @data_file = data_file
      @data = load_data(data_file)
    end

    def load_data(file : String)
      text = File.read(file)
      json = JSON.parse(text)
      return json.as_h
    end

    def layout_name
      if @data.has_key?("layout")
        @data["layout"] || "post"
      else
        "post"
      end
    end

    def render(layout : String, content : String)
      data = @data
      data["content"] = content
      template = Crustache.parse(layout)
    	Crustache.render(template, data)
    end
  end

  ##
  #
  class IndexCommand
    @config : Config
    @posts  : Array(String)

    def self.run(config : Config)
      new(config).run
    end

    def initialize(config : Config)
      @config = config
      @posts = [] of String
    end

    def run
      parse
      build
    end

    def parse
      OptionParser.new do |opts|
        opts.separator
        opts.separator "  Usage: brite index [options]"
        opts.separator
        opts.separator "  Options:"
        opts.separator

        opts.on("-h", "--help", "Display help") do
	        puts opts.to_s
	        exit
        end

        #opts.on("-c", "--with-content", "Include full content") do
	      #  @include_content = true
        #end

        opts.separator
        opts.separator
      end.parse!

      layouts = @config.layouts || ["post", "page"]

      @posts = collect_posts(layouts)
    end

    # Collect all posts/pages that have configured layouts.
    def collect_posts(layouts : Array(String))
      layouts.map { |layout| Dir.glob("**/*.#{layout}") }.flatten
    end

    #
    def build
      site_data = make_site_data
      indexer = Indexer.new(@posts, site_data)
      indexer.run
    end

    def make_site_data
      site_data = Hash(String, String).new
      site_data["title"] = @config.title
      site_data["url"] = @config.url
      site_data
    end
  end

  ##
  # Indexer generates a JSON metadata file that contains a section for each post/page.
  # Each sections contains all the information about each post/page, *except* the actual
  # post/page content -- a file path is given for that instead.
  #
  # In the future we will make it possible to create subcategory indexes, on a per-directory basis,
  # i.e. all posts below a directory will be included.
  #
  class Indexer
    @posts : Array(String)
    @site_data : Hash(String, String)

    def initialize(posts : Array(String), site_data : Hash(String, String))
      @posts = posts
      @site_data = site_data
    end

    def run
      save_json(generate_json)
    end

    # Generate JSON from metadata.
    def generate_json
      String.build do |io|
        io.json_object do |object|
          object.field "title", @site_data["title"]
          object.field "pubDate", today
          object.field "items" do
            io.json_array do |array|
              collect_items.each do |item|
                array << item 
              end
            end
          end
        end
      end
    end

    # Collect metadata from each post/page.
    def collect_items
      @posts.map do |post|
        name = post.chomp(File.extname(post))
        if File.file?(name + ".json")
          read_json_metadata(name + ".json")
        elsif File.file?(name + ".yaml")
          read_yaml_metadata(name + ".yaml")
        else
          raise "no metadata for #{post}"
        end
      end
    end

    # Save JSON index.
    def save_json(metadata)
      File.write("index.json", metadata.to_json)
    end

    # Generates RSS and/or Atom feed.
    def generate_feed(json)
      tmp_layout = Crustache.parse(RSS_LAYOUT)
      tmp_item_layout = Crustache.parse(RSS_ITEM_LAYOUT)

      model = {"content" => html}
      Crustache.render template, model

      File.write("index.rss", result)
    end

    def read_json_metadata(meta_file)
      if File.exists?(meta_file)
        JSON.parse(File.read(meta_file))
      else
        puts "Warning: No metadata found for #{meta_file}."
        # hmm... we have some figuring to do
        nil #Meta.default
      end
    end

    def read_yaml_metadata(meta_file)
      if File.exists?(meta_file)
        YAML.parse(File.read(meta_file)).as_h
      else
        puts "Warning: No metadata found for #{meta_file}."
        # hmm... we have some figuring to do
        nil #Meta.default
      end
    end

    def change_ext(file, ext)
      file.chomp(File.extname(file)) + ext
    end

    #
    #def find_layout_file(dir : String) : String
    #  ["index.json", "index.yaml", "index.yml"].each do |file|
    #    path = File.join(dir, file)
    #    return path if File.file?(path)
    #  end
    #  return ""
    #end

    # Time in ISO format, e.g. "2016-04-05".
    def today
      Time.now.to_s("%F")
    end
  end

end

Brite.run

