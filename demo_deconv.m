% This is a demo script for simple non-blind image deconvolution using 
% lexicographi notation. Since images are 2D data, you need to convert the
% signal into a vector to express the system by linear expression (matrix-
% vector multiplication). Lexicographic notation is used for this. 
%
% In this demo, Gaussian noise is added in the degradation model, which is
% more realistic. Since noise is random and unknown, it's harder to inverse
% the degradation process. (Actually, it's impossible to restore the original
% image exactly.) As you can see from the test, LS solver (min ||Hx-y||)
% will give terrible results. Instead, CLS solver will present descent
% results compared to LS. That's the power of regularizing, which enforces
% the solution smooth in case of CLS. You can control the regularzing
% parameter, lambda, to see its effect. It affects the peformance.
%
% Again, the implementation is based on lexicographic expressions, so, the
% mathematics looks more straightforward but it is very slow. In practice,
% you won't want to use this approach, but it's worth to see this. Please 
% limit the size of image small for the test. 
%
% I am presenting two solvers, LS and CLS here, and for each solver, two
% approaches are used: pseudo-inverse, and iterative method. For iterative
% method, gradient descent method, and Newton's method are implemented.
%
% Degradation model: y = Hx + n 
% Deconvolution:
%   (1) LS:  min_x 0.5||y-Hx||2
%   (2) CLS: min_x 0.5||y-Hx||2 + 0.5*lambda*||Cx||2
%   * Both methods are implemented in two ways
%    - pseudo-inverse, iterative method (gradient descent/Newton's method)
%
% Author: Seunghwan Yoo (seunghwanyoo2013@u.northwestern.edu)

clear; close all;
addpath(genpath('.'));

param.opt = 1; % 1:gradient descent, 2:Newton's method
param.blur = 1; % 1:Gaussian kernel, 2:User defined

%% original image
x0_whole = im2double(imread('peppers.png'));%'greens.jpg';
if ndims(x0_whole) > 1
    x0_whole = rgb2gray(x0_whole);
end
x_2d = x0_whole(201:220,201:220); % original image (20x20)
x = x_2d(:); % vectorized

%% blur kernel & laplacian kernel
switch (param.blur)
    case 1
        h0_2d = fspecial('gaussian',[11,11],2);
    case 2
        h0_2d = [1 1 1; 1 1 1; 1 0 0];%h0 = ones(5,5); % blur kernel
        h0_2d = h0_2d/sum(sum(h0_2d)); % blur kernel
end
c0_2d = [0 0.25 0; 0.25 -1 0.25; 0 0.25 0]; % 2D Laplacian for CLS

%% create operator matrix for lexicographic notation
tic; [h,h_2d] = create_lexicoH(x_2d,h0_2d); toc;
tic; [c,c_2d] = create_lexicoH(x_2d,c0_2d); toc;

%% degradation
fprintf('\n== Degradation\n');
y_b = h*x;                            % blurred image (vector)
y_2d_b = reshape(y_b,size(x_2d));     % blurred image (2D);
y_2d = imnoise(y_2d_b,'gaussian',0,0.01);  % noisy image (2D);
y = y_2d(:);                               % noisy image (vector);
figure, imshow(x_2d); title('original');
figure, imshow(y_2d); title('degraded (blur+noise)');


%% non-blind deconvolution (without noise, known y,h, get x)
%%% 1. direct method (pseudo inverse)
%%% 1-1. least squares (LS)
fprintf('== LS with pseudo-inverse\n');
tic; x_ls = h\y; toc;
%(or) x_rec = (h'*h)\(h'*y);
%%% 1-2. constrained least squares (CLS)
fprintf('== CLS with pseudo-inverse\n');
lambda = 1;
tic; x_cls = (h'*h+lambda*(c)'*c)\(h'*y); toc;

%%% results
figure, imshow(reshape(x_ls,size(x_2d))); title('restored (LS)');
figure, imshow(reshape(x_cls,size(x_2d))); title('restored (CLS)');
psnr_ls = psnr(x_2d,reshape(x_ls,size(x_2d)),1);
psnr_cls = psnr(x_2d,reshape(x_cls,size(x_2d)),1);


%%% 2. iterative method
%%% 2-1. LS
fprintf('== LS with an iterative method\n');
opt.linesearch = 1; % 1:wolfe, 2:backtracking
opt.rho = 0.5;      % param for backtracking line search
opt.tol = 10^(-5);  % param for stopping criteria
opt.maxiter = 10^3; % param for max iteration
opt.lambda = lambda;% param for CLS, regularizing param
opt.c = c;          % param for CLS, regularizing matrix
opt.vis = 0;        % param for display, 0:nothing,1:log,2:log+figure
obj.func = @func1;  % func1:LS, func2:CLS w/ I, func3:CLS w/ C
obj.grad = @func1_grad;
obj.hess = @func1_hess;
x0 = y;
switch (param.opt)
    case 1
        [x_ls_i] = opt_gd(obj,x0,opt,y,h);
    case 2
        [x_ls_i] = opt_newton(obj,x0,opt,y,h);
end

%%% 2-2. CLS
fprintf('== CLS with an iterative method\n');
obj.func = @func3; % func1:LS, func2:CLS w/ I, func3:CLS w/ C
obj.grad = @func3_grad;
obj.hess = @func3_hess;
x0 = y;
switch (param.opt)
    case 1
        [x_cls_i] = opt_gd(obj,x0,opt,y,h);
    case 2
        [x_cls_i] = opt_newton(obj,x0,opt,y,h);
end

figure, imshow(reshape(x_ls_i,size(x_2d))); title('restored (iterative LS)');
figure, imshow(reshape(x_cls_i,size(x_2d))); title('restored (iterative CLS)');
psnr_ls_i = psnr(x_2d,x_ls_i,1);
psnr_cls_i = psnr(x_2d,x_cls_i,1);