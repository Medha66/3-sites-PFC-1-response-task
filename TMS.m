function [varargout] = TMS(flag, varargin)
%-------------------------------------------------------------------------
% Function that enables communicating with MagVenture TMS machine. The
% following functionality is available:
% OPEN PORT: opens the serial port COM2
%       Usage: s = TMS('Open')
% ENABLE TMS: Enables the TMS machine. This can be done manually instead.
%       Usage: TMS('Enable', s)
% AMPLITUDE: Sets the amplitude on the TMS machine.
%       Usage: TMS('Amplitude', s, newAmplitude)
% SEND TRAIN: starts a train of pulses that needs to be set up manually on
%       the TMS machine. Amplitude needs to be set in advance with a 
%       separate call. An optional parameter "time" can be used to control 
%       the exact time of TMS delivery.
%       Usage: TMS('Train', s, time)
% SEND SINGLE PULSE: sends a single pulse. Amplitude needs to be set in 
%       advance with a separate call. An optional parameter "time" can be 
%       used to control the exact time of TMS delivery.
%       Usage: TMS('Single', s, time)
% DISABLE TMS: Disables the TMS machine. This can be done manually instead.
%       Usage: TMS('Disable', s)
% CLOSE PORT: closes the serial port
%       Usage: TMS('Close', s)
%
% Written by Doby Rahnev and Justin Riddle
%-------------------------------------------------------------------------

if strcmp(flag,'Open')
    % Opens COM2 port and returns serial port ID
    s = serial('/dev/tty.USA19H146P1.1'); %When using Keyspan HighSpeed USB Serial Adapter USA-19HS
    %s = serial('/dev/tty.pci-serial0'); % When using in-built MAC serial port
    fopen(s);
    set(s,'Baudrate',38400)
    % set(s,'Timeout',0.001)
    varargout{1} = s;
    fprintf('Serial Port OPEN\n');
    
else
    
    % The serial port has already been opened, and is expected as the first
    % parameter in varargin
    s = varargin{1};
    
    switch flag
        
        case 'Train'
            % Start a train at current amplitude
            %fwrite(s,hex2dec({'FE', '03', '04', '00', '00', '9E', 'FF'}),'uint8');
            if length(varargin) < 2
                fwrite(s, [254, 3, 4, 0, 0, 158, 255], 'uint8');
            else
                time = varargin{2};
                fwrite(s, [254, 3, 4, 0, 0, 158], 'uint8');
                WaitSecs('UntilTime',time);
                fwrite(s, 255, 'uint8');
            end
            
        case 'Single'
            % Sends a single pulse at current amplitude
            %fwrite(s,hex2dec({'FE','03','03','01','00','20','FF'}),'uint8');
            if length(varargin) < 2
                fwrite(s, [254, 3, 3, 1, 0, 32, 255], 'uint8');
            else
                time = varargin{2};
                fwrite(s, [254, 3, 3, 1, 0, 32], 'uint8');
                WaitSecs('UntilTime',time);
                fwrite(s, 255, 'uint8');
            end
            
        case 'Enable'
            % Enables the TMS machine
            %fwrite(s,hex2dec({'FE', '03', '02', '01', '00', '8B', 'FF'}),'uint8');
            fwrite(s, [254, 3, 2, 1, 0, 139, 255], 'uint8');
            fprintf('TMS machine ENABLED\n');
            
        case 'Disable'
            % Disnables the TMS machine
            %fwrite(s,hex2dec({'FE','03','02','00','00','4F','FF'}),'uint8');
            fwrite(s, [254, 3, 2, 0, 0, 79, 255], 'uint8');
            fprintf('TMS machine DISABLED\n');
            
        case 'Close'
            % Closes the serial port
            fclose(s);
            delete(s);
            clear s;
            fprintf('Serial Port CLOSED\n');
            
        case 'Amplitude'
            % Sets the amplitude of the TMS machine
            number = varargin{2};
            assert(number >= 0 || number <= 100);
            
            % Calculate CRC8 for MagVenture
            CRC8_hex = crc8_magVenture(['01' dec2hex(number,2) '00']);
            
            % Set the amplitude
            fwrite(s, [254, 3, 1, number, 0, hex2dec(CRC8_hex), 255], 'uint8');
    end
end
end

%% crc8_magVenture
function CRC8_hex = crc8_magVenture( hexStr )

numBytes = length(hexStr) /2;
numBits = numBytes * 8;

% BigEndian (flip byte order)
hexStr_bigEndian = '';
for byteIdx = 1:numBytes
    flipByteIdx = ((numBytes - byteIdx) * 2) + 1;
    hexStr_bigEndian = [hexStr_bigEndian hexStr(flipByteIdx:flipByteIdx+1)];
end
% Convert from Hex to Binary
encode = de2bi(hex2dec(hexStr_bigEndian),numBits);

% CRC8 Calculator
% x^8 + x^5 + x^4 + 1
checkSumGen = comm.CRCGenerator([1 0 0 1 1 0 0 0 1]);
inputAndCRC8 = step(checkSumGen,encode');
CRC8_bi = inputAndCRC8(numBits+1:end);
CRC8_de = bi2de(CRC8_bi');

% Return value as a hex string
CRC8_hex = dec2hex(CRC8_de);

end