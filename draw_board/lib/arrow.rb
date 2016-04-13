# encoding: UTF-8

require 'shapes_life'

class Arrow < Base
    include ShapesLife
    
    def initialize(myApp)
        super myApp
    end
    
    def draw(button, left, top)
        if @current
            button == 3 ? delete : move(@current)
        else
            shape_a = @myApp.arrow left, top, @myApp.shape_width,
                        stroke: @myApp.stroke_color, strokewidth: @myApp.stroke_width, fill: @myApp.fill_color
            shape_a.hover proc { |shp| @current = shp }
            shape_a.leave proc { |shp| @current = nil }
            shape_a.click {} # visual feedback of the "active" area
        end
    end
end
