% Setup
clear all; close all;
loadtools;


%% Exercise 1: Sparse Spikes Deconvolution with Matching Pursuits

set_rand_seeds(123456,21);
% dimension of the signal
n = 1024;
% width of the filter
s = 13;
% second derivative of Gaussian
t = -n/2:n/2-1;
h = (1-t.^2/s^2).*exp( -(t.^2)/(2*s^2) );
h = h-mean(h);
% normalize it
h = h/norm(h);
% recenter the filter for periodic boundary conditions
h1 = fftshift(h);

% We display its Fourier transform.
hf = fftshift(real(fft(h1)));

% The actual number of measurement of the seismic imaging is roughly the
% number of Fourier frequencies above the noise level sigma.
% noise level
sigma = .06*max(h);

% Approximate number of measures = 106.
% We compute the filtering matrix. To stabilize the recovery,
% we sub-sample by a factor of 2 the filtering.
% sub-sampling (distance between wavelets)
sub = 2;
% number of atoms in the dictionary
p = n/sub;
% the dictionary, with periodic boundary conditions
[Y,X] = meshgrid(1:sub:n,1:n);
D = reshape( h1(mod(X-Y,n)+1), [n p]);

% Now we create the ideal signal x we would like to recover.
% We design it so that there is a deacreasing distance between the spikes.
% It makes the recovery harder and harder from left to right.
% The amplitude of the spikes and the signs are randoms
% spacing min and max between the spikes.
m = 5; M = 40;
k = floor( (p+M)*2/(M+m) )-1;
spc = linspace(M,m,k)';
% location of the spikes
sel = round( cumsum(spc) );
sel(sel>p) = [];
% randomization of the signs and values
x = zeros(p,1);
si = (-1).^(1:length(sel))'; si = si(randperm(length(si)));
% creating of the sparse spikes signal.
x(sel) = si;
x = x .* (1-rand(p,1)*.5);
w = randn(n,1)*sigma;
y = D*x + w;
% Matching Pursuit
R = y;
xmp = zeros(p,1);
for ii = 1:M
    %Compute and display the correlation.
    C = D'*R;
    %Extract the coefficient with maximal correlation
    [tmp,I] = compute_max(abs(C));
    % update the coefficients
    xmp(I) = xmp(I) + C(I);
    % update the residual
    R = y-D*xmp;
end
% Display computed xmp and original x
clf;
subplot(2,1,1);
plot_sparse_diracs(x); axis('tight');
set_graphic_sizes([], 20);
title('Signal x');
subplot(2,1,2);
plot_sparse_diracs(xmp); axis('tight');
set_graphic_sizes([], 20);
title('Recovered by MP');
pause(0.1)

%% Excercise 2 - Sparse Spikes Deconvolution with Matching Pursuits

R = y;
xmp = zeros(p,1);
for ii = 1:round(1.5*M)
    %Compute and display the correlation.
    C = D'*R;
    %Extract the coefficient with maximal correlation
    [tmp,I] = compute_max(abs(C));
    % update the coefficients
    xmp(I) = xmp(I) + C(I);
    % update the residual
    R = y-D*xmp;
    sel = find(xmp~=0);
    xproj(:,ii) = zeros(p,1);
    xproj(sel,ii) = D(:,sel) \ y;
    err_mp(ii) = norm(x-xproj(:,ii))/norm(x);
end
xproj = xproj(:,(err_mp==min(err_mp)));
clf;
plot(1:1.5*M,err_mp,'.-')
title('Minimize error in xprojection')
ylabel('|x-xproj|/|x|')
xlabel('Iteration')
ylim([0.6,1.3])
% display
clf;
subplot(2,1,1);
plot_sparse_diracs(x);
title('Signal x');
subplot(2,1,2);
plot_sparse_diracs(xproj);
title(['Recovered by MP, err=' num2str(min(err_mp),3)]);

%% Exercise 3 - Sparse Spikes Deconvolution with Matching Pursuits
% Orthogonal matching pursuit improves over matching pursuit by
% back-projecting at each iteration the matching pursuit solution.

%The initialization of OMP is the same as with MP.
R = y;
xomp = zeros(p,1);
for ii = 1:M
    %The coeffcient selection is also done with maximum of correlation.
    C = D'*R;
    [tmp,I] = compute_max(abs(C));
    % update the coefficients
    xomp(I) = xomp(I) + C(I);
    % perform a back projection of the coefficients
    sel = find(xomp~=0);
    xomp = zeros(p,1);
    xomp(sel) = D(:,sel) \ y;
    % update the residual
    R = y-D*xomp;
    err_omp(ii) = norm(x-xomp)/norm(x);
    xompB(:,ii) = xomp;
end
xomp = xompB(:,(err_omp==min(err_omp)));
err_omp = min(err_omp);
clf;
subplot(2,1,1);
plot_sparse_diracs(x);
title('Signal x');
subplot(2,1,2);
plot_sparse_diracs(xomp);
title(['Recovered by OMP, err=' num2str(err_omp,3)]);

%% Exercise 4 - Sparse Spikes Deconvolution with Matching Pursuits
Delta = 15:40;
for ii = 1:length(Delta)
    delta = Delta(ii);
    x1 = zeros(p,1);
    x1(1:delta:p+1-delta) = 1;
    % compute the support and the complementary of the support
    S  =find(x1~=0); % in
    Sc =find(x1==0); % out
    % compute pseudo inverse of atoms within the support
    D1 = D(:,S);
    D1 = (D1'*D1)^(-1) * D1';
    % compute inner product between dual atoms inside the support
    % and atoms outside.
    C = D1 * D(:,Sc);
    % compute the maximum L1 norm, which is the ERC
    ERC(ii) = max( sum( abs(C), 1 ) );
    % display
end
clf; plot(Delta,ERC,'.-')
set_graphic_sizes([], 20);
axis tight
title(sprintf('Minimum scale = %i',Delta(find(ERC < 1,1,'first'))))
xlabel('delta'); ylabel('ERC')
%disp(strcat(['ERC(S)=' num2str(ERC,3)]));