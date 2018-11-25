classdef nastranMagic < handle
    %NASTRANMAGIC Parses and/or plots results from NASTRAN.

    % ---------------------------------------------------------------------------

    properties

        fileName % string containing file name
        initialString % string that determines where cut starts
        finalString % string that determines where cut ends
        tempData % temporary
        data

    end

    % ---------------------------------------------------------------------------

    methods



        function [obj] =  nastranMagic(inputArg1)
            %CONSTRUCTOR Construct an instance of this class
            %   Simply pass the name of the file with Nastran's results.

            obj.fileName = inputArg1;
        end



        function [obj] = setBounds(obj, arg1, arg2)

           narginchk(2,3); % obj actually counts as an argument even if it's
                           % always implicit

           if nargin == 3 % manually inserted bounds

             obj.initialString = arg1;
             obj.finalString = arg2;

           else

             requestedMode = arg1;

             if requestedMode == 'timeResponse'; % automatic time response mode

                obj.initialString = string('POINT-ID =         1');
                obj.finalString = string('* * * *  D B D I C T   P R I N T  * * * *');

             end

          end

        end



        function [obj] = extract(obj)

           temp_string = extractFileText(obj.fileName);
           temp_string = extractBetween(temp_string, obj.initialString, obj.finalString);
           obj.tempData = splitlines(temp_string);

        end



        function [obj] = filter(obj)

           [temp_size,~] = size(obj.tempData);
           line = 1;

           while (line <= temp_size)

             obj.tempData = erase(obj.tempData,'S'); % deletes all Ses
             curr_line = char(obj.tempData(line)); % converts from string to array of characters

             if (length(curr_line) < 4) % check if line is too short
                 obj.tempData(line) = [];
                 temp_size = temp_size-1;
                 continue; % passes to next iteration of loop
             end

             first3 = string(curr_line(1:3));

             if (first3 ~= '   ') % check number of spaces at the beginning
                 obj.tempData(line) = [];
                 temp_size = temp_size-1;
                 continue; % passes to next iteration of loop

             elseif (~isstrprop(curr_line(4),'digit')) % check if 4th character is not a digit
                 obj.tempData(line) = [];
                 temp_size = temp_size-1;
                 continue; % passes to next iteration of loop

             end

             line = line+1;

           end

        end



        function [obj] = makeArray(obj)

           for line = 1:length(obj.tempData)

             newRow = sscanf(obj.tempData(line),'%e');
             newRow = newRow';
             obj.data = [obj.data; newRow];

           end

        end



        function [timeResp] = parseTimeResponse(obj)
            %PARSETIMERESPONSE Parses time response from NASTRAN file to output vector.

            obj.setBounds('timeResponse');
            obj.extract();
            obj.filter();
            obj.makeArray();

            timeResp = obj.data;

            plot(obj.data(:,1), obj.data(:,2))

        end



    end



end
