#!/bin/bash
projDir="/Users/bschermerhorn/SideProjects/elderbas.github.io_blog/kitchenSink"
outputDir="/Users/bschermerhorn/SideProjects/elderbas.github.io_blog/gh-pages"

cd $projDir
cp public/_layout.ejs public/tempLayout.txt
sed 's/\/assets/\/blog\/assets/g' public/_layout.ejs > public/_layout.ejs

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
rm public/_layout.ejs
cp public/tempLayout.txt public/_layout.ejs
rm public/tempLayout.txt
# sed 's/\/blog\/assets/\/assets/g' public/_layout.ejs > public/_layout.ejs