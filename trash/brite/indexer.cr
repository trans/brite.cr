require "json"
require "./meta"

module Brite

  # Indexer generates a JSON metadata file that contains a section for each post/page.
  # Each sections contains all the information about each post/page, *except* the actual
  # post/page content -- a file path is given for that instead.
  #
  # In the future we will make it possible to create subcategory indexes, on a per-directory basis,
  # i.e. all posts below a directory will be included.

  class Indexer

    CONFIG_FILE = ".brite/config.yml"
    CONFIG_SECTION = "indexer"

    def run
      #yaml = JSON.parse(File.read(CONFIG_FILE))
      #conf = yaml[CONFIG_SECTION]
      #@spec = Spec.from_json(conf.to_json)
      generate_json
    end

    def generate_json
      index = Hash(String,Brite::Meta).new
      meta_files = Dir.glob("**/*.meta")
      meta_files.each do |file|
        data = read_metadata(file)
        if data
          index[change_ext(file, "html")] = data
        end
      end
      File.write("index.json", index.to_json)
    end

    def read_metadata(meta_file)
      if File.exists?(meta_file)
        Meta.from_json(File.read(meta_file))
      else
        puts "Warning: No metadata found for #{meta_file}."
        # hmm... we have some figuring to do
        nil #Meta.default
      end
    end

    def change_ext(file, ext)
      file.chomp(File.extname(file)) + ext
    end

    #class Spec
    #  JSON.mapping(
    #    ext: {type: String, nilable: true},
    #  )
    #end

  end

end

bi = Brite::Indexer.new
bi.run

