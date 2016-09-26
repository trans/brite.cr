# Markdown generator
# (c) OpenBohemians

#require "./yamlext"
require "json"
require "markdown"

module Brite

  class Markdown
		CONFIG_FILE = ".brite/config.yml"
  	CONFIG_SECTION = "markdown"

    # TODO best ext name?
    PARTIAL_EXTENSION = "chtml"

    property :spec 

    def initialize
      yaml = JSON.parse(File.read(CONFIG_FILE))
      conf = yaml[CONFIG_SECTION]
      @spec = Spec.from_json(conf.to_json)
    end

		def run
		  # Glob markdown files
		  files = Dir.glob(spec.include)
		  generate(files)
		end

		# Iterate thru md file and generate html via layouts 
		def generate(files)
			files.each do |file|
			  #data = read_metadata(file)
			  text = File.read(file)
			  output = render(text)
			  save(output, file)
			end
		end

		def render(body_text)
		  ::Markdown.to_html(body_text)
		end

		# Find layout relative to content file
		def find_layout(file, layout_name)
		  pwd = File.expand_path(".")
		  dir = File.dirname(File.expand_path(file))
		  while(dir != pwd && dir != "/")
        lay = File.join(dir, layout_name)  # extension?
			  if File.exists?()
			    return lay
			  end
			  dir = File.dirname(dir)
		  end 
		end

		# Find layout relative to content file
		#def read_metadata(file)
		#  meta_file = file.chomp(File.extname(file)) + ".meta"
		#  if File.exist?(meta_file)
		#    YAML.parse(File.read(meta_file))
		#  else
		#    # probably will do this brite command as a master check
		#    puts "Warning: No metadata found for #{file}."
		#    # hmm... we have some figuring to do
		#  end
		#end

	  def save(text, file)
	    file = file.chomp(File.extname(file)) + "." + PARTIAL_EXTENSION
      puts file
  	  File.write(file, text)
	  end

    class Spec
  		DEFAULT_INCLUDE = "**/*.md"
	  	DEFAULT_EXCLUDE = ""  # TODO

      JSON.mapping(
        include: String,
        exclude: String
      )

      #property :include
      #property :exclude

      #def initialize()
      #  yaml = YAML.parse(File.read(CONFIG_FILE))
      #  conf = yaml[CONFIG_SECTION]
      #  @include = conf["include"].as_s
      #  @exclude = conf["exclude"].as_s 
      #end

      def include
        @include || DEFAULT_INCLUDE
      end

      def exclude
        @exclude || DEFAULT_EXCLUDE
      end

    end

  end

end

# run main routine
bm = Brite::Markdown.new
bm.run

