%% ROB 435 Quantifying Human Motion Through Wearable Sensors %%
%% Final Project %%
%% Authors: Lucia Lee, Nathan Kuo, Keerthi Marri, Mason Niu
clear

%{
Script to analyze drumkick data and send analysis like drum beats, type of
kick used

IMU will be placed on the outside of the foot with the x-axis pointing to
the toes, 
%}

%% setup
clear;
clc;

% load data from csv file
data = readmatrix('drumkick_data.csv');