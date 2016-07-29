#!/bin/bash
projDir="/Users/bschermerhorn/SideProjects/elderbas.github.io_blog/kitchenSink"
outputDir="/Users/bschermerhorn/SideProjects/elderbas.github.io_blog/gh-pages"

cd $projDir
cd public
perl -pi -w -e 's/\/assets/\/blog\/assets/g;' _layout.ejs


cd $projDir
harp compile $projDir $outputDir

cd $projDir
git add .
git commit -a --allow-empty-message -m ""
git push origin kitchenSink

cd $outputDir
git add .
git commit -a --allow-empty-message -m ""
git push origin gh-pages
echo 'published '

cd $projDir
cd public
perl -pi -w -e 's/\/blog\/assets/\/assets/g;' _layout.ejs

