---
permalink: /
title: "Hi there!"
excerpt: "Hi there!"
author_profile: true
redirect_from:
  - /about/
  - /about.html
---

I'm Nadine. I have 7+ years of experience across AI/ML, data science, research and research software engineering. I've built LLM-based software, researched complex systems and worked on technical AI safety.

I'm also an ultra mountain runner and engage in photography.

In this blog, I share my work, thoughts and tools. Read (a lot) more about me [here](https://nadinespy.github.io/about-me/). 

## Latest posts

{% for post in site.posts limit:3 -%}
* {{ post.date | date: "%-d %B %Y" }} – [{{ post.title }}]({{ post.url | relative_url }})
{% endfor %}

[Browse all posts →]({{ '/year-archive/' | relative_url }})




