# Feeder generates a master metadata file in JSON, and an RSS and/or Atom feed.
# The RSS and Atom feed templates are built in but can be overridden by ...
#
# In the future we will make it possible to create subcategory feeds, on per-directory basis,
# i.e. all posts below a directory will be included.

CONFIG_FILE = ".brite/config.yml"
CONFIG_SECTION = "feeder"

require "yaml"
require "json"

def main
  config = read_config
  # what config do we need?
  generate_json
  generate_rss
  generate_atom
end

# Read config file
def read_config
  config = CONFIG_DEFAULT.dup
  master = YAML.parse(File.read(CONFIG_FILE))
  if master.key?(CONFIG_SECTION)
    config = config.merge(master[CONFIG_SECTION])
  end
  config
end

# TODO: support JSON metadata file too
def generate_json
  data = {}
  meta_files = Dir.glob("**/*.yml)
  meta_files.each do |file|
    file_data = YAML.load(File.read(file))
    # TODO what key should we use?
    data[file] = file_data
  end
end


