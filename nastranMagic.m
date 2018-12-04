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



        function [obj] = extract(obj)

           temp_string = extractFileText(obj.fileName);
           temp_string = extractBetween(temp_string, obj.initialString, obj.finalString);
           obj.tempData = splitlines(temp_string);

        end



        function [obj] = filter4tr(obj)

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

           % clean data
           obj.data = [];

           % build array
           for line = 1:length(obj.tempData)
             newRow = sscanf(obj.tempData(line),'%e');
             newRow = newRow';
             obj.data = [obj.data; newRow];
           end

        end



        function [timeResp] = parseTimeResponse(obj, point)
            %PARSETIMERESPONSE Parses time response from NASTRAN file to output vector.

            % prepare string for text extraction
            if (point > 999999999)
              error('requested mode number needs to be < 1000000000.')
            end
            figures = obj.getFigures(point);

            % add needed spaces to initial string
            spacesToAdd = 9 - figures;
            istr = 'POINT-ID = ';
            for counter = 1:spacesToAdd
              istr = [istr ' '];
            end

            % set bounds
            obj.initialString = [istr int2str(point)];
            obj.finalString = '* * * *  D B D I C T   P R I N T  * * * *';

            obj.extract();
            obj.filter4tr();
            obj.makeArray();

            timeResp = obj.data;

            plot(obj.data(:,1), obj.data(:,2))

        end



        function [noFigures] = getFigures(obj, int)

           if (floor(int) ~= int)
             error('input argument is not an integer.')
           end

           noFigures = 1;
           base = 10;
           threshold = base^noFigures;

           while (int >= threshold)

             noFigures = noFigures + 1;
             threshold = base^noFigures;

             if (noFigures > 50)
                error('input number is too large.')
                break
             end

           end

        end



        function [vg] = vgSingleMode(obj, modeNo)

           % count number of figures in input; if > 4, return error
           if (modeNo > 9999)
             error('requested mode number needs to be < 10000.')
           end
           figures = obj.getFigures(modeNo);

           % add needed spaces to initial string
           spacesToAdd = 4 - figures;
           istr = 'POINT = ';
           for counter = 1: spacesToAdd
             istr = [istr ' '];
           end

           % set bounds
           obj.initialString = [istr int2str(modeNo) '     MACH NUMBER'];
           obj.finalString = 'MSC/MD NASTRAN MODES ANALYSIS SET';

           % extract text; check for success of extraction
           obj.extract();
           if (isempty(obj.tempData))
             error(['Unable to find requested mode: mode ' int2str(modeNo) ' not found.'])
           end

           % remove unnecessary lines
           obj.tempData = splitlines(obj.tempData);
           obj.tempData(1:4) = [];
           obj.tempData(end) = [];

           % build array
           obj.makeArray;

           % select only necessary columns
           obj.data = obj.data(:, 3:4);

           % return
           vg = obj.data;

           % plot
           plot(obj.data(:,1), obj.data(:,2))

        end



        function [] = plotVg(obj, modes)
           %PLOTVG plots V-g diagram for specified modes. For instance:
           %file.plotVg([1 2 5])
           %plots modes 1, 2 and 5.

           figure('Name',[obj.fileName ': V-g diagram'],'NumberTitle','off')
           hold on
           description = [];

           for i = modes
             obj.vgSingleMode(i);
             description = [description; 'mode ' int2str(i)];
           end

           legend({description}) % 'Location','southwest'
           hold off

        end




    end



end
