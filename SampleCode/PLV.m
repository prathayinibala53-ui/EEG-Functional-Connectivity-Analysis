%% ==========================================================
%  Phase-Based Functional Connectivity Using PLV
%  Demonstration with Synthetic EEG Data
%
%  Author: Prathayini
%  Purpose: Educational demonstration of phase-based
%           functional connectivity methods
%% ==========================================================

clear; close all; clc;

%% Parameters
fs = 250;                 % Sampling frequency (Hz)
duration = 20;            % Signal length (seconds)
t = 0:1/fs:duration;
channels = 19;            % Typical EEG montage size

bands.Alpha = [8 13];
bands.Beta  = [13 30];
bandNames = fieldnames(bands);

%% Generate Synthetic EEG Signals
rng(1); % reproducibility
EEG = zeros(channels, length(t));

for ch = 1:channels
    EEG(ch,:) = sin(2*pi*(8 + rand*4)*t) + 0.5*randn(1,length(t));
end

%% Initialize PLV Storage
numBands = numel(bandNames);
PLV = zeros(channels, channels, numBands);

%% PLV Computation
for b = 1:numBands

    freqRange = bands.(bandNames{b});
    fprintf('Processing %s band (%.1f–%.1f Hz)\n', ...
            bandNames{b}, freqRange(1), freqRange(2));

    % Bandpass filter
    EEG_filt = bandpass(EEG', freqRange, fs)';

    % Phase extraction
    analytic_signal = hilbert(EEG_filt')';
    phase_data = angle(analytic_signal);

    % PLV matrix
    for i = 1:channels
        for j = 1:channels
            if i ~= j
                phase_diff = phase_data(i,:) - phase_data(j,:);
                PLV(i,j,b) = abs(mean(exp(1i * phase_diff)));
            end
        end
    end
end

%% Visualization
figure;
for b = 1:numBands
    subplot(1,numBands,b);
    imagesc(PLV(:,:,b));
    axis square;
    colorbar;
    clim([0 1]);
    title([bandNames{b} ' Band PLV']);
end

sgtitle('Phase Locking Value (PLV) Connectivity Matrices');
