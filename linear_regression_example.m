%% script example from PSGY4009 / lecture 6
%
% denis schluppeck, 2022-11-07

%% make sure you have access to data 
% I used the following dataset / files
% for the demos here:

theURL = 'https://github.com/schluppeck/hands-on-brain-data';
web(theURL)

% download the data (green button, download ZIP
%
% if you know how to use git/github, you can also 
% git clone https://github.com/schluppeck/hands-on-brain-data


%% change directory / navigate matlab to the folder
% then change into the "data" directory

cd('data')
clear all, close all

%% you should have nothing in your workspace
whos
who

% load in timecourse
y = load('timecourse.txt')
figure, plot(y)

% load in design matrix
X = load('design-3.txt')
plot(X)
title('fMRI response timecourse')

% make a figure of design matrix
figure, imagesc(X)
colormap(gray())
title('design matrix, three columns')

% look at the data in command window
y
X

%% there are several different approaches

% backslash
doc \  % to get help
X\y
p = X\y

%% use matlab regress()
doc regress
regress(y, X)


%% pseudoinverse
doc pinv
pinv(X)*y


%% Notes
%
% 3blue1brown -- basic concepts of linear algebra
%
% - https://youtube.com/playlist?list=PLZHQObOWTQDPD3MizzM2xVFitgF8hE_ab
%
% Gilbert Strang -- MIT course. Amazing resource.
%
% - https://youtube.com/playlist?list=PL49CF3715CB9EF31D

