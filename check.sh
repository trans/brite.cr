#!/bin/bash
crystal build src/brite/mustache.cr
mv mustache sample/.brite/pipeline/
cd sample
.brite/pipeline/mustache
cd ..

