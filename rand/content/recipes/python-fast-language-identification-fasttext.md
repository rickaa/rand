+++
title = "Language identification with fastText"
date = "2019-08-20"
author = "Ricardo"
categories = ["nlp", "fasttext", "language"]
tags = ["fasttext", "nlp", "text", "language", "identification", "classification"]
+++


```bash
wget https://dl.fbaipublicfiles.com/fasttext/supervised-models/lid.176.bin
```

```python
import fasttext

lid_model = fasttext.load_model('lid.176.bin')

def detector(text):
    # return empty string if there is no tweet
    if text.isspace():
        return ""
    else:
        # get first item of the prediction tuple, then split by "__label__" and return only language code
        return lid_model.predict(text)[0][0].split("__label__")[1]

df['language'] = df['Tweet'].apply(detector)
```



