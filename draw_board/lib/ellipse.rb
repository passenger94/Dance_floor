# encoding: UTF-8

require 'shapes_life'

class Ellipse < Base
    include ShapesLife
    
    def initialize(myApp)
        super myApp 
    end
    
    def draw(button, left, top)
        if @current
            button == 3 ? delete : move(@current)
        else
            shape_e = @myApp.oval left, top, @myApp.shape_width, @myApp.shape_height, center: true, 
                        stroke: @myApp.stroke_color, strokewidth: @myApp.stroke_width, fill: @myApp.fill_color
            shape_e.hover proc { |shp| @current = shp }
            shape_e.leave proc { |shp| @current = nil }
            shape_e.click {} # visual feedback of the "active" area
        end
    end
end

