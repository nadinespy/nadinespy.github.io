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
  
  # convert variables numeric vectors (if originally provided in dataframe format), and concatenate all in matrix 
  response_variable = data.matrix(response_variable)
  between_subjects_factor = data.matrix(between_subjects_factor)
  within_subjects_factor = data.matrix(within_subjects_factor)
  id = data.matrix(id)
  
  matrix = cbind(response_variable, between_subjects_factor, within_subjects_factor, id)
  colnames(matrix) = c("response_variable", "between_subjects_factor", "within_subjects_factor", "id")
  
  # calculate ANOVA for original dataset
  rm_anova = anova(lme(response_variable ~ between_subjects_factor*within_subjects_factor, random=~1 | id, method="ML"))
  
  # store F-values for each factor as well as their interaction
  FValue_between_subjects_factor = rm_anova[2,3]
  FValue_within_subjects_factor = rm_anova[3,3]
  FValue_interaction = rm_anova[4,3]
  
  # create variables to store F-values from bootstrapped datasets
  FVector_between_subjects_factor = numeric()
  FVector_within_subjects_factor = numeric()
  FVector_interaction = numeric()
  
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
  
  # determine number of repetitions for resampling
  n = number_of_bootstraps
  
  # create vectors containing values for set.seed(), one for resampling the response variable from different levels of the within-subjects factor, one for resampling the between-subjects factor
  index1 = numeric()
  set.seed(10)
  index1 = sample(1:100000,3000,replace=T)
  index2 = numeric()
  set.seed(20)
  index2 = sample(1:100000,3000,replace=T)
  
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
    
    # calculate ANOVA and store F-values for boostrapped data
    rm_anova_simulation = anova(lme(response_variable_for_boot ~ between_subjects_factor_for_boot*within_subjects_factor, random=~1 | id, method="ML", control=lmeControl(singular.ok=TRUE)))  
    
    FVector_between_subjects_factor[i] = as.numeric(rm_anova_simulation[2,3])
    FVector_within_subjects_factor[i] = as.numeric(rm_anova_simulation[3,3])
    FVector_interaction[i] = as.numeric(rm_anova_simulation[4,3])
  }
  
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

