# Non-blind image deconvolution in presence of noise with lexicographic notation
This is a demo script for simple non-blind image deconvolution using lexicographi notation. Since images are 2D data, you need to convert the signal into a vector to express the system by linear expression (matrix- vector multiplication). Lexicographic notation is used for this. </br></br>
In this demo, Gaussian noise is added in the degradation model, which is more realistic. Since noise is random and unknown, it's harder to inverse the degradation process. (Actually, it's impossible to restore the original image exactly.) As you can see from the test, LS solver (min ||Hx-y||) will give terrible results. Instead, CLS solver will present descent results compared to LS. That's the power of regularizing, which enforces the solution smooth in case of CLS. You can control the regularzing parameter, lambda, to see its effect. It affects the peformance. </br></br>
Again, the implementation is based on lexicographic expressions, so, the mathematics looks more straightforward but it is very slow. In practice, you won't want to use this approach, but it's worth to see this. Please  limit the size of image small for the test. </br></br>
I am presenting two solvers, LS and CLS here, and for each solver, two approaches are used: pseudo-inverse, and iterative method. For iterative method, gradient descent method, and Newton's method are implemented. </br>

# Results of image deconvolution
![alt tag](https://github.com/seunghwanyoo/nonblind_deconv_noise_lexico/blob/master/results/orig.jpg)
![alt tag](https://github.com/seunghwanyoo/nonblind_deconv_noise_lexico/blob/master/results/degraded.jpg) </br>
![alt tag](https://github.com/seunghwanyoo/nonblind_deconv_noise_lexico/blob/master/results/ls_p.jpg) 
![alt tag](https://github.com/seunghwanyoo/nonblind_deconv_noise_lexico/blob/master/results/cls_p.jpg) </br>
![alt tag](https://github.com/seunghwanyoo/nonblind_deconv_noise_lexico/blob/master/results/ls_i.jpg) 
![alt tag](https://github.com/seunghwanyoo/nonblind_deconv_noise_lexico/blob/master/results/cls_i.jpg) 


# Description of files/folders
- demo_deconv_lexico.m: test script
- /opt: includes functions for optimization methods
- /func: includes functions for objective function and corresponding gradient function, and hessian function.
- /result: includes result images

# Image degradation and deconvolution
- Degradation model: y = Hx + n
- Deconvolution: <br />
   (1) Least Squares (LS) method: <br />
        min_x 0.5||y-Hx||2 <br />
   (2) Constrained Least Squares (CLS): <br />
        min_x 0.5||y-Hx||2 + 0.5*lambda*||Cx||2 <br />

* Both deconvolution methods are implemented in two ways - pseudo-inverse, and iterative method. 

# Optimization methods
For the iterative method, I implemented two numerical optimization methods <br />
  (1) Gradient descent <br />
  (2) Newton's method <br />

# Contact
Seunghwan Yoo (seunghwanyoo2013@u.northwestern.edu)
