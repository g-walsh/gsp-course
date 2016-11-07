#! /usr/local/bin/fish

# copy figures to html/figures directory
cp -a xenograph/figures/. html/figures/

# prepare LaTeX ---
# flatten latex file
latexpand course.tex > html/temp.tex --keep-comments --empty-comments
# change marginpar commands to plain text
sed -i -r 's/.*\\\\(begin|end)\{marginnoteblock\}/MARGINNOTE\1/g' html/temp.tex

# convert LaTeX to HTML
pandoc html/temp.tex -o html/course.html --standalone --smart --normalize --ascii --number-sections --mathjax --css=style/minimal.css --bibliography=bibliography.bib --bibliography=bib_additional.bib --filter=pandoc-crossref
# correct figure urls
sed -i 's/xenograph\/figures/figures/g' html/course.html

# convert marginpars commands to html DIVs
sed -i 's/MARGINNOTEbegin/<div class="marginnote"><p>/g' html/course.html
sed -i 's/MARGINNOTEend/<\/p><\/div>/g' html/course.html
rm html/temp.tex
