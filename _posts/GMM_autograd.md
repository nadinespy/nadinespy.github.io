
# Probability density fitting of a Mixture of two Gaussians via autograd

Recently I've had to fit a [Mixture of two Gaussians](https://en.wikipedia.org/wiki/Mixture_model#Gaussian_mixture_model) to a target *density* instead of individual samples drawn from this density.
Googling revealed that at least [one other person](https://stats.stackexchange.com/questions/226504/fit-gaussian-mixture-model-directly-to-the-mixture-density) faced this particular problem too, but there was no code readily available.

To be clear, the problem is the following: given a mixture of Gaussian probability density that is evaluated at $N$ points, we want to recover parameters of these Gaussians (i.e. mean $\mu_{i}$, standard deviation $\sigma_{i}$, and a set of mixture weights $\pi_{i}$ that are constrained to be [0, 1] and sum to 1).

For two Gaussians our objective is to find parameters of a Gaussian mixture that make its density match the blue line below (evaluated at $N=25$ points).


```python
from scipy import stats
import autograd.numpy as np
import matplotlib.pyplot as plt
%matplotlib inline
m1 = 15
m2 = 20
std1 = 1
std2 = 1
pi = 0.8
gridmin, gridmax, N = 0, 25, 75
grid =  np.arange(gridmin, gridmax, (gridmax-gridmin)/N)

data = np.array([pi*stats.norm.pdf(t, loc=m1, scale=std1)+(1-pi)*stats.norm.pdf(t, loc=m2, scale=std2)
                for t in grid])
plt.plot(data, label='Mixture probability density')
plt.xlabel('Grid points')
plt.ylabel('Density')
```




    Text(0, 0.5, 'Density')




![png](images/GMM_autograd_1_1.png)


What follows is my simple solution using autograd with the following caveats:
* I estimate the distance between target probability density and our density via an $L2$ distance
* I circumvent setting up explicit constraints on $\pi$ by using the logit of $\pi$, which automatically constrains the 2 Gaussian case, but this has to be adapted for more Gaussians
* I choose two Gaussians, i.e. I don't estimate the optimal number of Gaussians; to do so one can use cross-validation
* Placing a prior on individual parameters might help
* Initial parameters matter, it can be necessary to run the procedure multiple times and choose the solution with smallest loss

## The solution


```python
import autograd.numpy as np
from autograd import grad
from autograd import hessian_vector_product
from autograd.misc.flatten import flatten_func
from functools import partial

# we have to defince our own Gaussian pdf because autograd does not like the one provided by scipy
def pdf(x, m, std):
    return (1/(std*np.sqrt(2*np.pi)))*np.exp(-0.5*((x-m)/std)**2)

def gmm(t, m1, m2, std1, std2, pi):
    '''Returns the density of a mixture of 2 Gaussians model estimated at grid point t.
    m1 and m2 are means of the two Gaussian
    std1 and std2 are logarithms of the standard deviation of the two Gaussians
    pi is the mixing probability (since it is constrained to sum to one we only need one in the 2 Gaussian case)'''
    return pi*pdf(t, m1, np.exp(std1))+(1-pi)*pdf(t, m2, np.exp(std2))

def loss_func(target_density, params, grid=25):
    '''Loss function for the model,
    target_density is an array of values for the target density,
    params is a list that contains m1, m2, std1, std2 and the logit of pi,
    grid can either be an int (in which case it is the argument supplied to range) or an iterable'''
    m1, m2, std1, std2, pi_prop = params
    if type(grid)==int:
        grid = range(grid)
    p = np.exp(pi_prop) / (np.exp(pi_prop) + 1)
    our_density = np.array([gmm(t, m1, m2, std1, std2, p)
                for t in grid])
    return np.sum((target_density-our_density)**2)

# use partial to build a loss function that uses our data and grid structure
objective = partial(loss_func, data, grid=grid)

# get a random guess for the mean
randmean = np.random.randint(0, 25, 2).astype('float').tolist()
initial_params = randmean + [0., 0., 1.]

# flatten everything so it plays nice with the optimizer
flattened_obj, unflatten, flattened_init_params =\
        flatten_func(objective, initial_params)

# get jacobian
gradf = grad(flattened_obj)

# now use conjugate gradient descent
from scipy.optimize import minimize
res=minimize(flattened_obj, flattened_init_params,
         jac=gradf, method='BFGS')

m1_l, m2_l, std1_l, std2_l, pi_prop = res.x
p = np.exp(pi_prop) / (np.exp(pi_prop) + 1)
print('True parameters {}'.format([m1, m2, std1, std2, pi]))
print('Recovered parameters {}'.format([m1_l, m2_l, np.exp(std1_l), np.exp(std2_l), p]))
```

    True parameters [15, 20, 1, 1, 0.8]
    Recovered parameters [19.99999432837761, 14.999999725601715, 1.0000045596166873, 0.9999995374426933, 0.1999986294444458]


### Let's see if the results look right.


```python
our_density = np.array([p*stats.norm.pdf(t, loc=m1_l, scale=np.exp(std1_l))+(1-p)*stats.norm.pdf(t, loc=m2_l, scale=np.exp(std2_l))
                for t in grid])

plt.plot(our_density, label='Estimated probability density', linewidth=3)
plt.plot(data, 'r-.', label='Mixture probability density')
plt.xlabel('Grid points')
plt.ylabel('Density')
plt.legend()
```




    <matplotlib.legend.Legend at 0x7fc46fe75310>




![png](images/GMM_autograd_6_1.png)

