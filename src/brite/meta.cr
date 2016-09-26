module Brite

  # class for read per post/page metadata
  class Meta
    JSON.mapping(
      title: String,
      author: String,
      date: String,  # Time ?
      summary: String,
      tags: Array(String)
    )

    def self.default
      from_json(<<-HERE
        "title": "Causal Dancing with Bananas"
        "author": "Annonymous"
        "date": "2015-10-10"
        "summary" "We have no bananas today!"
        "tags": []
      HERE)
    end

    def layout_file
      "layout.html"
    end
  end

end
