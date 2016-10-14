![Light-bulb!](logo.png)

# Brite Site Duex

*And no it won't be written in fucking Crystal or Swift.*

## A Little History

Back in the days when I was in the churning deeps of Ruby development, I created an early
static site/blog engine called Brite. It was unique in a number of ways. For starters
post files actually had a `.post` extension. Imagine that. It also supported multi-format
documents via my Neapolitan gem. Markdown and Textile in one page. Holy cow! Well Jekyll
came along and the world mostly moved to Markdown. Around that time I had started writing
my blog posts in a github wiki and, after wrestling with some foolish overwrought approaches,
was able to write a small plug-in for Jekyll to render my wiki pages just fine. Things were
pretty good.

Fast forward to 2016 and Jekyll has failed me for the last time! My plug in is now broke 
because of changes to Jekyll, and Bundler is keeping me locked in gem dependency hell. So
I decided to try some alternatives. I ended up taking a spin on Hugo written in Go, Obelisk
written in Elixir, and Cryogen which is written in Clojure. Hugo seemed promising, but it 
soon started giving me fits. Themes are in bad shape and it is difficult to extend. Obelisk
showed promise, but it had no themes at all. You get blank page. So it just wasn't far enough
along. Of the three, Cryogen worked the best. With only a little conjoling I was able to get
my site up, it looked pretty good and was fully functional. I was about a stones throw from
committing to it -- after all I've always had a soft spot for Lisp. But there was this nagging
voice in the back of my mind that I could not shake. "There's a better way."


## A New Approach

Brite takes a fairly different approach from all the other copycat static site generators
out there. First of all it uses a pipeline. Some other tools use a pipeline. It's a smart
approach, but unlike the others, Brite's pipeline is composed of individual tools. Any one
of which can be replaced if need be, without restriction on language or dependencies.
Don't like Brite's built-in Markdown renderer? Just replace that part with a shell script
that uses Pandoc. Fine by us. It is your site after all. The `brite` command line tool
is really little more than a lightweight wrapper that manages this pipeline.

**NOTE: This feature might not be used, depends on if we can make it work well with themes.**
Another distinction of Brite is its use of *acquisition*. Acquisition is a concept
borrowed from Zope (if any of you remember that). Essentially layouts are searched for starting
with the location of the source document and continues up the directory tree to the site's top
directory.

### Features

* Unix philosophy
* Statically compiled 
* Extensible pipeline
* Mustache Templates
* Markdown Format
* HCard support
* RSS/Atom feeds
* Easy Themes

**Maybe Features**

* Dynamic Javascript site (in addition to full static)
* [Constraint-based Stylesheets](http://gridstylesheets.org/)


## Getting Started

Right now it's all development hoss. So keep you pants on and we'll get you wrangling pony as soon
as we can.

** DOES NOT WORK YET! WORK IN PROGRESS! **

```bash
$ brite new mysite
$ cd mysite
```

Then

```bash
$ brite build
```

The standard pipeline can be broken down into a few broard *ordered* operations.

1. sourcing   - prepare source materials
2. indexing   - create site indexes
3. generating - generate site pages
4. deploying  - upload site to servers

Out of the box Brite provides the following tools.

Indexing tools

1. index  - generate index pages and metadata files (e.g. RSS feeds)
2. rss    - generate RSS feed
3. atom   - generate Atom feed

Generating tools 

1. markdown  - generate html partials from markdown files
2. mustache  - generate html finals from partials, metadata and mustache layouts

Deployment tools

1. gitup - update site on serve using git


## Copyrights

Brite Site Duex (c) 2016 OpenBohemians

