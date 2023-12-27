---
title: Terraform Beginners Workshop
author: >-
  Jason Praful | Senior Software Engineer | Github: jasonpraful
theme:
  override:
    footer:
      style: template
      left: Jason Praful
      right: '{current_slide} / {total_slides}'
    code:
      theme_name: OneHalfDark
      alignment: left
---

## Introduction

This workshop is designed to help you get started with Terraform. It will cover the basics of Terraform, and will give you the skills you need to manage your infrastructure as code.

## Prerequisites

- !**Basic understanding of AWS and Cloud infrastructure**!
- An understanding of what Infrastructure as Code is
- An AWS account
- An AWS IAM user with programmatic access
- AWS CLI installed on your local machine [AWS CLI Installation](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
- Terraform installed on your local machine

```markdown
If you don't have terraform installed on your Mac, you can install it using Homebrew: `brew install terraform`
```

- An IDE or text editor of your choice
- A stable internet connection and access to this github repo

## What is Infrastructure as Code?

Let's get ChatGPT give us the perfect answer

```bash +exec
node chatgpt.js "What is Infrastructure as Code?"
```

<!--end_slide-->

<!--column_layout: [2,1]-->
<!--column: 0-->

# What is Terraform?

Terraform is an infrastructure as code tool created by HashiCorp that lets you define both cloud and on-prem resources in human-readable configuration files that you can version, reuse, and share. You can then use a consistent workflow to provision and manage all of your infrastructure throughout its lifecycle. Terraform can manage low-level components like compute, storage, and networking resources, as well as high-level components like DNS entries and SaaS features.

_**source: https://developer.hashicorp.com/terraform/introm**_

<!--column: 1-->

![Terraform](./images/tf_logo.png)

<!--reset_layout-->

<!--pause-->

## How is this different from CloudFormation?

Terraform is cloud agnostic, meaning it can be used to manage infrastructure on any cloud provider or even multiple cloud providers at once. CloudFormation is a cloud specific tool provided by AWS to manage infrastructure on AWS only. For instance, if you'd want to create your infrastructure on AWS, a DNS record on Cloudflare, and monitoring for these resources in Datadog, you'd have to use CloudFormation, Cloudflare's API, and Datadog's API to manage these resources. With Terraform, you can manage all of these resources in one place.

> Another cloud agnostic tool is Pulumi, which is a competitor to Terraform. Pulumi is a great tool, but it is not as mature as Terraform and is not as widely used.

<!--pause-->

## What will you learn in this workshop?

- Terraform Overview and Setup
- Terraform Basics

  - Providers
  - Resources
  - Variables
  - Outputs

- Terraform State

  - Local State
  - Remote State
  - Terraform Cloud

- Terraform Modules

  - Module Basics
  - Module Sources
  - Module Registry

- **Workshop Example:** Creating a simple lambda, API Gateway, S3 bucket, Cloudfront distribution, and DynamoDB table

**Bonus:** Cloudflare DNS record

**Bonus:** S3 bucket to store your Terraform state

<!--end_slide-->

## Architecture

At the end of this workshop, you will have deployed the following architecture on AWS and Cloudflare:

![Architecture](./images/architecture.png)

The system consists of:

- A Cloudflare DNS record with a CNAME pointing to our Cloudfront distribution (**Bonus**)
- A Cloudfront distribution
  - With S3 bucket as the origin to serve our static website
  - With an endpoint `/api` that points to our API Gateway
- An API Gateway
  - With a lambda integration
  - With a DynamoDB table as the backend
- An S3 bucket to store our static website

<!--end_slide-->

## Terraform Overview

To deploy infrastructure with Terraform:

- **Scope & Code** - Architect your infrastructure and write Terraform configuration.
- **Initialise** - Initialize a working directory containing Terraform configuration files, download providers and plugins. [`terraform init`]
- **Plan** - See what Terraform will do before actually doing it. [`terraform plan`]
- **Apply** - Execute all the changes to the infrastructure. [`terraform apply`]
- **Destroy** - Destroy all the resources created by Terraform. [`terraform destroy`]

### Terraform Setup

How a terraform project is structured

```markdown
.
├── terraform.tfstate # The state file that terraform uses to keep track of the resources it manages
├── main.tf # main terraform file where all the configuration is defined
├── variables.tf # variables used in the main.tf file
└── provider.tf # All the cloud providers used in the project and their configuration (e.g. AWS, Cloudflare and their respective credentials)
```

<!--pause-->

### Terraform Providers

Providers are plugins which are installed to interact with the respective cloud provider. Each provider has its own set of resources exposed which can be used to manage the resources on that cloud provider via Terraform, without which Terraform would have no idea how to interact with the cloud provider. For instance, the AWS provider has resources like `aws_s3_bucket` and `aws_lambda_function` which can be used to manage S3 buckets and Lambda functions respectively.

> Where do I find the list of resources for each provider?

For this workshop, we will be fetching our providers from the public Terraform Registry. You can find the list of resources for each provider on the [Terraform Registry](https://registry.terraform.io/browse/providers). However, you can also publish your own private providers (Not covered in this workshop).

<!--pause-->

### Terraform Resources

Resources are the most important element in Terraform. Each resource block describes one or more infrastructure objects, such as virtual networks, compute instances, or higher-level components such as DNS records. A resource might be a physical component such as an EC2 instance, or it can be a logical resource such as a Heroku application.

Resources are declared in the main Terraform configuration file `main.tf` and are defined by a resource block:

```terraform
resource "aws_s3_bucket" "my_bucket" {
  bucket = "my-bucket"
  acl    = "private"
}
```

The above resource block creates an S3 bucket with the name `my-bucket` and sets the access control list to `private`.

> Where do I find the list of resources for each provider?

Each provider has documented resources on the [Terraform Registry](https://registry.terraform.io/browse/providers). For instance, the [AWS provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs) has a list of all the resources it supports.

<!--pause-->

<!--end_slide-->

## Introduction slide

An introduction slide can be defined by using a front matter at the beginning of the markdown file:

```yaml
---
title: My presentation title
sub_title: An optional subtitle
author: Your name which will appear somewhere in the bottom
---
```

The slide's theme can also be configured in the front matter:

```yaml
---
theme:
  # Specify it by name for built-in themes
  name: my-favorite-theme

  # Otherwise specify the path for it
  path: /home/myself/themes/epic.yaml

  # Or override parts of the theme right here
  override:
    default:
      colors:
        foreground: white
---
```

<!-- end_slide -->

## Headers

Using commonmark setext headers allows you to set titles for your slides (like seen above!):

```
Headers
---
```

# Other headers

All other header types are simply treated as headers within your slide.

## Subheaders

### And more

<!-- end_slide -->

## Slide commands

Certain commands in the form of HTML comments can be used:

# Ending slides

In order to end a single slide, use:

```html
<!-- end_slide -->
```

# Creating pauses

Slides can be paused by using the `pause` command:

```html
<!-- pause -->
```

This allows you to:

<!-- pause -->

- Create suspense.
<!-- pause -->
- Have more interactive presentations.
<!-- pause -->
- Possibly more!

<!-- end_slide -->

## Code highlighting

Code highlighting is enabled for code blocks that include the most commonly used programming languages:

```rust
// Rust
fn greet() -> &'static str {
    "hi mom"
}
```

```python
# Python
def greet() -> str:
    return "hi mom"
```

```cpp
// C++
string greet() {
    return "hi mom";
}
```

And many more!

<!-- end_slide -->

## Dynamic code highlighting

Select specific subsets of lines to be highlighted dynamically as you move to the next slide. Optionally enable line
numbers to make it easier to specify which lines you're referring to!

```rust {1-4|6-10|all} +line_numbers
#[derive(Clone, Debug)]
struct Person {
    name: String,
}

impl Person {
    fn say_hello(&self) {
        println!("hello, I'm {}", self.name)
    }
}

```

<!-- end_slide -->

## Shell code execution

Run commands from the presentation and display their output dynamically.

```bash +exec
terraform show
```

<!-- end_slide -->

## Images

Image rendering is supported as long as you're using iterm2, your terminal supports
the kitty graphics protocol (such as the kitty terminal itself!), or the sixel format.

- Include images in your slides by using `![](path-to-image.extension)`.
- Images will be rendered in **their original size**.
  - If they're too big they will be scaled down to fit the screen.

![](./images/doge.png)

_Picture by Alexis Bailey / CC BY-NC 4.0_

<!-- end_slide -->

## Column layouts

<!-- column_layout: [2, 1] -->

<!-- column: 0 -->

Column layouts let you organize content into columns.

Here you can place code:

```rust
fn potato() -> u32 {
    42
}
```

Plus pretty much anything else:

- Bullet points.
- Images.
- _more_!

<!-- column: 1 -->

![](./images/doge.png)

_Picture by Alexis Bailey / CC BY-NC 4.0_

<!-- reset_layout -->

Because we just reset the layout, this text is now below both of the columns. Code and any other element will now look
like it usually does:

```python
print("Hello world!")
```

<!-- end_slide -->

## Text formatting

Text formatting works as expected:

- **This is bold text**.
- _This is italics_.
- **This is bold _and this is bold and italic_**.
- ~This is strikethrough text.~
- Inline code `is also supported`.
- Links look like this [](https://example.com/)

<!-- end_slide -->

## Other elements

Other elements supported are:

# Tables

| Name   | Taste |
| ------ | ----- |
| Potato | Great |
| Carrot | Yuck  |

# Block quotes

> Lorem ipsum dolor sit amet. Eos laudantium animi ut ipsam beataeet
> et exercitationem deleniti et quia maiores a cumque enim et
> aspernatur nesciunt sed adipisci quis.

# Thematic breaks

A horizontal line by using `---`.

---
