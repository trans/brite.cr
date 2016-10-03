# Mustache generator
# (c) OpenBohemians

require "json"
require "crustache"
require "./meta"

module Brite

  class Mustache

    CONFIG_FILE = ".brite/config.yml"
    CONFIG_SECTION = "mustache"

    property :spec 

    def initialize
      yaml = JSON.parse(File.read(CONFIG_FILE))
      conf = yaml[CONFIG_SECTION]
      @spec = Spec.from_json(conf.to_json)
    end

    def run
      ext = @spec.extension
      generate(ext)
    end

    # Iterate thru md file and generate html via layouts 
    def generate(ext)
      files = Dir.glob("**/*." + ext)
	    files.each do |file|
	      html = File.read(file)
	      data = read_metadata(file)
	      layout_file = find_layout(file, data.layout_file)
	      unless layout_file
          puts "Warning: No layout template #{layout_file} found for #{file}" 
          layout_file = "layout.html" #default_layout_file
	      end
	      output = render(html, layout_file)
	      save(output, file)
	    end
    end

	  def save(text, file)
      ext = File.extname(file)
	    file = file.chomp(ext) + (ext.sub(".c", "."))
      puts file
  	  File.write(file, text)
	  end

    # Need rest of meatadata in model, plus some other things.
    def render(html, template_file)
      template = Crustache.parse File.read(template_file)
      model = {"content" => html}
      Crustache.render template, model
    end

    # Find layout relative to content file
    def find_layout(file, layout_name)
      pwd = File.dirname(File.expand_path("."))
      dir = File.dirname(File.expand_path(file))
      while(dir != pwd && dir != "/")
        lay = File.join(dir, layout_name)  # extension?
        if File.exists?(lay)
          return lay
        end
        dir = File.dirname(dir)
      end 
    end

    # Find layout relative to content file
    def read_metadata(file)
      meta_file = file.chomp(File.extname(file)) + ".json"
      if File.exists?(meta_file)
        Meta.from_json(File.read(meta_file))
      else
        puts "Warning: No metadata found for #{file}."
        # hmm... we have some figuring to do
        Meta.default
      end
    end

    class Spec
      def self.default
        from_json(<<-HERE
          "extension": "chtml"
        HERE)
      end

      JSON.mapping(
        extension: String
      )
    end

  end

end

# run main routine
bm = Brite::Mustache.new
bm.run

