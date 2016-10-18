![Light-bulb!](logo.png)

# Brite Site Duex

*The Crystal Clear Static Site Generator!*


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
out there. For starters, page and post files have a file extension coresponding the layout 
template they will use. Another distinction is that pages and posts are organized into
directories, not just files. This allows assets to be stored with the content to which
it pertains. This in turn alows Brite to use a feature called *acquisition*. Acquisition
is a concept borrowed from Zope (if any of you remember that). Essentially layouts are searched
for starting with the location of the source document and continued up the directory tree
to the site's top directory. In thsi way pages and posts can be categorized by the directory
hiearchy and assets, like layouts, shared between categories.

### Features

* Unix philosophy
* Statically compiled 
* Mustache Templates
* Markdown Format
* HCard support (eventually)
* RSS/Atom feeds
* Easily Themed

**Possible Future Features**

* Dynamic Javascript site generator
* [Constraint-based Stylesheets](http://gridstylesheets.org/)
* Extensible rendering pipeline

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

## Going Deep

The standard pipeline can be broken down into a four broard *ordered* operations.

1. sourcing   - prepare source materials
2. indexing   - create site indexes
3. generating - generate site pages
4. deploying  - upload site to servers

Out of the box Brite provides the following.

**Sourcing**

None at this time.

In the future we might provided a a way to import from other engines such as
Jekyll, as well as import from a Gollum Wiki. For now however, you have to do
this by hand. Or start a site from stratch.

**Indexing**

* json   - generate JSON index
* rss    - generate RSS feed
* atom   - generate Atom feed

Presently the first, JSON index, is always generated. The later are generated
if the layout template files are found in the `theme` directory, namely,
`rss.html` and `atom.html` respectively. If you do not wish for one or either
of these to be rendered we recommend simply renaming the layout file with a
prefixing undersore, e.g. `_rss.html` and/or `_atom.html`.

**Generating**

* markdown  - generate html partials from markdown files
* mustache  - generate html finals from partials, metadata and mustache layouts

Presently these two operations occur together in a single pass. In the future
it may be possible to separate them, but there are some ramifications to this
that have to considered carefully first.

**Deployment**

None at this time.

In the future we will add some built-in support for pushing to hosting services,
starting with git-based hosting repositories, such as Github.


## Roadmap

Considering the addition of an exentsible pipeline. To do this, it must be
possible for all steps in the processes to be isolated, so that custom tools
can be run in between each with access to the necessary data and configuration.
We could do this in a very Unix way, allowing external command line tools to
run, or we could do it via a plug-in system, in which case only Crystal coded
extensions would be of use -- however, I do not know how that could work for
a compiled program. The former approach has some advantages. Any part of the
pipeline could be replaced if need be, without restriction on language or
dependencies. Don't like Brite's built-in Markdown renderer? Just replace that
part with a shell script that uses Pandoc, for instance. The downside here,
each tool is on its own with regard to reading the configuration data and just
generally doing the right thing.

## Copyrights

Brite Site Duex (c) 2016 OpenBohemians

