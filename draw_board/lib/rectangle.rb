# encoding: UTF-8

require 'shapes_life'

class Rectangle < Base
    include ShapesLife
    
    def initialize(myApp)
        super myApp
    end
    
    def draw(button, left, top)
        if @current
            button == 3 ? delete : move(@current)
        else
            shape_r = @myApp.rect left, top, @myApp.shape_width, @myApp.shape_height, center: true,
                        stroke: @myApp.stroke_color, strokewidth: @myApp.stroke_width, fill: @myApp.fill_color
            shape_r.hover proc { |shp| @current = shp }
            shape_r.leave proc { |shp| @current = nil }
            shape_r.click {} # visual feedback of the "active" area
        end
    end
    
end
