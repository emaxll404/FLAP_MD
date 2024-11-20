function TouchpixxWhacAMoleDemo()
% TouchpixxWhacAMoleDemo()
%
% Whack-A-Mole game using TOUCHPixx touch panel.
%
% History:
%
% Nov 23, 2012  paa     Written
% Nov  3, 2014  dml     Revised

AssertOpenGL;

try
    % We are assuming that the DATAPixx is connected to the highest number screen.
    % If it isn't, then assign screenNumber explicitly here.
    screenNumber=max(Screen('Screens'));

    % We use the imaging pipeline to open a window so that we can get microsecond accurate stimulus onset timetags
    PsychImaging('PrepareConfiguration');
    PsychImaging('AddTask', 'General', 'UseDataPixx');
    [w, wRect] = PsychImaging('OpenWindow', screenNumber, 0);
    winWidth = wRect(3) - wRect(1);
    winHeight = wRect(4) - wRect(2);

    % After OpenWindow so it's under the text generated by Screen
    fprintf('\nTOUCHPixx Whack-A-Mole Demo\n');

    % Configure DATAPixx/TOUCHPixx
    Datapixx('SetVideoMode', 0);                        % Normal passthrough
    Datapixx('EnableTouchpixx');                        % Turn on TOUCHPixx hardware driver
    Datapixx('SetTouchpixxStabilizeDuration', 0.01);    % Stabilize inputs for calibration
    Datapixx('RegWrRd');

    % Put up first touch calibration target near top-left corner, and acquire TOUCHPixx coordinates
    calDispX1 = 100;
    calDispY1 = 100;
    backCol = [128 128 128];
    Screen('FillRect', w, backCol, wRect);
    calCol = [255 255 255];
    Screen('FillRect', w, calCol, [calDispX1-50 calDispY1-50 calDispX1+50 calDispY1+50]);
    textCol = [0 0 0];
    Screen('TextFont',w, 'Courier New');
    Screen('TextSize',w, floor(50 * winWidth/1920));
    DrawFormattedText(w, 'Touch center of first calibration square', 'center', 'center', textCol);
    Screen('Flip', w);
    touchPt = [0 0];                        % Wait for press
    while touchPt == [0 0]
        Datapixx('RegWrRd');
        touchPt = Datapixx('GetTouchpixxCoordinates');
    end;
    calTouchX1 = touchPt(1);
    calTouchY1 = touchPt(2);
    Screen('FillRect', w, backCol, wRect);  % Erase calibration square
    Screen('Flip', w);
    isPressed = 1;                          % Wait until panel release
    while isPressed
        Datapixx('RegWrRd');
    	status =  Datapixx('GetTouchpixxStatus');
        isPressed = status.isPressed;
    end;

    % Do same for a second calibration target near bottom-right corner of display
    calDispX2 = winWidth - 100;
    calDispY2 = winHeight - 100;
    Screen('FillRect', w, backCol, wRect);
    Screen('FillRect', w, calCol, [calDispX2-50 calDispY2-50 calDispX2+50 calDispY2+50]);
    DrawFormattedText(w, 'Touch center of second calibration square', 'center', 'center', textCol);
    Screen('Flip', w);
    touchPt = [0 0];                        % Wait for press
    while touchPt == [0 0]
        Datapixx('RegWrRd');
        touchPt = Datapixx('GetTouchpixxCoordinates');
    end;
    calTouchX2 = touchPt(1);
    calTouchY2 = touchPt(2);
    Screen('FillRect', w, backCol, wRect);  % Erase calibration square
    Screen('Flip', w);
    isPressed = 1;                          % Wait until panel release
    while isPressed
        Datapixx('RegWrRd');
    	status =  Datapixx('GetTouchpixxStatus');
        isPressed = status.isPressed;
    end;

    % Calculate linear mapping between touch coordinates and display coordinates
    mx = (calDispX2 - calDispX1) / (calTouchX2 - calTouchX1);
    my = (calDispY2 - calDispY1) / (calTouchY2 - calTouchY1);
    bx = (calTouchX1 * calDispX2 - calTouchX2 * calDispX1) / (calTouchX1 - calTouchX2);
    by = (calTouchY1 * calDispY2 - calTouchY2 * calDispY1) / (calTouchY1 - calTouchY2);

    % Whacking instructions
    Screen('FillRect', w, backCol, wRect);
    DrawFormattedText(w, 'Whack moles when they appear\nTouch screen to start', 'center', 'center', textCol);
    Screen('Flip', w);
    isPressed = 0;                          % Wait until panel release
    while ~isPressed
        Datapixx('RegWrRd');
    	status =  Datapixx('GetTouchpixxStatus');
        isPressed = status.isPressed;
    end;
    while isPressed                         % Wait until panel release
        Datapixx('RegWrRd');
    	status =  Datapixx('GetTouchpixxStatus');
        isPressed = status.isPressed;
    end;
    
    % Loop for each mole to whack
    for i = 1:4
        % Wait for a random 1-2 second mole target onset
        status = Datapixx('GetVideoStatus');
        refreshRate = status.verticalFrequency;
        onsetDelay = floor((1 + rand(1)) * refreshRate);
        Screen('FillRect', w, backCol, wRect);
        for onsetFrame = 1:onsetDelay;
            Screen('Flip', w);
        end

        % Draw mole
        Screen('FillRect', w, backCol, wRect);
        moleX = floor(wRect(1) + winWidth/8 + winWidth * 0.75 * rand(1));
        moleY = floor(wRect(2) + winHeight/8 + winHeight * 0.75 * rand(1));
        moleSize = 150;
    	moleCol = [100 100 0];
        Screen('FillOval', w, moleCol, [moleX-moleSize/2 moleY-moleSize/2 moleX+moleSize/2 moleY+moleSize/2]);
        Screen('FillOval', w, [0 0 0], [moleX-moleSize/4 moleY-moleSize/4 moleX-moleSize/8 moleY-moleSize/8]);        
        Screen('FillOval', w, [0 0 0], [moleX+moleSize/8 moleY-moleSize/4 moleX+moleSize/4 moleY-moleSize/8]);        
        Screen('FrameArc', w, [0 0 0], [moleX-moleSize/3 moleY-moleSize/3 moleX+moleSize/3 moleY+moleSize/3], 135, 90, 20);        
        PsychDataPixx('LogOnsetTimestamps', 1); % Tells imaging pipeline to capture DATAPixx microsecond-accurate hardware stimulus onset timestamp
        Screen('Flip', w);
        moleTimetag = PsychDataPixx('GetLastOnsetTimestamp');

        % Start TOUCHPixx event logging
        Datapixx('SetTouchpixxLog');        % Configure TOUCHPixx logging with default buffer
        Datapixx('EnableTouchpixxLogContinuousMode');   % Continuous logging during a touch, so we recognize a sweep-a-mole
        Datapixx('StartTouchpixxLog');
        Datapixx('RegWrRd');
        
        % Wait around until mole gets whack'd
        whacked = 0;
        while ~whacked
        
            % Escape if key pressed
            if KbCheck
                break;
            end

            % How much TOUCHPixx data is available to read?
            Datapixx('RegWrRd');                    % Update registers for GetTouchpixxStatus
            status = Datapixx('GetTouchpixxStatus');
            if status.newLogFrames                  % We have new TOUCHPixx logged data to read?
                [touches timetags] = Datapixx('ReadTouchpixxLog', status.newLogFrames);
                for iTouch = 1:status.newLogFrames  % Examine each logged TOUCHPixx datum
                    touchX = touches(1,iTouch);
                    touchY = touches(2,iTouch);
                    if (touchX ~= 0 & touchY ~= 0)  % Confirm datum is not a panel release
                        
                        % Convert touch panel coordinates to pixel coordinates
                        whackX = mx * touchX + bx;
                        whackY = my * touchY + by;
                        
                        % Detect a winning whac
                        if (abs(whackX - moleX) < moleSize/2 & abs(whackY - moleY) < moleSize/2)
                            whacked = 1;
                            responseTime = timetags(iTouch) - moleTimetag;
                            disp(sprintf('Mole at (%d,%d) whacked in %d milliseconds', moleX, moleY, floor(responseTime*1000)));
                            break;
                        end
                    end
                end
            end
        end
         
        Datapixx('StopTouchpixxLog');
        Datapixx('RegWrRd');        
    end

    Datapixx('DisableTouchpixx');    % Turn off TOUCHPixx hardware driver
    Datapixx('RegWrRd');
    Screen('CloseAll');
    ShowCursor;
    return;
catch
    Screen('CloseAll');
    ShowCursor;
    psychrethrow(psychlasterror);
end
