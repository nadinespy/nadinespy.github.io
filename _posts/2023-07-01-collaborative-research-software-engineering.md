---
output:
  html_document:
    keep_md: true

title: "Collaborative Research Software Engineering in Python"
date: 2023-07-01
permalink: /posts/2023/07/collaborative-research-software-engineering-in-python/
tags:
  - snippets<a name="collaboration_feedback_help"></a>
---

---
output:
  html_document:
    keep_md: true

title: "Collaboration in Science: Happier People ↔  Better Research"
date: 2023-05-25
permalink: /posts/2023/05/collaboration-in-science-happier-people-better-research/
tags:
  - snippets<a name="collaboration_feedback_help"></a>
---



### 90 min tutorial at the Artificial Life conference 2023, 24th July, Sapporo
<br>
<span style="font-size: 25px; color:#2E8B57">**Hello, welcome to the tutorial’s website!**</span> 🙂🍀 

Here, you’ll get an overview on 
* how the tutorial is motivated, 
* what you’ll learn, 
* whom this tutorial is for, and 
* how it will be delivered to you. 
      
Once you’ve read through all of it and made up your mind whether you’d like to participate, you can [register via this link](https://docs.google.com/forms/d/e/1FAIpQLSdW1-Ea1W7uX_3GqGXSkXCFEhxjZ4Xm1yyanDv8TQzvQn4AUg/viewform).

This is a hybrid event – you can participate online or in-person. In order to take part, **you will need to have registered for the [Artificial Life conference](https://2023.alife.org/)** (see the conference’s announcement of the tutorial on the conference page [here](https://2023.alife.org/programme/tutorials/) – 8th tutorial from the top –, though it is an outdated description).

**You can still benefit from this tutorial’s material by going through it yourself** – it is fully documented and includes explanations, code, exercises and solutions, and further resources in this [HackMD main document](https://hackmd.io/@nadinespy/rkteKiVDn) that will be used throughout the event. You may even reuse the material for your own purposes (read the licence at the end of this main document for that matter).

This tutorial has been developed and organized by me, [Nadine Spychala](https://nadinespy.github.io/about-me/), and will be instructed by both me and [Rousslan Dossa](https://dosssman.github.io/). 💥🚀

## How is this tutorial motivated - why collaboration and best research software practices in the first place?

In science, we often want or need to reproduce results to **build knowledge incrementally**. 
* If, for some reason, results can't be reproduced, we at least want to understand the steps taken to arrive at the results, i.e., have transparency on the tools used, code written, computations done, and anything else that has been relevant for generating a given research result.
* However, very often, the steps taken - and particularly the **code written** -, for generating scientific results are **not available**, and/or **not readily implementable**, and/or **not sufficiently understandable**. 

The **consequences** are:
* redundant, or, at worst, wasted work, if reproduction of results is essential, but not possible. This, in the grand scheme of things, greatly slows down scientific progress, 
* code that is not designed to be possibly re-used – and thus scrutinized by others – runs the risk of being flawed and therefore, in turn, produce, flawed results,
* it hampers collaboration – something that becomes increasingly important as 
  - people from all over the world become more inter-connected, 
  - more diversified and specialized knowledge is produced (such that different "parts" need to come together to create a coherent "whole"), 
  - the mere amount of people working in science increases,
  - many great things can't be achieved alone. 

To manage those developments well and avoid working in silos, it is important to have structures at place that enable people to join forces, and respond to and integrate each other’s work well - we need more teamwork.

**Why is it difficult to establish collaborative and best coding practices?** For cultural/scientific practice reasons, and the way academia has set up its incentives (in terms of # of papers where authors are given credit as _individuals_, and prestige of journals plays a role), special value is placed on individual rather than collaborative research outputs. It also discourages doing things right rather than quick-and-dirty. This needs to change. 

## What you’ll learn

This tutorial is a **modified 90-minute mini-version** of the [Intermediate Research Software Development](https://carpentries-incubator.github.io/python-intermediate-development/) course from the [Carpentries Incubator](https://carpentries-incubator.org/).

Here, you'll get 
* little tasters of most sections of the original course - with a **focus on testing and software design** -, 
* as well as some **new learning content, resources and tools** that you won't find in the original course.

This tutorial equips you with a solid foundation for working on software development in a team, using practices that help you write code of higher quality, and that make it easier to develop and sustain code in the future – both by yourself and others. The topics covered concern core, intermediate skills covering important aspects of the software development life-cycle that will be of most use to anyone working collaboratively on code.

**At the start, we’ll address**
* Integrated Development Environments,
* Git and GitHub,
* virtual environments.

**Regarding testing software**, you’ll learn how to
* ensure that results are correct by using unit testing and scaling it up,
* debug code & include code coverage,
* continuous integration.

**Regarding software design**, you’ll particularly learn about 
* object-oriented programming, and 
* functional programming.

**With respect to improving software and preparing it for reuse**, you’ll hear about
* code review, and
* packaging code for release and distribution.

Some of you will likely have written much more complex code than the one you’ll encounter in this tutorial, yet we call the skills taught “intermediate”, because for code development in teams, you need more than just the right tools and languages – you need a strategy (best practices) for how you’ll use these tools _as a team_, or at least for potential re-use by people outside your team (that may very well consist only of you). Thus, it’s less about the complexity of the code as such within a self-contained environment, and more about the complexity that arises due to other people either working on it, too, or re-using it for their purposes. 

**Disclaimer**: rather than this being a tutorial about how to do collaborative research software engineering with a particular Python lens, we use **Python as a vehicle to convey fairly general research software engineering principles**. Skills and tools taught here, while Python-specific, are transferable to other similar tools and programming languages.

## Whom this tutorial is for
The best way to check whether this tutorial is for you is to browse its contents in the [HackMD main document](https://hackmd.io/@nadinespy/rkteKiVDn).

This tutorial is targeted to anyone who 
* has basic programming skills in Python (or any other programming language – it is not very essential to be a Python coder), 
* has some basic familiarity with Git/GitHub, and 
* aims to learn more about best practices and new ways to tackle research software development (as a team). 

It is suitable for all career levels – from students to (very) senior researchers for whom writing code is part of their job, and who either are eager to up-skill and learn things anew, or would like to have a proper refresh and/or new perspectives on research software development. 

<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Page Title</title>
    <style>
      /* Whatever that is inside this <style> tag is all styling for your markup / content structure.
      /* The . with the boxed represents that it is a class */
      .boxed5 {
        background: #F2F2F2;
        color: #4682B4;
        border: 1px solid #4682B4;
        margin: 10px;
        width: 700px;
        padding: 10px;
        border-radius: 10px;
      }
    </style>
  </head>
  <body>
    <!-- This is the markup of your box, in simpler terms the content structure. -->
    <div class="boxed5"  >
     If you’re keen on learning how to restructure existing code such that it is more robust, reusable and maintainable, automate the process of testing and verifying software correctness, and collaboratively work with others in a way that mimics a typical software development process within a team, then *we’re looking forward to you*!
    </div>
  </body>
</html>

## How this tutorial will be delivered

* This tutorial is instructed by both me and [Rousslan Dossa](https://dosssman.github.io/). 
* It is fully documented and includes explanations, code, exercises and solutions, as well as further resources in this [HackMD main document](https://hackmd.io/@nadinespy/rkteKiVDn) which we will use throughout the event. 
* It uses [GitHub CodeSpaces](https://github.com/features/codespaces) – a cloud-powered development environment that one can configure to one’s liking. 
  - Everyone will instantiate a GitHub codespace within their GitHub account and all coding will be done from there - folks will be able to directly apply what is taught in their codespace, work on exercises, and implement solutions. 
  - Thus, the only thing you will need for this tutorial is an account on [GitHub](https://github.com/). More on GitHub CodeSpaces in the [HackMD main document](https://hackmd.io/@nadinespy/rkteKiVDn).

## Acknowledgments
I am grateful to [Matthew Bluteau](https://www.software.ac.uk/about/fellows/matthew-bluteau) as well as [Iain Barrass](https://www.software.ac.uk/about/fellows/iain-barrass) who kindly gave me some feedback on the tutorial. I also want to thank [Masami Yamaguchi](https://www.linkedin.com/in/masami-yamaguchi-93678558/) for giving input on organizational matters.

I am grateful to the [Software Sustainability Institute](https://www.software.ac.uk/) which supports this tutorial via my Fellowship.

Finally, I am very grateful to [Rousslan Dossa](https://dosssman.github.io/) who contributes his skills and expertise by co-instructing the tutorial, and giving valuable input on its content. I am very grateful for the time that he is willing to dedicate to this event, thereby supporting the adoption of best practices in research software engineering. 🙏🌺



