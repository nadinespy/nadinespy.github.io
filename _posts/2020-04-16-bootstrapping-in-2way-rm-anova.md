---
output: 
  html_document:
    keep_md: true
    
title: "A bootstrapping function for a two-way mixed effects ANOVA"
date: 2020-02-04
permalink: /posts/2020/04/some_blog_post/
tags:
  - snippets
---
% # Write something clever

Ever wondered how to use **bootstrapping** for null hypothesis significance testing (NHST) in a **2-way mixed effects model**? In my brain-computer interface study (which you can have a look at [here](https://www.frontiersin.org/articles/10.3389/fnhum.2019.00461/full)), I had to do exactly this in order to properly calculate ANOVAs. As I was searching for solutions in the world wide web, I realized that there was no showcase readily applicable to precisely my problem. 

There is a lot on methods of bootstrapping in general (a classical source is this [book](https://books.google.de/books/about/An_Introduction_to_the_Bootstrap.html?id=gLlpIUxRntoC&redir_esc=y) written by Bradley Efron and Robert J. Tibshirani), and some people have developed methods for their studies involving one- and two-way fixed effects models (see, e. g., this [study](https://www.jstor.org/stable/24309529?seq=1) about gene classification), or looked at specific cases of these models (see, e. g., this [study](https://www.sciencedirect.com/science/article/pii/S0047259X12002394) on bootstrapping in models with unequal variances), or written built-in functions in R (e. g., the R built-in function [ANOVA.boot()](https://www.rdocumentation.org/packages/lmboot/versions/0.0.1/topics/ANOVA.boot), which distinguishes between the so-called _residual_ and the _wild_ bootstrap, both of which have different assumptions about the error terms involved), but neither did studies seem to have used bootstrapping in two-way mixed effects model nor have any functions been developed for this sort of model. 

When using bootstrapping in NHST, it all comes down to the question how to create the null distribution based on the real data. Whereas it is quite clear how to treat between-subject factors in this respect, it is less straightforward what to do with within-subject factors. 

A methodological paper written by [Berkovits, Hancock, and Nevitt (2000)](https://journals.sagepub.com/doi/10.1177/00131640021970961) filled the gap: These authors proposed a bootstrapping method for a one-way repeated measure ANOVA design using so-called _centering_ (more about this below).

In the following, I present you a function which outputs the same as anova(), but with bootstrapped p-values. Thus, should you need a one-line solution to your bootstrapping problem for two-way mixed effects models (or some inspiration writing your own function) - below you see one way how you can do it. 

But first of all...

## Why bootstrapping in the first place?
Normally, when performing a statistical test using standard programs or functions (in e. g. R or MATLAB) you assume a theoretical null distribution (e. g. a t-distribution with mean and variance parameters) for your test statistic. This is fine, if you are certain that your data is normally distributed. If you aren't, you should consider to do the test using a **data-driven approximate null distribution**. While all procedures to create such a distribution use a form of resampling from the given data, their exact details depend on the model of interest (i.e., whether you consider a 1-, 2- or n-way model, and whether effects are fixed or random). 

# How to use bootstrapping in a two-way mixed effects ANOVA
Imagine that we want to compare two diets, a moderately low-carb diet and a strict ketogenic diet (the latter having caused strong debates in recent years - see e. g. this recent [article](https://www.nytimes.com/2020/01/02/style/self-care/keto-diet-explained-benefits.html) from the New York Times), w. r. t. weight loss. Let us further assume that each individual trying either the low-carb (LC) or the ketogenic (K) diet undergoes two different consecutive sport interventions, one focusing on weight training (WT), and one focusing on endurance (E), which we also want to compare. Thus, we are interested in the effect of the between-subject factor diet and the effect of the within-subject factor sport (and possibly their interaction) on weight loss. 

Let's create some dummy data representing this model.

## Generating data for our model

```{r}
# number of subjects
n = 20

# number of subjects
n = 20

set.seed(10)
a <- rnorm(29, 2, 2)
set.seed(20)
b <- rnorm(3, 6, 1)
set.seed(30)
c <- rnorm(8, 8, 1)
weight_loss <- cbind(c(a, b, c))                                    # in kg
sport_intervention = matrix(c(rep(0, n), rep(1, n)))                # 0 codes for WT, 1 for E
diet = matrix(c(rep(0,n/2), rep(1,n/2), rep(0,n/2), rep(1,n/2)))    # 0 codes for LC, 1 for K
id = matrix(c(1:n,1:n))

```
Here, the data is already provided in the way as required by the function, i.e., the response variable (weight loss) is ordered according to the levels of the within-subjects factor (WT and E) (first all values of weight loss under the condition of WT, and then all values of weight loss under the condition of E). We also need factor variables indicating the kind of diet and sport intervention as well as a variable indicating the subject. 

Note that our response variable follows a left-skewed distribution (which gives you a reason to perform your tests using bootstrapping).

Now we call bootstrap_2way_rm_anova() - the function I wrote (rm stands for repeated measures).

## bootstrap_2way_rm_anova()
This function requires a response variable, the between-subjects and within-subjects factor, a subject indicator variable as well as the number of bootstraps to be performed (here, we decide for 3000) as input variables. 

```{r}
rm_anova_weight_loss_bootstrap = bootstrap_two_way_rm_anova(weight_loss, diet, sport_intervention, id, 3000)
```
The output is as given by anova(), but with bootstrap p-values instead:

```{r}
> rm_anova_weight_loss_bootstrap
                                               numDF denDF   F-value p-value
(Intercept)                                        1    18 117.72286  <.0001
between_subjects_factor                            1    18  59.18527  <.0001
within_subjects_factor                             1    18  16.88298   0.001
between_subjects_factor:within_subjects_factor     1    18  21.22307  <.0001
```
It looks like there is an effect of both diet and sport intervention on weight loss in this dataset, including an interaction of the two, with greater losses in the E condition (mean ~ 4.2 kg) than in the WT condition (mean ~ 1.9 kg), and greater losses in the K (mean ~ 5.2 kg) than in the LC diet (mean ~ 0.9) - seems plausible. ;) 

Now let's look into the function and see what it exactly does.

## The general idea 

The objective is to resample from the given data such that we obtain a null distribution against which we test our statistic in question. In our case, it's the F-value (remember, we want to calculate an ANOVA). The null hypothesis for which we aim to find a distribution representing it is: There are no differences in mean weight loss, i.e., no main effects neither for diet not sport intervention, and no interaction effect between the two factors. How do we need to resample from the data such that we obtain a distribution reflecting this situation?

Creating a distribution of weight loss that corresponds to a lack of a difference between the diets is easy - you simply need to shuffle the between-subjects factor. It's not so clear what to do with the within-subject factor, though. Here, it is important to keep in mind what we are interested in: Although sport intervention is a within-subject factor, we want to know whether there is a systematic difference between WT and E _across subjects_, and we want to ignore the difference that is specific to the individual.

What can simulate a distribution of weight loss, in which one does not find an inter-individual difference between WT and E, yet in which intra-individual differences (which turn out to be unsystematic on a group-level) may occur?

We solve this problem by performing a centering of the within-subject factor, i.e., we calculate the mean of weight loss for each level (WT and E), and subtract it from the subjects’ value of weight loss within the respective level. By doing so, we eliminate any group-level difference between WT and E, but retain the possibility of intra-individual variation. 

As a next step, we randomly resample with replacement 20 cases (the size of our original sample) of the centered data, while preserving the allocation of WT and E to the same subject, and randomizing the assigned diet. This is now our _bootstrapped_ dataset. We compute a 2-way mixed ANOVA from this dataset, and store the F-value. We repeat this process a number of times, each time calculating and storing the F-value. Now, to determine the p-value, we place the F-value of our original sample within the distribution of F-values that we obtained via repeating the procedure described above. Finally, we check, if the proportion of F-values larger than the observed one is below 5% (or whatever your threshold in your significance tests might be) or not. Based on this, we can assume either an effect or no effect.

```{r}
bootstrap_2way_rm_anova <- function(response_variable, between_subjects_factor, within_subjects_factor, id, number_of_bootstraps){
```
### allocate variables and perform statistical test with original data
```{r}
  # convert variables numeric vectors (if originally provided in dataframe format) 
  response_variable = data.matrix(response_variable)
  between_subjects_factor = data.matrix(between_subjects_factor)
  within_subjects_factor = data.matrix(within_subjects_factor)
  id = data.matrix(id)
  
  # calculate ANOVA for original dataset
  rm_anova = anova(lme(response_variable ~ between_subjects_factor*within_subjects_factor,   random=~1 | d, method="ML"))
  
  # store F-values for each factor as well as their interaction
  FValue_between_subjects_factor = rm_anova[2,3]
  FValue_within_subjects_factor = rm_anova[3,3]
  FValue_interaction = rm_anova[4,3]
  
  # create variables to store F-values from bootstrapped datasets
  FVector_between_subjects_factor = numeric()
  FVector_within_subjects_factor = numeric()
  FVector_interaction = numeric()
```
### centering
```{r}
  # derive number of levels in within-subjects factor (either 2 or 3)
  number_of_levels = length(seq(range(within_subjects_factor)[1], range(within_subjects_factor)[2],by=1))
  split = nrow(response_variable)/number_of_levels
  
  # centering the within-subjects factor: calculate means of response variable for different levels of within-subject factor, and subtract them from the respective level (either for the case of 2 or 3 levels)
  if (number_of_levels ==3){
    mean1 = mean(response_variable[1:split])
    mean2 = mean(response_variable[(split+1):(split*2)])
    mean3 = mean(response_variable[(split*2+1):(split*3)])
    
    response_variable[1:split] = response_variable[1:split]-mean1
    response_variable[(split+1):(split*2)] = response_variable[(split+1):(split*2)]-mean2
    response_variable[(split*2+1):(split*3)] = response_variable[(split*2+1):(split*3)]-mean3
  } else {
    mean1 = mean(response_variable[1:split])
    mean2 = mean(response_variable[(split+1):(split*2)])
    
    response_variable[1:split] = response_variable[1:split]-mean1
    response_variable[(split+1):(split*2)] = response_variable[(split+1):(split*2)]-mean2
  }
```
### resampling
```{r}
  # determine number of repetitions for resampling
  n = number_of_bootstraps
  
  index1 = numeric()
  set.seed(10)
  index1 = sample(1:100000,3000,replace=T)
  index2 = numeric()
  set.seed(20)
  index2 = sample(1:100000,3000,replace=T)
  
  # resampling 
  for (i in 1:n){
    # response variable after centering
    if (number_of_levels ==3){
      set.seed(index1[i])
      resample_response_from_third_level =   sample(response_variable[(split*2+1):(split*3)], split, replace = T)  
      set.seed(index1[i])
      resample_response_from_first_level = sample(response_variable[1:split], split, replace = T)
      set.seed(index1[i])
      resample_response_from_second_level = sample(response_variable[(split+1):(split*2)], split, replace = T)
    } else {
      set.seed(index1[i])
      resample_response_from_first_level = sample(response_variable[1:split], split, replace = T)
      set.seed(index1[i])
      resample_response_from_second_level = sample(response_variable[(split+1):(split*2)], split, replace = T)
    }
    # shuffling of between-subject factor
    set.seed(index2[i])
    resample_between_subjects_factor = t(t(sample(between_subjects_factor, nrow(between_subjects_factor), replace = T)))
    
    # concatenate response variable from the single levels
    if (number_of_levels ==3){
      resample_response = rbind(t(t(resample_response_from_first_level)),t(t(resample_response_from_second_level)), t(t(resample_response_from_third_level)))
    } else {resample_response = rbind(t(t(resample_response_from_first_level)),t(t(resample_response_from_second_level)))
    }
```
### calculate ANOVA for boostrapped data
```{r}
    # recalculate anova using new response variable and shuffled between subject-factor
    rm_anova_simulation = anova(lme(resample_response ~ resample_between_subjects_factor*within_subjects_factor, random=~1 | d, method="ML", control=lmeControl(singular.ok=TRUE)))  
    
    # store F-values for each factor as well as their interaction
    FVector_between_subjects_factor[i] = as.numeric(rm_anova_simulation[2,3])
    FVector_within_subjects_factor[i] = as.numeric(rm_anova_simulation[3,3])
    FVector_interaction[i] = as.numeric(rm_anova_simulation[4,3])
  }
```
### locate F-value of original dataset within empirical F-distribution
```{r}
  # bootstrap p-value for between-subjects factor: check proportion of F-values larger than the observed one
  bootstrap_pValue_between_subjects_factor = length(which(FVector_between_subjects_factor>FValue_between_subjects_factor))/n
  
  # bootstrap p-value for within-subjects factor: check proportion of F-values larger than the observed one
 bootstrap_pValue_within_subjects_factor = length(which(FVector_within_subjects_factor>FValue_within_subjects_factor))/n
  
  # bootstrap p-value for interaction: check proportion of F-values larger than the observed one
  bootstrap_pValue_interaction = length(which(FVector_interaction>FValue_interaction))/n
  
  # concatenate all p-values
  FValues = rbind(FValue_between_subjects_factor, FValue_within_subjects_factor, FValue_interaction)
  bootstrap_pValues = rbind(bootstrap_pValue_between_subjects_factor, bootstrap_pValue_within_subjects_factor, bootstrap_pValue_interaction)
  
  # replace p-values in original anova
  rm_anova[2:nrow(rm_anova), "p-value"] = bootstrap_pValues
  return(rm_anova)
}
```

```python
# copy paste some code
```
```python
# ![](/images/GMM_autograd_1_1.png)
```



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
```python
# ![](/images/GMM_autograd_6_1.png)
```

You can download the R markdown file [here](http://mjboos.github.io/files/GMM_autograd.ipynb).





The way the F-distribution is obtained is different to how one would yield it using [boot()](https://www.statmethods.net/advstats/bootstrapping.html). In bootstrap_2way_rm_anova(), a new null distribution is created using centering, shuffling and resampling (with replacement) the number of times you want to bootstrap the F-statistic, and the F-statistic is calculated for each of the newly created null distributions. Using boot(), only one null distribution would be created, from which resamples with replacement would be drawn the number of times you want to do the bootstrapping, and the F-statistic would calculated for each of the resamples from the same null data. A second version of my bootstrapping function, which implements boot() didn't work most of the time, as it  Out of curiosity, I integrated boot() in a second version of my bootstrapping function, and it didn't work most of the time, but gave me singularity errors. 



