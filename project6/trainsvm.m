function [svmclassify,sv_i,alphas]=trainsvm(xTr,yTr, C,ktype,kpar);
% function [svmclassify,sv_i,alphas]=trainsvm(xTr,yTr, C,ktype,kpar);
% INPUT:	
% xTr : dxn input vectors
% yTr : 1xn input labels
% C   : regularization constant (in front of loss)
% ktype : (linear, rbf, polynomial)
% 
% Output:
% svmclassify : a classifier (scmclassify(xTe) returns the predictions on xTe)
% sv_i : indices of support vecdtors
% alphas : a nx1 vector of alpha values
%
% Trains an SVM classifier with kernel (ktype) and parameters (C,kpar)
% on the data set (xTr,yTr)
%

if nargin<5,kpar=1;end;
yTr=yTr(:);
svmclassify=@(xTe) (rand(1,size(xTe,2))>0.5).*2-1; %% classify everything randomly
n=length(yTr);



disp('Generating Kernel ...')
% 
K = computeK(ktype, xTr, xTr, kpar);
%
disp('Solving QP ...')
%
[H,q,Aeq,beq,lb,ub]=generateQP(K,yTr',C);
x0=zeros(n,1);
options=optimoptions(@quadprog,'Algorithm','active-set')
[alphas, OBJ, INFO, LAMBDA] = quadprog (H, q,Aeq.*0,beq.*0,Aeq,beq,lb, ub,x0,options);
%it seems the X0 is useless,because of the "interior-point-convex' algorithm

%
alphas(alphas<0)=0;
disp('Recovering bias')
%
% YOUR CODE 
bias = recoverBias(K, yTr, alphas, C);
%
disp('Extracting support vectors ...')
%
% YOUR CODE 
sv_i=find(alphas>0.0001&alphas<C);

disp('Creating classifier ...')
%
% YOUR CODE 
svmclassify = @(xTe) computeK(ktype, xTe, xTr, kpar)*(yTr.* alphas)+bias; 

disp('Computing training error:') % this is optional, but interesting to see
%
% YOUR CODE 
disp(sum(sign(svmclassify(xTr))~=yTr)./length(yTr));


