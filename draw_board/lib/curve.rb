# encoding: UTF-8

class Curve < Base
    
    def initialize(myApp)
        super myApp
        
        @temps = []
        @points = []
        @all = []
    end
    
    def draw(button, left, top)
        if button == 1
            @points.push [left, top]
            @temps << @myApp.oval(left, top, 4, fill: @myApp.black)
            
            if @points.size == 3
                @temps.each &:remove; @temps.clear
                shape_c = @myApp.shape stroke: @myApp.stroke_color, strokewidth: @myApp.stroke_width do
                    @myApp.nofill
                    @myApp.move_to *@points[0]
                    @myApp.curve_to *@points.flatten
                end
                @all << shape_c
                
            elsif @points.size > 3
                @points.clear
                @points.push [left, top]
            end
        elsif button == 3
            delete
        end
    end

    def delete
        @all.last.remove
        @points.clear
    end
end
