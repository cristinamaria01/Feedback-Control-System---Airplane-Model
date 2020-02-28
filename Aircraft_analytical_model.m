clear all
close all
clc

[G_tf, ~, W_T, eps_max, w_perf, ~, ~] = date_indiv(123);

%Cerinta_1_________________________________________________________________

s = tf('s');
W_S = 80/( s/w_perf + 1);
S = feedback(1, G_tf);
norm_WsS = norm(W_S*S,inf);
%{
figure()
    bodemag(W_S,W_T)
    title('W_S vs W_T')
    legend('W_S','W_T')
%}

%Cerinta_2_________________________________________________________________

omegL = logspace(-4, 4, 1e3);
amp_Y = reshape(bode(W_T,omegL),1,numel(omegL));

%{
[a,b] = size(omegL);
for i=1:b
    if amp_Y(i) >= 1
        w_rob = omegL(i)
        break;
    end
end
%}

w_rob = 3.8778;

%Cerinta_3_________________________________________________________________

w_jf = omegL(1:find(omegL >= w_perf));

[amp1,~,~] = bode(W_S, w_jf);               % |Ws|
      amp1 = reshape(amp1,1,length(amp1));
[amp2,~,~] = bode(W_T, w_jf);               % |Wt|
      amp2 = reshape(amp2,1, length(amp2));
      
      R_jf = amp1 ./ (1 - amp2);            % Ws / (1 - Wt)

%Cerinta_4_________________________________________________________________

w_if = omegL(find(omegL >= w_rob,1):end);

[amp_1,~,~] = bode(W_S, w_if);              % |Ws|
      amp_1 = reshape(amp_1,1,length(amp_1));
[amp_2,~,~] = bode(W_T, w_if);              % |Wt| 
      amp_2 = reshape(amp_2,1,length(amp_2));
      
      R_if = (1 - amp_1) ./ amp_2;          % (1 - Ws) / Wt

%Cerinta_5_________________________________________________________________

k = 130;
    
L_syn = (k*(s/0.65+1)*(s/170+1))/((s/w_perf +1)*(s/4.2+1)*(s/950+1)*(s/9500+1));


[amp_L,~,~] = bode(L_syn, omegL);
      amp_L = reshape(amp_L,1,length(amp_L));

figure()
      semilogx(w_jf,db(R_jf),'r',w_if,db(R_if),'g',omegL,db(amp_L),'b');
      legend('Rj','Ri','L');
      grid on;

C_syn = L_syn/G_tf;
C_syn = tf(ss(C_syn,'min'));

%Cerinta_6_________________________________________________________________

T = feedback(L_syn, 1);
S = feedback(1, L_syn);
poli_T = (pole(T))';

%{
figure()
    pzmap(T);
%}

[mag1,~,~] = bode(W_S*S,omegL);             % |Ws*S|
[mag2,~,~] = bode(W_T*T,omegL);             % |Wt*T|
      
       mag = reshape(mag1+mag2,1,length(omegL));

robperf_cost = max(mag);

%{
    figure();
    semilogx(omegL,mag);
    title('|| |WsS|+|WtT| ||_{infinity} - conditie performanta robusta')
    grid on
%}
