# encoding: UTF-8

class Segment < Base
    
    def initialize(myApp)
        super myApp
        
        @points = []
    end
    
    def draw(button, left, top)
        if button == 1
            @points.push [left, top]

            if @points.size == 2 
                @shape_segment = @myApp.line *@points.flatten, stroke: @myApp.stroke_color, strokewidth: @myApp.stroke_width
            elsif @points.size > 2
                @points.clear
                @points.push [left, top]
            end
        elsif button == 3
            delete
        end
    end

    def delete
        @shape_segment.remove
        @points.clear
    end


end
