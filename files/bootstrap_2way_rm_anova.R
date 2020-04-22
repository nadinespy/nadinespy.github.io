# two-way mixed-effects anova with bootstrapping

# input: response variable, between-subjects factor, within-subjects factor, indices for subjects, number of bootstraps to be performed (optional, with 3000 as default), and number for seed (optional) (all but number of bootstraps and number for seed as column vectors, either numerical or as dataframes);
# output: usual output as given by anova(lme()), but with bootstrap p-values instead.

# example: sample of 18 participatns, two groups (9 patients and 9 controls, between-subjects factor "group"), two experimental conditions per subject (within-subjects factor "condition").
# group = matrix(c(rep(0,9), rep(1,9), rep(0,9), rep(1,9)))
# condition = matrix(c(rep(0, 18), rep(1, 18)))
# id = matrix(c(1:18,1:18))

# load necessary packages
library("nlme")


bootstrap_2way_rm_anova <- function(response_variable, between_subjects_factor, within_subjects_factor, id, number_of_bootstraps = 3000, seednumber = NULL){
  
  # convert variables numeric vectors (if originally provided in dataframe format), and concatenate all in matrix 
  response_variable = data.matrix(response_variable)
  between_subjects_factor = data.matrix(between_subjects_factor)
  within_subjects_factor = data.matrix(within_subjects_factor)
  id = data.matrix(id)
  
  dataset = cbind(response_variable, between_subjects_factor, within_subjects_factor, id)
  colnames(dataset) = c("response_variable", "between_subjects_factor", "within_subjects_factor", "id")
  
  # calculate ANOVA for original dataset
  rm_anova = anova(lme(response_variable ~ between_subjects_factor*within_subjects_factor, random =~1 | id, method="ML"))
  
  # store F-values for each factor as well as their interaction
  FValue_between_subjects_factor = rm_anova[2,3]
  FValue_within_subjects_factor = rm_anova[3,3]
  FValue_interaction = rm_anova[4,3]
  
  # create variables to store F-values from bootstrapped datasets
  FVector_between_subjects_factor = numeric()
  FVector_within_subjects_factor = numeric()
  FVector_interaction = numeric()
  
  # derive number of levels in within-subjects factor
  number_of_levels = length(seq(range(within_subjects_factor)[1], range(within_subjects_factor)[2], by=1))
  
  # store all levels in column vector
  codes_for_levels = cbind(seq(range(within_subjects_factor)[1], range(within_subjects_factor)[2], by=1))
  
  # create variable to store means of response variable per level
  vector_with_means = matrix(, nrow=number_of_levels, ncol=1)
  
  # calculate means of response variable for each level, and substract respective mean from original value
  for (j in 1:number_of_levels){
    vector_with_means[j] = mean(dataset[within_subjects_factor==codes_for_levels[j],"response_variable"])
    dataset[within_subjects_factor == codes_for_levels[j],"response_variable"] = dataset[within_subjects_factor==codes_for_levels[j],"response_variable"]-vector_with_means[j]
  }
  
  # resampling
  # set seed if provided
  if (!is.null(seednumber)){
    set.seed(seednumber)
  }

  for (i in 1:number_of_bootstraps){

    copy_response_variable = dataset[,"response_variable"]
    
    # get sample-size resample of the subjects
    resample_subjects = sample(dataset[, "id"], length(response_variable)/number_of_levels, replace = T)
      
    # create variables to store response variables and corresponding within-subjects factor
    response_variable_for_boot = numeric()
    within_subjects_factor_for_boot = numeric()
    
    # for each subject contained in resample_subjects, extract response variables of all levels, store corresponding within-subjects factor
    for (p in 1:length(resample_subjects)){
      for (w in 1:length(copy_response_variable)){
        if (dataset[w,"id"] == resample_subjects[p]){
          response_variable_for_boot = append(response_variable_for_boot, copy_response_variable[w])
          within_subjects_factor_for_boot = append(within_subjects_factor_for_boot, within_subjects_factor[w])
        }
      }
    }
    
    # resampling of the between_subjects factor (as often as the sample-size), and replicating it as many times as the number of levels of within-subject factor
    between_subjects_factor_for_boot = sample(between_subjects_factor, nrow(between_subjects_factor)/number_of_levels, replace = T)
    between_subjects_factor_for_boot = rep(between_subjects_factor_for_boot, each=number_of_levels)
    
    # adjust indicator variable according to response_variable_for_boot (replicate the number as many times as the number of levels of within-subject factor)
    id_for_boot = rep(seq(1,length(response_variable)/number_of_levels,1), each=number_of_levels)
    
    # calculate ANOVA and store F-values for boostrapped data
    rm_anova_simulation = anova(lme(response_variable_for_boot ~ between_subjects_factor_for_boot * within_subjects_factor_for_boot, random = ~1 | id_for_boot, method="ML", control = lmeControl(singular.ok = TRUE)))  
  
    FVector_between_subjects_factor[i] = as.numeric(rm_anova_simulation[2,3])
    FVector_within_subjects_factor[i] = as.numeric(rm_anova_simulation[3,3])
    FVector_interaction[i] = as.numeric(rm_anova_simulation[4,3])
  }
  
  # bootstrap p-value for between-subjects factor: check proportion of F-values larger than the observed one
  bootstrap_pValue_between_subjects_factor = length(which(FVector_between_subjects_factor > FValue_between_subjects_factor))/number_of_bootstraps
  
  # bootstrap p-value for within-subjects factor: check proportion of F-values larger than the observed one
  bootstrap_pValue_within_subjects_factor = length(which(FVector_within_subjects_factor > FValue_within_subjects_factor))/number_of_bootstraps
  
  # bootstrap p-value for interaction: check proportion of F-values larger than the observed one
  bootstrap_pValue_interaction = length(which(FVector_interaction > FValue_interaction))/number_of_bootstraps
  
  # concatenate all p-values
  FValues = rbind(FValue_between_subjects_factor, FValue_within_subjects_factor, FValue_interaction)
  bootstrap_pValues = rbind(bootstrap_pValue_between_subjects_factor, bootstrap_pValue_within_subjects_factor, bootstrap_pValue_interaction)
  
  # replace p-values in original anova
  rm_anova[2:nrow(rm_anova), "p-value"] = bootstrap_pValues
  return(rm_anova)
}

