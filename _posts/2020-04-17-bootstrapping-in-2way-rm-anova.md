---
output: 
  html_document:
    keep_md: true
    
title: "A bootstrapping function for a two-way mixed effects ANOVA"
date: 2020-04-20
permalink: /posts/2020/04/bootstrapping-function-for-2way-mixed-effects-ANOVA/
tags:
  - snippets
---

Ever wondered how to use **bootstrapping** for null hypothesis significance testing (NHST) in a **2-way mixed effects model**? 

In my brain-computer interface study (which you can have a look at [here](https://www.frontiersin.org/articles/10.3389/fnhum.2019.00461/full)), I had to do exactly this in order to properly calculate ANOVAs. As I was searching for solutions in the world wide web, I realized that there was no showcase readily applicable to precisely my problem. 

There is a lot on methods of bootstrapping in general (a classical source is this [book](https://books.google.de/books/about/An_Introduction_to_the_Bootstrap.html?id=gLlpIUxRntoC&redir_esc=y) written by Bradley Efron and Robert J. Tibshirani), and some people have developed methods for their studies involving one- and two-way fixed effects models (see, e. g., this [study](https://www.jstor.org/stable/24309529?seq=1) about gene classification), or looked at specific cases of these models (see, e. g., this [study](https://www.sciencedirect.com/science/article/pii/S0047259X12002394) on bootstrapping in models with unequal variances), or written built-in functions in R (e. g., [ANOVA.boot()](https://www.rdocumentation.org/packages/lmboot/versions/0.0.1/topics/ANOVA.boot), which distinguishes between the so-called _residual_ and the _wild_ bootstrap, both of which have different assumptions about the error terms involved), but neither did studies seem to have used bootstrapping in two-way mixed effects models nor have any functions been developed for these sort of models. 

When using bootstrapping in NHST, it all comes down to the question how to create the null distribution based on the real data. Whereas it is quite clear how to treat between-subject factors in this respect, it is less straightforward what to do with within-subject factors. 

A methodological paper written by [Berkovits, Hancock, and Nevitt (2000)](https://journals.sagepub.com/doi/10.1177/00131640021970961) filled the gap: These authors proposed a bootstrapping method for a one-way repeated measure ANOVA design using _centering_ (more about this below).

In the following, I present you a function which outputs the same as anova() for mixed effects models, but with bootstrapped p-values. **Thus, should you need a one-line solution to your bootstrapping problem for two-way mixed effects models (or some inspiration writing your own function) - below you see one way how you can do it.** 

## Why bootstrapping in the first place?
Normally, when performing a statistical test using standard programs or functions (in e. g. R or MATLAB) you assume a theoretical null distribution (e. g. a t-distribution with mean and variance parameters) for your test statistic. This is fine, if you are certain that your data is normally distributed. If you aren't, you should consider to do the test using a **data-driven approximate null distribution**. While all procedures to create such a distribution use a form of resampling from the given data, their exact details depend on the model of interest (i.e., whether you consider a 1-, 2- or n-way model, and whether effects are fixed or random). 

# How to use bootstrapping in a two-way mixed effects ANOVA
Imagine that we want to compare two diets, a moderately low-carb diet and a strict ketogenic diet, w. r. t. weight loss. Let us further assume that each individual trying either the low-carb (LC) or the ketogenic (K) diet undergoes two different consecutive sport interventions, one focusing on weight training (WT), and one focusing on endurance (E), which we also want to compare. Thus, we are interested in the effect of the between-subject factor diet and the effect of the within-subject factor sport (and possibly their interaction) on weight loss. 

Let's create some dummy data representing this model.

## Generating data for our model

```r
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
Here, the data is already provided in the way as required by the function, i.e., the response variable (weight loss) is ordered according to the levels of the within-subjects factor (WT and E). (First all values of weight loss under the condition of WT, and then all values of weight loss under the condition of E.) We also need factor variables indicating the kind of diet and sport intervention as well as a variable indicating the subject. 

Note that our response variable follows a left-skewed distribution (which gives you a reason to perform your tests using bootstrapping).

Now we call bootstrap_2way_rm_anova() - the function I wrote (rm stands for repeated measures).

## bootstrap_2way_rm_anova()
This function requires a response variable, the between-subjects and within-subjects factor, a subject indicator variable as well as the number of bootstraps to be performed (here, we decide for 3000) as input variables. You can pass them either as dataframes or numerical column vectors.

```r
rm_anova_weight_loss_bootstrap = bootstrap_2way_rm_anova(weight_loss, diet, sport_intervention, id, 3000)
```
The output is as given by anova(), but with bootstrap p-values instead:

```r
> rm_anova_weight_loss_bootstrap
                                               numDF denDF   F-value p-value
(Intercept)                                        1    18 117.72286  <.0001
between_subjects_factor                            1    18  59.18527  <.0001
within_subjects_factor                             1    18  16.88298   0.001
between_subjects_factor:within_subjects_factor     1    18  21.22307  <.0001
```
It seems like there is an effect of both diet and sport intervention on weight loss in this data, including an interaction of the two, with greater losses in the E condition (mean ~ 4.2 kg) than in the WT condition (mean ~ 1.9 kg), and greater losses in the K (mean ~ 5.2 kg) than in the LC diet (mean ~ 0.9). (Remember, it's a fictious example.)

Now let's look into the function and see what it exactly does.

The general idea behind using bootstrapping for NHST is to resample from the given data such that we obtain a null distribution against which we test our statistic. By repeating this process a couple of times, we obtain a distribution of F-values, in which we then place the F-value of our original sample to derive a p-value.

In the code, we first allocate variables and perform the statistical test with the original data.

```r
bootstrap_2way_rm_anova <- function(response_variable, between_subjects_factor, within_subjects_factor, id, number_of_bootstraps){

  # convert variables numeric vectors (if originally provided in dataframe format), and concatenate all in matrix 
  response_variable = data.matrix(response_variable)
  between_subjects_factor = data.matrix(between_subjects_factor)
  within_subjects_factor = data.matrix(within_subjects_factor)
  id = data.matrix(id)
  
  matrix = cbind(response_variable, between_subjects_factor, within_subjects_factor, id)
  colnames(matrix) = c("response_variable", "between_subjects_factor", "within_subjects_factor", "id")
  
  # calculate ANOVA for original dataset
  rm_anova = anova(lme(response_variable ~ between_subjects_factor*within_subjects_factor,   random=~1 | id, method="ML"))
  
  # store F-values for each factor as well as their interaction
  FValue_between_subjects_factor = rm_anova[2,3]
  FValue_within_subjects_factor = rm_anova[3,3]
  FValue_interaction = rm_anova[4,3]
  
  # create variables to store F-values from bootstrapped datasets
  FVector_between_subjects_factor = numeric()
  FVector_within_subjects_factor = numeric()
  FVector_interaction = numeric()
```
Now we need to figure out how to resample from the original data such that we obtain a null distribution. The null hypothesis for which we aim to find a distribution representing it is: There are no differences in mean weight loss, i.e., no main effects neither for diet nor sport intervention, and no interaction effect between the two factors. How do we need to do the resampling to obtain a distribution reflecting this situation?

Creating a distribution of weight loss that corresponds to a lack of a difference between the diets is easy - you simply need to shuffle the between-subjects factor. It's not so clear what to do with the within-subject factor, though. Here, it is important to keep in mind what we are interested in: Although sport intervention is a within-subject factor, we want to know whether there is a systematic difference between WT and E _across subjects_, and we want to ignore the difference that is specific to the individual.

What can simulate a distribution of weight loss, in which one does not find an inter-individual difference between WT and E, yet in which intra-individual differences (which turn out to be unsystematic on a group-level) may occur?

We solve this problem by performing a centering of the within-subject factor, i.e., we calculate the mean of weight loss for each level (WT and E), and subtract it from the subjects’ value of weight loss within the respective level. By doing so, we eliminate any group-level difference between WT and E, but retain the possibility of intra-individual differences. 

### Centering
```r
  # derive number of levels in within-subjects factor
  number_of_levels = length(seq(range(within_subjects_factor)[1], range(within_subjects_factor)[2],by=1))
  
  # store all levels in column vector
  codes_for_levels = cbind(seq(range(within_subjects_factor)[1], range(within_subjects_factor)[2],by=1))
  
  # create variable to store means of response variable per level
  vector_with_means = matrix(,nrow=number_of_levels,ncol=1)
  
  # calculate means of response variable for different levels, and substract respective mean from original value
  for (j in 1:number_of_levels){
    vector_with_means[j] = mean(matrix[within_subjects_factor==codes_for_levels[j],"response_variable"])
    for (k in 1:length(matrix[,"response_variable"])){
      if (matrix[k,"within_subjects_factor"] == codes_for_levels[j]){
        matrix[k,"response_variable"] = response_variable[k]-vector_with_means[j]
      }
    }
  }
```
As a next step, we randomly resample with replacement 20 cases (the size of our original sample) of the centered data (from each level 10 cases), whereby we preserve the allocation of WT and E to the same subject, and randomize the assigned diet. This is now our bootstrapped dataset. 

### Resampling
```r
  # determine number of repetitions for resampling
  n = number_of_bootstraps
  
  # create vectors containing values for set.seed(), one for resampling the response variable from different levels of the within-subjects factor, one for resampling the between-subjects factor
  index1 = numeric()
  set.seed(10)
  index1 = sample(1:100000,3000,replace=T)
  index2 = numeric()
  set.seed(20)
  index2 = sample(1:100000,3000,replace=T)
  
  # resampling 
  for (i in 2:n){
    
    # get response variable from matrix
    response_variable_for_boot = matrix[,"response_variable"]
    
    # create variable for sample sizes per level, resamples per level, and the resulting bootstrapped response variable
    number_per_level = matrix(,nrow=number_of_levels, ncol=1)
    list_of_resamples = list()
    new_response_variable = numeric()
    
    for (j in 1:number_of_levels){
      
      # resample from level j
      number_per_level[j] = dim(matrix[within_subjects_factor==codes_for_levels[j],])[1]
      set.seed(index1[i])
      list_of_resamples[[j]] = sample(matrix[within_subjects_factor==codes_for_levels[j], "response_variable"], number_per_level[j],replace = T)
      
      # get indices of level j in matrix
      index_for_response_variable = numeric()
      for (k in 1:length(matrix[,"response_variable"])){
        if (matrix[k,"within_subjects_factor"] == codes_for_levels[j]){
          index_for_response_variable = append(index_for_response_variable,k)
        }
      }
      
      # replace original value of response variable by resampled value
      for (m in 1:number_per_level[j]){
        response_variable_for_boot[index_for_response_variable[m]] = list_of_resamples[[j]][m]
      }
    }
    
    # resample between_subjects factor
    set.seed(index2[i])
    between_subjects_factor_for_boot = sample(between_subjects_factor, nrow(between_subjects_factor), replace = T)
```
We compute a 2-way mixed effects ANOVA from this dataset using anova(lme()), and store the F-value. We repeat this process a number of times, each time calculating and storing the F-value.

### Calculate ANOVA for boostrapped data
```r
    rm_anova_simulation = anova(lme(response_variable_for_boot ~ between_subjects_factor_for_boot*within_subjects_factor, random=~1 | id, method="ML", control=lmeControl(singular.ok=TRUE)))  
    
    # store F-values for bootstrapped data
    FVector_between_subjects_factor[i] = as.numeric(rm_anova_simulation[2,3])
    FVector_within_subjects_factor[i] = as.numeric(rm_anova_simulation[3,3])
    FVector_interaction[i] = as.numeric(rm_anova_simulation[4,3])
  }
```
Now, to determine the p-value, we place the F-value of our original sample within the distribution of F-values that we obtained via repeating the procedure described above. We finally check, if the proportion of F-values larger than the observed one is below 5% (or whatever your threshold in your significance tests might be) or not. Based on this, we can assume either an effect or no effect.

### Locate F-value of original dataset within empirical F-distribution
```r
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
You can download the R markdown file with the above example  [here](https://github.com/nadinespy/nadinespy.github.io/blob/master/files/bootstrapping_in_2way_rm_anova.Rmd), and the source code of bootstrap_2way_rm_anova() [here](https://github.com/nadinespy/nadinespy.github.io/blob/master/files/bootstrap_2way_rm_anova.R).



