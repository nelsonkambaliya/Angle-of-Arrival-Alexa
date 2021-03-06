close all;
clear all;

errors =[];

for signal_index =1:10
    for array_index=1:3
        file_name = ['./train/A0' num2str(array_index) '_X0' num2str(signal_index) '.wav'];
        ans_X=signal_index;
        [raw_y,Fs] = audioread(file_name);
        disp(file_name);
        error = call_rest_of_code(raw_y,Fs,array_index, signal_index);
        errors=[errors;error];
        
    end
end

function [errors] = call_rest_of_code(raw_y,Fs,array_index, signal_index)
    x_loc = 0;
    y_loc = 0;
    d = 4.5e-2;
    c = 343;
    ang = [120 60 0 300 240 180];
    mic_loc = [x_loc+d*cosd(ang') y_loc+d*sind(ang')];

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    mic_dis = [];
    for ref_mic = 1:6
        for i=1:6
            dis_vec = [mic_loc(i,1)-mic_loc(ref_mic,1) mic_loc(i,2)-mic_loc(ref_mic,2) 0];
            mic_dis = [mic_dis; dis_vec];
        end
    end

    direc_vecs = [];
    for tau = 0:359
        tau_vec = [cosd(tau) sind(tau)];
        direc_vecs = [direc_vecs; tau_vec/norm(tau_vec)];
    end

    %mic_dis_projections = mic_dis * direc_vecs';
    %save('mic_dis_projections.mat', 'mic_dis_projections');

    %time_diff = mic_dis_projections/c;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    load('outputAngle.mat');
    raw_y = raw_y(:,1:6);

    %[first_mic, mic_delays] = first_mic_solver(raw_y);

    %[max_val, max_indx] = max(ref_sig);
    %imeband = [max_indx-500 max_indx+25000];

    %chops the signal
    %fy = raw_y(timeband(1):timeband(2),:);
    fy = raw_y;


    fy_dis = [];
    fy_dis2 = [];
    for ref_mic = 1:6
        refsig = fy(:,ref_mic);
        for idx=1:6
            if(ref_mic == idx)
                tau=0;
                tau2=0;
            else
                tau = gccphat(refsig, fy(:,idx), Fs);
                tau2 = interpolated_gccphat(refsig, fy(:,idx), Fs);
            end
            fy_dis = [fy_dis; tau*c];
            fy_dis2 = [fy_dis2; tau2*c];
        end
    end
    %{
    result = [];
    result2 = [];
    for alpha = 1:360
        result = [result norm(mic_dis_projections(:,alpha)-fy_dis)];
        result2 = [result2 norm(mic_dis_projections(:,alpha)-fy_dis2)];
    end
%}
    res = 0.1;
    azi_grid = linspace(0,360,360/res);
    ele_grid = linspace(0,90,90/res);
    
    [azi_2d, ele_2d] = meshgrid(azi_grid,ele_grid);
    
    scores = zeros(size(azi_2d));
    scores2 = zeros(size(azi_2d));

    
    for A=1:size(azi_2d,2)
        for E=1:size(azi_2d,1)
            azi= azi_2d(E,A)*pi/180;
            ele = ele_2d(E,A)*pi/180;
            vec = [cos(azi)*cos(ele) sin(azi)*cos(ele) sin(ele)];
            scores(E,A)= 1/norm(mic_dis*vec' - fy_dis);
            scores2(E,A)= 1/norm(mic_dis*vec' - fy_dis2);
            
        end
    end
    %figure;
    %imagesc(scores2);
    %xlabel('Azimuth (0-360)');
    %ylabel('Elevation (0-90)');
    %title('AoA space search: 1/distance');
    result = sum(scores,1);
    result2 = sum(scores2,1);
    %figure;
    %plot((1:720)./2, result);
    %hold on;
    [max_val, max_indx] = max(result);
    [max_val2, max_indx2] = max(result2);
    
    deg = res*max_indx;
    deg2 = res*max_indx2;

    
    %scatter(max_indx/2, max_val, 'v');
    err = abs(outputAngle(signal_index,array_index)- deg);
    err2 = abs(outputAngle(signal_index,array_index)-deg2);
    errors=[err err2];
    disp([deg deg2 err err2]);
    disp(outputAngle(signal_index,array_index));
    
    
    %{
    heat_map = zeros(90,360);
    for azi=1:360
        for ele=1:91
            azi_rad = azi*pi/180;
            ele_rad = ele*pi/180;
            vec = [cos(azi)*cos(ele) sin(azi)*cos(ele) sin(ele)];
            
            heat_map(ele,azi) = norm(mic_dis*vec' - fy_dis2);
        end
    end
    colormap('hot');
    imagesc(heat_map);
    %}
    
    
    
    %figure;
    %plot(0:359, result);
    %hold on;
    %plot(0:359, result2);
    
    %{
    [min_val, min_indx] = min(result);
    [min_val2, min_indx2] = min(result2);
    disp([min_indx min_indx2]);
    
%}

end


function [tau] = interpolated_gccphat(y1, y2, Fs)
    esp = 0.000001;
    N = length(y1);
    
    ffta_y1 = fft(y1,2*N);
    fft_y1 = ffta_y1(1:(floor(length(ffta_y1)/2)+1));
    ffta_y2 = fft(y2,2*N);
    fft_y2 = ffta_y2(1:(floor(length(ffta_y2)/2)+1));
    
    fft_prod = fft_y1 .* conj(fft_y2);
    fft_prod_mag = abs(fft_prod);
    Gphat = fft_prod./(fft_prod_mag+esp);
    Rphat = irfft(Gphat, 1, 2*N);
    
    x = horzcat(Rphat(N+1:end),Rphat(1:N));
    lag = -N:N;
    %figure;
    %plot(1:size(x,2),x);
    
   %interpolation
   %[corr_val, corr_index] = max(x(N-8:N+8));
   %corr_index = corr_index + (N-8);
   [corr_val, corr_index] = max(x);
   tau_approx = lag(corr_index)/Fs;
   
   dk = 0.5*(x(corr_index-1) - x(corr_index+1)) / (x(corr_index+1) + x(corr_index-1) - 2*x(corr_index));
   if(abs(dk)>=1)
       dk=0;
   end
   %{
   if(tau_approx==0)
       dk=0;
   end
   %}
   t_offset = dk/Fs;
   tau = tau_approx + t_offset;
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

function [irfft_result] = irfft(x,even, N)
     n = 0; % the output length
     s = 0; % the variable that will hold the index of the highest
            % frequency below N/2, s = floor((n+1)/2)
     if(even==1)
        n = 2 * (length(x) - 1 );
        s = length(x) - 1;
     else
        n = 2 * (length(x) - 1 )+1;
        s = length(x);
     end
     xn = zeros(1,n);
     xn(1:length(x)) = x;
     xn(length(x)+1:n) = conj(x(s:-1:2));
     irfft_result  = ifft(xn, N);
end
