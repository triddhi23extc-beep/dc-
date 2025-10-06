function DigitalMessagingSystem
    % Create GUI window
    f = figure('Name','Digital Messaging System', ...
               'NumberTitle','off', ...
               'Position',[300 150 700 500], ...
               'Color',[0.9 0.9 0.9]);

    % Title
    uicontrol('Style','text','String','Digital Messaging System (Text → Bits → Modulation)', ...
        'FontSize',13,'FontWeight','bold','BackgroundColor',[0.9 0.9 0.9], ...
        'Position',[80 440 550 30]);

    % Text input label
    uicontrol('Style','text','String','Enter Text Message:', ...
        'Position',[50 390 150 25],'BackgroundColor',[0.9 0.9 0.9]);

    % Text input box
    hInput = uicontrol('Style','edit','Position',[200 390 300 25], ...
        'BackgroundColor','white','HorizontalAlignment','left');

    % Modulation type dropdown
    uicontrol('Style','text','String','Select Modulation:', ...
        'Position',[50 350 150 25],'BackgroundColor',[0.9 0.9 0.9]);
    hMod = uicontrol('Style','popupmenu','Position',[200 350 150 25], ...
        'String',{'ASK','FSK','PSK'});

    % Buttons
    uicontrol('Style','pushbutton','String','Transmit', ...
        'Position',[380 350 100 25],'Callback',@transmitCallback);

    % Output text box
    uicontrol('Style','text','String','Received Text:', ...
        'Position',[50 310 150 25],'BackgroundColor',[0.9 0.9 0.9]);
    hOutput = uicontrol('Style','edit','Position',[200 310 300 25], ...
        'BackgroundColor','white','Enable','inactive');

    % Axes for plotting
    ax1 = axes('Parent',f,'Position',[0.1 0.1 0.8 0.35]);
    title(ax1,'Signal Waveforms'); xlabel(ax1,'Time'); ylabel(ax1,'Amplitude');

    % --- Callback function ---
    function transmitCallback(~,~)
        % Get user input and modulation type
        msg = get(hInput,'String');
        modType = get(hMod,'Value');
        if isempty(msg)
            msgbox('Please enter a text message.','Error','error');
            return;
        end

        % Convert text to binary
        ascii_vals = double(msg);
        bin_msg = reshape(de2bi(ascii_vals,8,'left-msb')',1,[]);
        fs = 1000; Tb = 0.01; t = 0:1/fs:Tb-1/fs;
        fc1 = 100; fc2 = 200; % FSK frequencies
        modulated = [];

        % Modulate signal
        switch modType
            case 1 % ASK
                for i = 1:length(bin_msg)
                    if bin_msg(i) == 1
                        s = cos(2*pi*fc1*t);
                    else
                        s = 0*cos(2*pi*fc1*t);
                    end
                    modulated = [modulated s];
                end
                title(ax1,'ASK Modulation');
            case 2 % FSK
                for i = 1:length(bin_msg)
                    if bin_msg(i) == 1
                        s = cos(2*pi*fc1*t);
                    else
                        s = cos(2*pi*fc2*t);
                    end
                    modulated = [modulated s];
                end
                title(ax1,'FSK Modulation');
            case 3 % PSK
                for i = 1:length(bin_msg)
                    s = cos(2*pi*fc1*t + pi*bin_msg(i));
                    modulated = [modulated s];
                end
                title(ax1,'PSK Modulation');
        end

        % Add noise
        noisy = awgn(modulated,10,'measured');

        % Plot signal
        cla(ax1);
        plot(ax1,noisy);
        xlabel(ax1,'Time');
        ylabel(ax1,'Amplitude');
        grid(ax1,'on');

        % Demodulation
        demod_bits = zeros(1,length(bin_msg));
        samples_per_bit = length(t);
        for i = 1:length(bin_msg)
            segment = noisy((i-1)*samples_per_bit+1:i*samples_per_bit);
            switch modType
                case 1 % ASK
                    corr1 = sum(segment .* cos(2*pi*fc1*t));
                    demod_bits(i) = corr1 > 0.5 * samples_per_bit;
                case 2 % FSK
                    corr1 = sum(segment .* cos(2*pi*fc1*t));
                    corr2 = sum(segment .* cos(2*pi*fc2*t));
                    demod_bits(i) = corr1 > corr2;
                case 3 % PSK
                    corr = sum(segment .* cos(2*pi*fc1*t));
                    demod_bits(i) = corr < 0; % Phase difference
            end
        end

        % Convert bits to text
        bin_matrix = reshape(demod_bits,8,[])';
        recovered_ascii = bi2de(bin_matrix,'left-msb');
        received_text = char(recovered_ascii)';

        % Display output
        set(hOutput,'String',received_text);
    end
end