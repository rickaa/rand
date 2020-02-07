FILES="$(find notebooks -type f -name '*.ipynb' -not -path '*_checkpoints*')"
for f in $FILES
do
    nb2hugo $f --site-dir rand --section posts
done

MKDS="$(find thoughts -type f -name '*.md' ! -name '_*')"
for f in $MKDS
do
    cp $f rand/content/thoughts
done
