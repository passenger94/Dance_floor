# encoding: UTF-8

class Polyline < Base
    
    def initialize(myApp)
        super myApp
        
        @points = [] 
        @all = []
    end

    def draw(button, left, top)
        @points.push [left, top]
        if button == 1
            if @points.size == 2
                shp = @myApp.line *@points.flatten, stroke: @myApp.stroke_color, strokewidth: @myApp.stroke_width
                @all << shp
            
                @points.shift
            end
            
        elsif button == 2
            @points.clear
            @all.clear
        elsif button == 3
            delete
            @points.clear
            @all.clear
        end
    end

    def delete
        @all.each { |p| p.remove }
    end

end

