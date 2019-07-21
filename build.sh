FILES="$(find notebooks -type f -name '*.ipynb' -not -path '*_checkpoints*')"
for f in $FILES
do
    nb2hugo $f --site-dir rand --section post
done
cd rand
hugo
