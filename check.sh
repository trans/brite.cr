#!/bin/bash
crystal build src/brite/indexer.cr
mv indexer sample/.brite/pipeline/
cd sample
.brite/pipeline/indexer
cd ..

