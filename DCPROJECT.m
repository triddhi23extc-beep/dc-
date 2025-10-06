clc; clear; close all;
bits = input('Enter bits (e.g. [1 0 1 1 0]): ');
fc = input('Enter carrier frequency (e.g. 5): ');
bit_duration = 1;       
fs = 1000;               
t_total = [];
original_bits = [];
ASK = [];
FSK = [];
PSK = [];

for idx = 1:length(bits)
    t = (idx-1):1/fs:idx-1+bit_duration-(1/fs); 
    original_bits = [original_bits bits(idx)*ones(1, length(t))];
    ask_wave = bits(idx) * sin(2*pi*fc*t);
    ASK = [ASK ask_wave];
    if bits(idx) == 1
        fsk_wave = sin(2*pi*(fc+2)*t);
    else
        fsk_wave = sin(2*pi*(fc-2)*t);
    end
    FSK = [FSK fsk_wave];
    psk_wave = sin(2*pi*fc*t + pi*(bits(idx)==0));
    PSK = [PSK psk_wave];
    t_total = [t_total t];         
end
figure;

subplot(4,1,1);
plot(t_total, original_bits,'k','LineWidth',2);
title('Input Bits');
ylim([-0.2 1.2]); ylabel('Bit Value'); grid on;

subplot(4,1,2);
plot(t_total, ASK, 'b','LineWidth',1.5);
title('ASK (Amplitude Shift Keying)');
ylabel('Amplitude'); grid on;

subplot(4,1,3);
plot(t_total, FSK, 'r','LineWidth',1.5);
title('FSK (Frequency Shift Keying)');
ylabel('Amplitude'); grid on;

subplot(4,1,4);
plot(t_total, PSK, 'g','LineWidth',1.5);
title('PSK (Phase Shift Keying)');
ylabel('Amplitude'); grid on;
xlabel('Time (seconds)');

