# encoding: UTF-8

require 'shapes_life'

class Polygon < Base
    include ShapesLife
    
    def initialize(myApp)
        super myApp
        
        @temps = []
        @points = []   
        @ox, @oy = 0, 0
    end
    
    def draw(button, left, top) 
        if @current
            button == 3 ? delete : move(@current)
        else
            @points.push [left, top]
            @temps << @myApp.oval(left, top, 4, fill: @myApp.black)
            
            if @points.size == 1
                @ox, @oy = left, top
            end

            if button == 2
                @points.pop
                @temps.each &:remove; @temps.clear
                
                shape_p = @myApp.shape left: @ox, top: @oy, stroke: @myApp.stroke_color,
                            strokewidth: @myApp.stroke_width, fill: @myApp.fill_color do 
                    @points.each { |p| @myApp.line_to p[0]-@ox, p[1]-@oy }
                    @myApp.line_to 0, 0
                end
                shape_p.hover proc { |shp| @current = shp }
                shape_p.leave proc { |shp| @current = nil }
                shape_p.click {} # gives a visual feedback of the "active" area
                
                @points.clear
            end
        end
    end
    
end
