function [ ] = modiffigures( fig, axs, varargin)

    set(axs, 'LineWidth', 0.6)
    set(axs, 'FontName', 'Times New Roman');
    set(axs, 'FontWeight', 'normal')
    set(axs, 'FontSize', 9)
    set(axs, 'XMinorTick', 'on')
    set(axs, 'YMinorTick', 'on')
    
    set(fig, 'Units', 'Centimeters')
    set(fig, 'PaperPosition', [0 0 8 6])   % changes width and height of final picture
    
    for ii = 1:nargin-2
        if strcmp(varargin(ii), 'CO')
            set(axs, 'FontAngle', 'italic')
            
            child = get(fig, 'Children');
            chStr1 = get(child(1), 'XLabel');
            chStr2 = get(child(1), 'YLabel');
            set([chStr1 chStr2], 'FontName', 'Times New Roman');
            set([chStr1 chStr2], 'FontWeight', 'normal')
            set([chStr1 chStr2], 'FontSize', 9)
            set([chStr1 chStr2], 'FontAngle', 'italic')
            
            chStr = get(axs, 'XTickLabel');
            for iii = 1:size(chStr,1)       % должен быть способ элегантнее!
                for iv = 1:size(chStr,2)
                    if chStr(iii,iv) == '.'
                        chStr(iii,iv) = ',';
                    end
                end
            end
            set(axs, 'XTickLabel', chStr);
            
            chStr = get(axs, 'YTickLabel');
            for iii = 1:size(chStr,1)       % должен быть способ элегантнее!
                for iv = 1:size(chStr,2)
                    if chStr(iii,iv) == '.'
                        chStr(iii,iv) = ',';
                    end
                end
            end
            set(axs, 'YTickLabel', chStr)
        end
        
        if strcmp(varargin(ii), 'threeinrow')           % FIX!
            set(fig, 'PaperPosition', [0 0 5.3 4])      % changes width and height of final picture
        end

        if strcmp(varargin(ii), 'CO-bar') 
            child = get(fig, 'Children');   % changes width and height of final picture
            chStr = get(child(1), 'YTickLabel');
            for iii = 1:size(chStr,1)       % должен быть способ элегантнее!
                for iv = 1:size(chStr,2)
                    if chStr(iii,iv) == '.'
                        chStr(iii,iv) = ',';
                    end
                end
            end
            set(child(1), 'YTickLabel', chStr);
        end
        
        if strcmp(varargin(ii), 'mdpi') 
            set(axs, 'FontName', 'Palatino Linotype');
            
            child = get(fig, 'Children');
            chStr1 = get(child(1), 'XLabel');
            chStr2 = get(child(1), 'YLabel');
            set([chStr1 chStr2], 'FontName', 'Palatino Linotype');
            set([chStr1 chStr2], 'FontWeight', 'normal')
            set([chStr1 chStr2], 'FontSize', 9)
        end
    end

%     print '-dtiff' -r300 'fig'
end