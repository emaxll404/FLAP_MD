Screen('TextFont',w, 'Arial');Screen('TextSize',w, 42);%     Screen('TextStyle', w, 1+2);Screen('FillRect', w, gray);colorfixation = white;if site==4DrawFormattedText(w, 'Prendi una piccola pausa. \n\n  \n \n \n \n Premi un tasto qualsasi per cotinuare', 'center', 'center', white);elseDrawFormattedText(w, 'Rest your eyes. \n\n  \n \n \n \n Press any key to start', 'center', 'center', white);endScreen('Flip', w);KbQueueWait;