function [  ] = modiflabels( lab )

    % my old style
%     set(lab, 'FontWeight', 'bold')
%     set(lab, 'FontAngle', 'Italic')
%     set(lab, 'FontName', 'Arial');  
%     set(lab, 'FontSize', 16)
    % <- my old style

    % my new style (to use with print function)
    set(lab, 'FontName', 'Times New Roman');
    set(lab, 'FontAngle', 'italic')
    set(lab, 'FontWeight', 'normal')
    set(lab, 'FontSize', 9)
    % <- my new style
end
