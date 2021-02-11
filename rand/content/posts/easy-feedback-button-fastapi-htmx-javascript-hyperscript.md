+++
title = "Create a vanishing feedback button with FastAPI and hyperscript"
date = "2021-02-11"
author = "Ricardo Ander-Egg Aguilar"
tags = ["web", "fastapi", "javascript", "htmx", "feedback", "hyperscript", "button", "webapp"]
thumbnail = "img/social/feedback_btn.jpg"
+++

Feedback is one of the most importante things when you are creating a product (probably the most important one!), so it should be easy for users to give feedback. In this post we'll see how to implement a feedback button easily. This exact code is what I'm using at [drwn.io](https://drwn.io/), a little project I'm working on with a friend.

The button does the following: after you use it, it will change its text to "Thank you!", then it will fade out we will have our backend handle the message. Let's see it in action:

![Feedback button in action](https://raw.githubusercontent.com/polyrand/rand/minimal2/rand/static/img/social/feedbackbtn.gif)

The first thing we need is an html button, it's styled using Tailwind CSS. Notice the `_="on click ..."`, this is where we will put our [`hyperscript`](https://hyperscript.org/) code. To use hyperscript, add this to your page's `<head>`.

(Now I'm using version 0.0.3, make sure to update it if you are reading it in the future)

```html
<script src="https://unpkg.com/hyperscript.org@0.0.3"></script>
```

And now our HTML button with hyperscript:

```html
<div id="get-feedback-div" class="inline-flex ml-3 shadow rounded-md transition-opacity duration-500 ease-in">
	<button id="get-feedback-button" _="on click call getFeedback() then set #get-feedback-button.innerText to 'Thank you!' then wait 1000ms then toggle .opacity-0 on #get-feedback-div then wait 600ms then toggle .hidden on #get-feedback-div"
            class="inline-flex items-center justify-center px-5 py-3 text-base font-medium text-blue-600 bg-white border border-transparent rounded-md hover:bg-blue-50">
              Give us feedback
	</button>
</div>
```

We can go step-by-step with hyperscript:

`on click call getFeedback()`: when the button is clicked, execute the function `getFeedback()` (explained later).

`then set #get-feedback-button.innerText to 'Thank you!'`: after that, get the element with id `get-feedback-button` and change the innerText to `'Thank you!'`

`then wait 1000ms`: self-explanatory I guess

`then toggle .opacity-0 on #get-feedback-div`: toggle the CSS class `opacity-0` in the element with id `get-feedback-div`

`then wait 600ms then toggle .hidden on #get-feedback-div`: finally, wait again and toggle the class `hidden` on the element

What I love about hyperscript is:

* The code is all in one place, I don't have to go back and forth between javascript and html files
* It feels like I'm writing in a declarative language. I tell it what I want, and it does it.

Now our `getFeedback()` function. It's straightforward, use `prompt()` to get a message, if the user writes something, send a JSON request to the `/feedback_prompt` endpoint.

```js
function getFeedback() {
    var message = prompt("Write your message here:", "");

    if (message != "") {
        const data = {msg: message};

        fetch('/feedback_prompt', {
            method: 'POST', // or 'PUT'
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify(data),
        })
            .then()
            .catch((error) => {
                alert("There was an error sending your message, please try it later.");
            });
    }
}
```

And now our backed with [FastAPI](https://fastapi.tiangolo.com/) to wrap everything up. We have an endpoint that reads the message and passes it to a `notify()` function. This function can be whatever you want, in my projects it's usually sending the message to telegram, slack and/or email.


```python
from pydantic import BaseModel
from fastapi import FastAPI

app = FastAPI()

# whatever you want to do with the feedback message
# save to the database, send to telegram, slack, email...
def notify(message: str):
return message

class FeedBackPrompData(BaseModel):
    msg: str


@app.post("/feedback_prompt")
async def feedback_post(data: FeedBackPrompData):

    content = f"Feeback from drwn.io:\n\n{data.msg}"

    notify(content)

    return

```

And that's it, we now have a working full-stack system to have a feedback button.