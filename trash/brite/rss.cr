require "json"
require "mustache"
require "./meta"

module Brite

  # Generates RSS feed.
  #
  # In the future we will make it possible to create subcategory feeds, on a per-directory basis,
  # i.e. all posts below a directory will be included.

  class RSS

    CONFIG_FILE = ".brite/config.yml"
    CONFIG_SECTION = "rss"

    def run
      #yaml = JSON.parse(File.read(CONFIG_FILE))
      #conf = yaml[CONFIG_SECTION]
      #@spec = Spec.from_json(conf.to_json)
      generate_rss
    end

    def generate_rss
      file = "index.json"
      json = JSON.parse(File.read(file))

      tmp_layout = Crustache.parse(RSS_LAYOUT)
      tmp_item_layout = Crustache.parse(RSS_ITEM_LAYOUT)

      model = {"content" => html}
      Crustache.render template, model

      File.write("index.rss", result)
    end

    def read_metadata(meta_file)
      if File.exists?(meta_file)
        Meta.from_json(File.read(meta_file))
      else
        puts "Warning: No metadata found for #{file}."
        # hmm... we have some figuring to do
        nil #Meta.default
      end
    end

    #class Spec
    #  JSON.mapping(
    #  )
    #end


  end

end

