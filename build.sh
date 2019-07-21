FILES="$(find notebooks -type f -name '*.ipynb')"
for f in $FILES
do
    nb2hugo $f --site-dir rand --section post
done
hugo -s rand
