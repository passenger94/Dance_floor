# encoding: UTF-8

require 'shapes_life'

class Star < Base
    include ShapesLife
    
    def initialize(myApp)
        super myApp
    end

    def draw(button, left, top)
        if @current
            button == 3 ? delete : move(@current)
        else
            shape_s = @myApp.star left, top,  @myApp.shape_count, @myApp.shape_width, @myApp.shape_height, 
                        stroke: @myApp.stroke_color, strokewidth: @myApp.stroke_width, fill: @myApp.fill_color
            shape_s.hover proc { |shp| @current = shp }
            shape_s.leave proc { |shp| @current = nil }
            shape_s.click {} # visual feedback of the "active" area # doesn't work !?!
        end
    end
    
end
