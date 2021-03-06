close all;
clear all;

x_loc = 5;
y_loc = 5;
d = 4.75e-2;
c = 343;
ref_mic = 5;
ang = [120 60 0 300 240 180];
mic_loc = [x_loc+d*cosd(ang') y_loc+ d*sind(ang')];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

mic_dis = [];
for i=1:6
    dis_vec = [mic_loc(i,1)-mic_loc(ref_mic,1) mic_loc(i,2)-mic_loc(ref_mic,2)];
    mic_dis = [mic_dis; dis_vec];
end

direc_vecs = [];
for tau = 0:359
    tau_vec = [cosd(tau) sind(tau)];
    direc_vecs = [direc_vecs; tau_vec/norm(tau_vec)];
end

mic_dis_projections = mic_dis * direc_vecs';
save('mic_dis_projections.mat', 'mic_dis_projections');

time_diff = mic_dis_projections/c;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Process y
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[raw_y,Fs] = audioread('./train/A03_X01.wav');
load('outputAngle.mat');
raw_y = raw_y(:,1:6);

[first_mic, mic_delays] = first_mic_solver(raw_y);

ref_sig = raw_y(:,first_mic(1));
[max_val, max_indx] = max(ref_sig);
timeband = [max_indx-500 max_indx+25000];

%chops the signal
raw_y=raw_y(timeband(1):timeband(2),:);

%bandpass signal
passfreq = [500 1500];
for idx = 1:6 
    raw_y(:,idx) = bandpass(raw_y(:,idx), passfreq, Fs);
end

%{
final_result =[];
for freq = 500:1:1500
    result = aoa(raw_y, freq, c, Fs, mic_dis_projections);
    if(length(result)>1)
        diff_result = abs(result-ang(first_mic(1)));
        [min_val, min_indx] = min(diff_result);
        final_result = [final_result; result(min_indx)];
        disp([ang(first_mic(1)) result(min_indx) result]);
    elseif(length(result)==1)
        final_result = [final_result; result(1)];
    else
        fprintf('---------------');
    end
end
disp(outputAngle(2,:));
disp(mean(final_result));
%}

final_result = time_aoa(raw_y, c, Fs, ref_mic, mic_dis_projections);
disp(outputAngle(1,:));
[pks, locs] = findpeaks(final_result, 'MinPeakHeight', 0.3, 'MinPeakDistance', 20);
disp([locs locs+180]);
figure;
plot(0:359, final_result);
hold on;
scatter(locs,pks, 'v');

function [result] = time_aoa(raw_y, c, Fs, ref_mic, mic_dis_projections)
    time_diff = mic_dis_projections/c;
    ref_signal = raw_y(:,ref_mic);
    
    spec_result= [];
    for idx=1:360
        disp(idx);
        delays=time_diff(:,idx);
        delayed_signal=[];
        for idx2=1:6
            delayed_signal = [delayed_signal; delayseq(ref_signal,delays(idx2),Fs)];
        end
        signal_sum = norm(sum(delayed_signal,1));
        spec_result = [spec_result signal_sum];
    end
    %[pks,locs] = findpeaks(spec_result);
    result = spec_result; 
end


function [result] = aoa(raw_y, freq, c, Fs, mic_dis_projections)
    disp(freq);
    lambda = c/freq;
    zmag=[];
    zang=[];

    for idx = 1:6 
        yF(idx,:) = fft(raw_y(:,idx), Fs);
        zmag = [zmag abs(yF(idx,freq))];
        zang = [zang angle(yF(idx,freq))];
    end
    
    t=1;
    fy = [];

    for idx = 1:6
        %freq_y = zmag(idx) * exp((1i*2*pi*freq*t) + zang(idx));
        freq_y = exp(-1i*(2*pi*freq*t + zang(idx)));
        fy = [fy; freq_y'];
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Find Angle
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    phase_diff = mic_dis_projections*2*pi./lambda;
    M = exp(1i*phase_diff');
    spectrum = (M * fy)'; % 360x6 * 6x1
    spec_result= [];
    for idx =1:size(spectrum,2)
        spec_result = [spec_result real(spectrum(idx))];
    end
    
    %figure;
    %plot(0:359,spec_result);
    [pks,locs] = findpeaks(spec_result);
    result = locs;
    %disp([locs, calc_ref_mic, ang(calc_ref_mic)]);
    %disp(outputAngle(2,:));
end


function [first_mic, mic_delays] = first_mic_solver(y)
    mic_delays = [];
    for i=1:6
        [res, lags] = xcorr(y(:,1), y(:,i));
        [max_v, max_i] = max(res);
        mic_delays = [mic_delays lags(max_i)];
    end
    [least_lag] = max(mic_delays);
    first_mic = find(mic_delays == least_lag);
end



