+++
title = "Black ❤ Jupyter"
date = "2019-07-22"
author = "Ricardo"
categories = ["tips", "formatting", "pandas"]
tags = ["pandas", "formatting", "black", "code", "comprehension", "list"]
+++


After nearly a year coding in Python (although not consistently), I started trying code formatters and discovered they were more useful than I thought. Here are some reason why.
<!--more-->

First, I must admit these tips may be biased by the fact I use [Jupyter Notebooks](https://jupyterlab.readthedocs.io/en/stable/) quite a lot. I think they are an incredible tool for learning although they may also instill some bad coding habits.

Before talking about [black](https://github.com/psf/black) lets go through the step to install it and use it with Jupyter Notebooks.

## Installing black and using it with Jupyter

Luckily for us, there is a Jupyterlab [extension](https://github.com/ryantam626/jupyterlab_code_formatter) for code formatting. To get started you only need 4 commands if you are using **conda**:

```bash
conda install -c conda-forge black
jupyter labextension install @ryantam626/jupyterlab_code_formatter
conda install -c conda-forge jupyterlab_code_formatter
jupyter serverextension enable --py jupyterlab_code_formatter
```

If you are using **pip** you need to install the one of the supported formatters (black in this case) and then do:

```bash
jupyter labextension install @ryantam626/jupyterlab_code_formatter
pip install jupyterlab_code_formatter
jupyter serverextension enable --py jupyterlab_code_formatter
```

Finally, what really helps me using black continuously, is having a handy shortcut to run it in the current cell. In my case I use **ctrl + k**, you can add it to your jupyterlab shortcuts pasting the following in your shortcuts settings editor:

```json
{

    "shortcuts": [
    {
                "command": "jupyterlab_code_formatter:black",
                "keys": [
                    "Ctrl K"
                ],
                "selector": ".jp-Notebook.jp-mod-editMode"
            }
        ]
}
```

Now lets go back to code ❗️

## Pandas method chaining

I believe one of those bad habits that Jupyter creates is writing code that doesn't look very clean when used outside the notebook. One case can be when using [method-chaining](https://tomaugspurger.github.io/method-chaining) in Pandas, which is the currently promoted style when cleaning data. Let's look at an example.


```python
def read_messages(path):
    df = (
        pd.read_csv(
            path,
            delimiter=";",
            dtype={"id": "int",
                   "type": "category",
                   "title": "str",
                   "text": "str"})
        .drop(["Unnamed: 0"], axis=1)
        # dates
        .assign(date=lambda x: pd.to_datetime(x["date"], format="%Y-%m-%d %H:%M:%S"),
                date_start=lambda x: pd.to_datetime(x["date_start"], format="%Y-%m-%d %H:%M:%S"),
                date_end=lambda x: pd.to_datetime(x["date_end"], format="%Y-%m-%d %H:%M:%S"))
        # others
        .assign(txt_length=lambda x: x.text.str.len(),
                word_number=lambda x: x.text.str.split().apply(len),
                date=lambda x: pd.to_datetime(x["date"].apply(lambda y: y.strftime("%Y-%m-%d")), format="%Y-%m-%d",),
                hour=lambda x: x["date"].apply(lambda y: y.hour)))

    return df
```

That is probably the best we would do if we were writing code and experimenting with data cleaning functions. Even though it looks quite readable (I think when you get used to method chaining it gets a lot easier to read the code), there are a lot of parentheses, indents and long functions.

This is how it looks when we apply [black](https://github.com/python/black) to it.


```python
def read_messages(path):
    df = (
        pd.read_csv(
            path,
            delimiter=";",
            dtype={"id": "int", "type": "category", "title": "str", "text": "str"},
        )
        .drop(["Unnamed: 0"], axis=1)
        # dates
        .assign(
            date=lambda x: pd.to_datetime(x["date"], format="%Y-%m-%d %H:%M:%S"),
            date_start=lambda x: pd.to_datetime(
                x["date_start"], format="%Y-%m-%d %H:%M:%S"
            ),
            date_end=lambda x: pd.to_datetime(
                x["date_end"], format="%Y-%m-%d %H:%M:%S"
            ),
        )
        .assign(
            txt_length=lambda x: x.text.str.len(),
            word_number=lambda x: x.text.str.split().apply(len),
            date=lambda x: pd.to_datetime(
                x["date"].apply(lambda y: y.strftime("%Y-%m-%d")), format="%Y-%m-%d"
            ),
            hour=lambda x: x["date"].apply(lambda y: y.hour),
        )
    )

    return df
```

That looks a lot better, and most importantly, it gets incredibly easier to debug when you get an error. At first, I thought I would be using black only after I finished writing my functions, but now it's actually the other way around, by constantly keeping the same clean code style I can spot the bugs faster.

## Long, messy functions

Now we are going to simulate a function with many parameters. This example was taken from the great blog [Mouse vs Python](http://www.blog.pythonlibrary.org/2019/07/16/intro-to-black-the-uncompromising-python-code-formatter/) by [Mike Driscoll](https://twitter.com/driscollis).


```python
def long_func(x, param_one=None, param_two=[], param_three={}, param_four=None, param_five="", param_six=123456):
    print(f"{param_three['first']}")
```

The function takes a lot of (unnecessary) arguments and then prints one of the values of the `dictionary` *param_three*. But what happens if we pass a `list` instead is that we get an error, and we can see that with such a long function, if the parameters were more difficult to debug and read this could turn out in one of these bugs that look obvious to solve but you can't find which parameter you are messing with.


```python
long_func(2, param_one=None, param_two=[], param_three=['cat'], param_four=None, param_five="", param_six=123456)
```


    ---------------------------------------------------------------------------

    TypeError                                 Traceback (most recent call last)

    <ipython-input-49-72b71a3bb5df> in <module>
    ----> 1 long_func(2, param_one=None, param_two=[], param_three=['cat'], param_four=None, param_five="", param_six=123456)
    

    <ipython-input-48-748a355c1dbb> in long_func(x, param_one, param_two, param_three, param_four, param_five, param_six)
          1 def long_func(x, param_one=None, param_two=[], param_three={}, param_four=None, param_five="", param_six=123456):
    ----> 2     print(f"{param_three['first']}")
    

    TypeError: list indices must be integers or slices, not str


This is how it looks like after applying black, a lot better!


```python
def long_func(
    x,
    param_one=None,
    param_two=[],
    param_three={},
    param_four=None,
    param_five="",
    param_six=123456,
):
    print(f"{param_three['first']}")
```

Even if we wanted to do type annotations it would be easy to read:


```python
from typing import List, Dict, Tuple


def long_func(
    x,
    param_one: int = None,
    param_two: List[str] = [],
    param_three: Dict[str, bool] = {'first': True},
    param_four: Tuple[int, int] = None,
    param_five: str = "",
    param_six: float = 123456.34,
) -> bool:
    
    print(f"{param_three['first']}")
    return param_three['first']
```

Another thing I love about black is that it won't reformat the code if there are syntax mistakes, and sometimes this has let me spot the before executing a slow function, which would have made me notice the error only during runtime.

For example in the function above if we had used `-->` for the return value annotation instead of `->` (this has happened to me very often), black would not have changed the original (unreadable) function.


```python
def long_func(x, param_one: int = None, param_two: List[str] = [], param_three: Dict[str, bool] = {'first': True},
              param_four: Tuple[int, int] = None, param_five: str = "",
              param_six: float = 123456.34) --> bool:
                                    ##     ^^^^ this is not correct
                                    ##     so this cell won't be formatted
                                    ##     when applying black!
                                    ##
                                    ##     I'm using 'bool' because I added
                                    ##     a return True at the end.
                            
    print(f"{param_three['first']}")

    return True
```


      File "<ipython-input-1-e610204a317b>", line 3
        param_six: float = 123456.34) --> bool:
                                      ^
    SyntaxError: invalid syntax



## Bonus

Since we are talking about formatting and debugging, I would like to show something I found recently, and it is the advantages of splitting code in multiple lines.

To illustrate it I am going to use list comprehensions. The example is taken from this [blog post](https://treyhunner.com/2019/03/abusing-and-overusing-list-comprehensions-in-python/) by [@treyhunner](https://twitter.com/treyhunner), which I highly recommend.

We are going to write a function to get the factors of a number using a list comprehension.


```python
def get_factors(dividend):
    """Return a list of all factors of the given number."""
    return [n for n in range(1, dividend + 1) if dividend % n == 0]
```


```python
get_factors(134)
```




    [1, 2, 67, 134]



But if we happen to mess the variables, and we try to add an **int** and a **string**:


```python
def get_factors(dividend):
    """Return a list of all factors of the given number."""

    num = "ops, this was supposed to be a number, not a string"

    return [n for n in range(1, dividend + num) if dividend % n == 0]
```


```python
get_factors(134)
```


    ---------------------------------------------------------------------------

    TypeError                                 Traceback (most recent call last)

    <ipython-input-56-dc9aa8e3ca2e> in <module>
    ----> 1 get_factors(134)
    

    <ipython-input-55-9abb3284b2d3> in get_factors(dividend)
          4     num = "ops, this was supposed to be a number, not a string"
          5 
    ----> 6     return [n for n in range(1, dividend + num) if dividend % n == 0]
    

    TypeError: unsupported operand type(s) for +: 'int' and 'str'


Now we are getting an error, but we don't know exactly in what part of the comprehensions it is (this is just for illustration, in this case it is very easy to see where the bug is).

However, if we had separated the comprehension in multiple lines, we would know exactly where the error is:


```python
# fmt: off
def get_factors(dividend):
    """Return a list of all factors of the given number."""
    
    num = "ops, this was supposed to be a number, not a string"

    return [
        n
        for n in range(1, dividend + num)
        if dividend % n == 0
    ]
# fmt: on

get_factors(134)
```


    ---------------------------------------------------------------------------

    TypeError                                 Traceback (most recent call last)

    <ipython-input-57-88ff78e5b1e0> in <module>
         12 # fmt: on
         13 
    ---> 14 get_factors(134)
    

    <ipython-input-57-88ff78e5b1e0> in get_factors(dividend)
          7     return [
          8         n
    ----> 9         for n in range(1, dividend + num)
         10         if dividend % n == 0
         11     ]


    TypeError: unsupported operand type(s) for +: 'int' and 'str'


We can see the interpreter points at the exact line (9) where the problematic variable is. This can also be useful when creating **pandas pivot tables**, since it's easy to make mistakes the first times you do it.

Lastly, notice the comments `# fmt: off` and `# fmt: on`. Those are because black would reformat that function to a one-line comprehension 😂, and with that comments we can avoid it.


```python
# fmt: off
def get_factors(dividend):
    """Return a list of all factors of the given number."""
    return [
        n
        for n in range(1, dividend + 1)
        if dividend % n == 0
    ]
# fmt: on
```

In the end, formatting is something very personal. After starting to use black I found the consistency of the formatting really helped me be more productive and also understand the code faster we I went back to it.

The trend with Jupyter notebooks is quite clear, more and more tools keep appearing and more people are using them. One of the use cases for notebooks nowadays is teaching, and there's no doubt why, but being able to split your functions and outputs to make it clearer does not mean unreadable code is allowed. I believe many tutorials would be easier to follow only if the code were kept consistent and readable across notebooks.

To sum up, I found using a code formatter while writing code in Jupyter made me a lot more productive and it's something I will thank myself for  if I ever need to reread an old notebook.

**I hope you enjoyed it!**