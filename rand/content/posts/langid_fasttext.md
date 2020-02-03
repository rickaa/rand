+++
title = "Language identification with fastText"
date = "2019-08-20"
author = "Ricardo"
categories = ["nlp", "fasttext", "language"]
tags = ["fasttext", "nlp", "text", "language", "identification", "classification"]
+++


When dealing with a multilingual dataset doing language identification is a very important part of the analysis process, here I'll show a way to do a fast ⚡️ and reliable ✨ languague identification with [fasttext](https://fasttext.cc).
<!--more-->

**TL;DR**


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

First we need to download a dataset to play with. We'll use the [kaggle CLI tool](https://github.com/Kaggle/kaggle-api). Run the following command after installing it or download the dataset [directly from kaggle](https://www.kaggle.com/rtatman/the-umass-global-english-on-twitter-dataset).

```bash
kaggle datasets download -d rtatman/the-umass-global-english-on-twitter-dataset
```


```python
import pandas as pd

df = pd.read_csv('the-umass-global-english-on-twitter-dataset.zip', sep='\t')
df.head()
```




<div>
<style scoped>
    .dataframe tbody tr th:only-of-type {
        vertical-align: middle;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }

    .dataframe thead th {
        text-align: right;
    }
</style>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>Tweet ID</th>
      <th>Country</th>
      <th>Date</th>
      <th>Tweet</th>
      <th>Definitely English</th>
      <th>Ambiguous</th>
      <th>Definitely Not English</th>
      <th>Code-Switched</th>
      <th>Ambiguous due to Named Entities</th>
      <th>Automatically Generated Tweets</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>434215992731136000</td>
      <td>TR</td>
      <td>2014-02-14</td>
      <td>Bugün bulusmami lazimdiii</td>
      <td>0</td>
      <td>0</td>
      <td>1</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
    </tr>
    <tr>
      <th>1</th>
      <td>285903159434563584</td>
      <td>TR</td>
      <td>2013-01-01</td>
      <td>Volkan konak adami tribe sokar yemin ederim :D</td>
      <td>0</td>
      <td>0</td>
      <td>1</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
    </tr>
    <tr>
      <th>2</th>
      <td>285948076496142336</td>
      <td>NL</td>
      <td>2013-01-01</td>
      <td>Bed</td>
      <td>1</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
    </tr>
    <tr>
      <th>3</th>
      <td>285965965118824448</td>
      <td>US</td>
      <td>2013-01-01</td>
      <td>I felt my first flash of violence at some fool...</td>
      <td>1</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
    </tr>
    <tr>
      <th>4</th>
      <td>286057979831275520</td>
      <td>US</td>
      <td>2013-01-01</td>
      <td>Ladies drink and get in free till 10:30</td>
      <td>1</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
    </tr>
  </tbody>
</table>
</div>




```python
print(f"""There are: {df.Tweet.shape[0]} tweets.
    
First 10 tweets:
    
{df['Tweet'].head(10)}""")
```

    There are: 10502 tweets.
        
    First 10 tweets:
        
    0                            Bugün bulusmami lazimdiii
    1       Volkan konak adami tribe sokar yemin ederim :D
    2                                                  Bed
    3    I felt my first flash of violence at some fool...
    4              Ladies drink and get in free till 10:30
    5                     @Melanynijholtxo ahhahahahah dm!
    6                                                 Fuck
    7    Watching #Miranda On bbc1!!! @mermhart u r HIL...
    8                                       @StizZsti fino
    9            Shopping! (@ Kohl's) http://t.co/I8ZkQHT9
    Name: Tweet, dtype: object


Looking at the first 10 tweets we can already see the are multiple languags been used. Lets now use fasttext to classify them. You need to download the language indentification model to use it, run the following shell command if you need to do so.

```bash
wget https://dl.fbaipublicfiles.com/fasttext/supervised-models/lid.176.bin
```

Alternatively, you can use a slightly less accurate but a lot smaller model:

```bash
wget https://dl.fbaipublicfiles.com/fasttext/supervised-models/lid.176.ftz
```

And now we can use it.


```python
import fasttext

lid_model = fasttext.load_model('lid.176.bin')
```

    


Create a list in which each item is a tweet.


```python
corpus = df['Tweet'].to_list()
```

Predict the language of the first tweet.


```python
tweet = corpus[0]
prediction = lid_model.predict(corpus[0])
print(f"Text:\n \t {tweet} \n \n Prediction:\n \t {prediction}")
```

    Text:
     	 Bugün bulusmami lazimdiii 
     
     Prediction:
     	 (('__label__tr',), array([0.77383512]))


The output of the prediction is a tuple of language label and prediction confidence. Language label is a string with “\__label__” followed by ISO 639 code of the language. You can check the language codes [here](https://www.loc.gov/standards/iso639-2/php/code_list.php) and the languages supported by fasttext at the end of [their blog post](https://fasttext.cc/blog/2017/10/02/blog-post.html).

Lets try with a different one.


```python
print(f"Text:\n \t {corpus[4]} \n \n Prediction:\n \t {lid_model.predict(corpus[4])}")
```

    Text:
     	 Ladies drink and get in free till 10:30 
     
     Prediction:
     	 (('__label__en',), array([0.65553886]))


Now we can create a new column with the langue of each tweet.


```python
def detector(text):
    # return empty string if there is no tweet
    if text.isspace():
        return ""
    else:
        # get first item of the prediction tuple, then split by "__label__" and return only language code
        return lid_model.predict(text)[0][0].split("__label__")[1]
```


```python
%%time
df['language'] = df['Tweet'].apply(detector)
```

    CPU times: user 258 ms, sys: 4.17 ms, total: 262 ms
    Wall time: 266 ms


I added the `%%time` IPython [command](https://ipython.readthedocs.io/en/stable/interactive/magics.html) to show one of the main reasons to use fasttext, the speed ⚡️. **In 250ms I processed 10502 tweets** working on a 2016 laptop with a dual-core 2 GHz Intel Core i5 processor.

The speed of fastText can also be compared with [langid.py](https://github.com/saffsd/langid.py) in this table from their [blog](https://fasttext.cc/blog/2017/10/02/blog-post.html).

![](https://fasttext.cc/img/blog/2017-10-02-blog-post-img1.png)

Finally, if we wanted to work only with a subset of the languages and convert the rest to _"unk"_ (and maybe use a multilingual model when working with them), we can use the following.


```python
# keep the 4 top languages according to the current predictions
languanges_keep = df.language.value_counts().index[:4].to_list()

# create a custom list
languanges_keep = ["en", "es", "pt", "ja"]

df.loc[df.language.apply(lambda x: x not in languanges_keep), 'language'] = "unk"
```


```python
df.language.value_counts()
```




    en     5735
    unk    2247
    es     1139
    pt      876
    ja      505
    Name: language, dtype: int64



And from here we can keep working with our text data!
