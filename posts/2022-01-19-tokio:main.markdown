---
title: Rust procedural macros, deep dive on tokio:main 
---

I've been doing more Rust in my free time and in particular messing around with [Rust's AWS lambda runtime](https://github.com/awslabs/aws-lambda-rust-runtime). I've also been looking into the [Chalice](https://aws.github.io/chalice/index.html) framework for work. Chalice is a framework for writing serverless applications in Python and it allows you to write nifty little snippets like this:

```python
@app.on_sns_message(topic='MyDemoTopic')
def handle_sns_message(event):
    app.log.debug("Received message with subject: %s, message: %s",
                  event.subject, event.message)
```

Which defines an AWS lambda that will read off of an SNS topic and print log the message. I thought it would be cool to try and define something similar for Rust with syntax like:

```rust
#[lambda_handler(function_name=my_lambda)]
pub fn my_function() {
    println!("Hello, World!");
}
```

This has lead me to trying to understand how to define my own function attributes (the `#[lambda-handler...` stuff above the function definition). These attributes are defined using procedural macros which are defined in functions 
k