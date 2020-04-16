# two-way mixed-effects anova with bootstrapping for comparing means, for either two or three levels in the within-subjects factor

# input: response variable ordered according to levels of within-subjects factor (i.e., first all values of first level, second all values of second level etc.), between-subjects factor, within-subjects factor, indices for subjects (all as column vectors, either numerical or as dataframes);
# output: usual output as given by anova(), but with bootstrap p-values instead.

# example: sample of 18 participatns, two groups (9 patients and 9 controls, between-subjects factor "group"), two experimental conditions per subject (within-subjects factor "condition").
# group = matrix(c(rep(0,9), rep(1,9), rep(0,9), rep(1,9)))
# condition = matrix(c(rep(0, 18), rep(1, 18)))
# id = matrix(c(1:18,1:18))

# load necessary packages
library("nlme")


bootstrap_2way_rm_anova <- function(response_variable, between_subjects_factor, within_subjects_factor, id, number_of_bootstraps){
  
  response_variable = data.matrix(response_variable)
  between_subjects_factor = data.matrix(between_subjects_factor)
  within_subjects_factor = data.matrix(within_subjects_factor)
  id = data.matrix(id)
  
  rm_anova = anova(lme(response_variable ~ between_subjects_factor*within_subjects_factor, random=~1 | d, method="ML"))
  
  FValue_between_subjects_factor = rm_anova[2,3]
  FValue_within_subjects_factor = rm_anova[3,3]
  FValue_interaction = rm_anova[4,3]
  
  FVector_between_subjects_factor = numeric()
  FVector_within_subjects_factor = numeric()
  FVector_interaction = numeric()
  
  number_of_levels = length(seq(range(within_subjects_factor)[1], range(within_subjects_factor)[2],by=1))
  split = nrow(response_variable)/number_of_levels
  
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
  
  n = number_of_bootstraps
  
  index1 = numeric()
  set.seed(10)
  index1 = sample(1:100000,3000,replace=T)
  index2 = numeric()
  set.seed(20)
  index2 = sample(1:100000,3000,replace=T)
  
  for (i in 1:n){
    
    if (number_of_levels ==3){
      set.seed(index1[i])
      resample_response_from_third_level = sample(response_variable[(split*2+1):(split*3)], split, replace = T)  
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
    set.seed(index2[i])
    resample_between_subjects_factor = t(t(sample(between_subjects_factor, nrow(between_subjects_factor), replace = T)))
    
    if (number_of_levels ==3){
      resample_response = rbind(t(t(resample_response_from_first_level)),t(t(resample_response_from_second_level)), t(t(resample_response_from_third_level)))
    } else {resample_response = rbind(t(t(resample_response_from_first_level)),t(t(resample_response_from_second_level)))
    }
    
    rm_anova_simulation = anova(lme(resample_response ~ resample_between_subjects_factor*within_subjects_factor, random=~1 | d, method="ML", control=lmeControl(singular.ok=TRUE)))  
    
    FVector_between_subjects_factor[i] = as.numeric(rm_anova_simulation[2,3])
    FVector_within_subjects_factor[i] = as.numeric(rm_anova_simulation[3,3])
    FVector_interaction[i] = as.numeric(rm_anova_simulation[4,3])
  }
  
  # bootstrap p-value for between-subjects factor
  bootstrap_pValue_between_subjects_factor = length(which(FVector_between_subjects_factor>FValue_between_subjects_factor))/n
  
  # bootstrap p-value for within-subjects factor
  bootstrap_pValue_within_subjects_factor = length(which(FVector_within_subjects_factor>FValue_within_subjects_factor))/n
  
  # bootstrap p-value for interaction
  bootstrap_pValue_interaction = length(which(FVector_interaction>FValue_interaction))/n
  
  
  FValues = rbind(FValue_between_subjects_factor, FValue_within_subjects_factor, FValue_interaction)
  bootstrap_pValues = rbind(bootstrap_pValue_between_subjects_factor, bootstrap_pValue_within_subjects_factor, bootstrap_pValue_interaction)
  
  rm_anova[2:nrow(rm_anova), "p-value"] = bootstrap_pValues
  return(rm_anova)
}

