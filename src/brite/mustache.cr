# Mustache generator
# (c) OpenBohemians

require "yaml"
require "crustache"

CONFIG_FILE = ".brite/config.yml"
CONFIG_SECTION = "mustache"

# Default config
CONFIG_DEFAULT = {
  "include" => "**/*.chtml",
  "exclude" => ""  # TODO
}

def main
  config = read_config
  # Glob .iml files
  files = Dir.glob(config["include"])
  generate(files)
end

# Read config file
def read_config
  config = CONFIG_DEFAULT.dup
  master = YAML.parse(File.read(CONFIG_FILE))
  if config.key?(CONFIG_SECTION)
    config = config.merge(data[CONFIG_SECTION])
  end
  config
end

# Iterate thru md file and generate html via layouts 
def generate(files)
	files.each do |file|
	  html = File.read(file)
	  data = read_metadata(file)
	  layout_file = find_layout(file, data["layout"])
	  unless layout_file
		puts "Warning: No layout template #{layout_file} found for #{file}"
		layout_file = default_layout_file
	  end
	  output = render(html, layout_file)
	  save(output, file)
	end
end

def render(html, template_file)
  template = Crustache.parse File.read(template_file)
  model = {"content" => html}
  Crustache.render template, model
end

# Find layout relative to content file
def find_layout(file, layout_name)
  pwd = File.expand_path(".")
  dir = File.dirname(File.expand_path(file))
  while(dir != pwd && dir != "/") do
    lay = File.join(dir, layout_name)  # extension?
    if File.exists?()
      return lay
    end
	dir = File.dirname(dir)
  end 
end

# Find layout relative to content file
def read_metadata(file)
  meta_file = file.chomp(File.extname(file)) + ".meta"
  if File.exist?(meta_file)
    YAML.parse(File.read(meta_file))
  else
    puts "Warning: No metadata found for #{file}. Not rendered."
    # hmm... we have some figuring to do
  end
end


# run main routine
main
