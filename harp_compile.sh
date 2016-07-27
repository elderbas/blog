#!/bin/bash
projDir="/Users/bschermerhorn/SideProjects/elderbas.github.io_blog/kitchenSink"
outputDir="/Users/bschermerhorn/SideProjects/elderbas.github.io_blog/gh-pages"
harp compile $projDir $outputDir

cd outputDir
git add .
git commit -m "$date"
git push origin kitchenSink

cd outputDir
git add .
git commit -m "$date ghpages"
git push origin gh-pages
echo 'published'