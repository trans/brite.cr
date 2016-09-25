# Markdown generator
# (c) OpenBohemians

require "yaml"
require "markdown"

CONFIG_FILE = ".brite/config.yml"
CONFIG_SECTION = "markdown"

# Default config
CONFIG_DEFAULT = {
  "include" => "**/*.md",
  "exclude" => ""  # TODO
}

def main
  config = read_config
  # TODO: improve this to hand directory names ane exlcusions
  # Glob markdown files
  files = Dir.glob(config["include"])
  generate(files)
end

# Read config file
def read_config
  config = CONFIG_DEFAULT.dup
  yaml = YAML.parse(File.read(CONFIG_FILE))
  if yaml.is_a?(Hash)
    if cfg = yaml[CONFIG_SECTION]
      config = config.merge(cfg)
    end
  else
    raise "Unexpected YAML format: #{yaml.class}"
  end
  config
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
  return Markdown.to_html(body_text)
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
  file = file.chomp(File.extname(file)) + ".chtml"
  File.write(file, text)
end

# run main routine
main
