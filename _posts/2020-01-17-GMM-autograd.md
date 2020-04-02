---
title: "Type some title here"
date: 2020-02-04
permalink: /posts/2020/04/some_blog_post/
tags:
  - snippets
---
# Write something clever

Recently I've had to fit a [Mixture of Gaussians](https://en.wikipedia.org/wiki/Mixture_model#Gaussian_mixture_model) to a target *density* instead of individual samples drawn from this density. To be clear, the problem is the following: given a mixture of Gaussian probability density that is evaluated at $N$ points, we want to recover parameters of these Gaussians (i.e. mean $\mu_{i}$, standard deviation $\sigma_{i}$, and a set of mixture weights $\pi_{i}$ that are constrained to be [0, 1] and sum to 1).

```python
# copy paste some code
```

![](/images/GMM_autograd_1_1.png)


What follows is my simple solution using autograd with the following caveats:
* point 1
* point 2
* point 3

## The solution


```python
# again some code
```


### Let's see if the results look right.

```python
# code code code
```

![](/images/GMM_autograd_6_1.png)

You can download this notebook [here](http://mjboos.github.io/files/GMM_autograd.ipynb).

