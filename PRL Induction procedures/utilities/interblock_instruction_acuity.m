Screen('TextFont',w, 'Arial');Screen('TextSize',w, 42);%     Screen('TextStyle', w, 1+2);Screen('FillRect', w, gray);colorfixation = white;DrawFormattedText(w, 'Report the orientation of the gap of the C \n \n Press any key to start', 'center', 'center', white);Screen('Flip', w);KbQueueWait;