# encoding: UTF-8

require 'shapes_common'

class ArrowWidget < Shoes::Widget
    include ShapesCommon
    
    def initialize(w, h)
        @width = @height = w
        
        @selecting = false
        @moving = false
    end
    
    def paint(button, left, top)
        main_slot = flow left: left-@width/2, top: top-@height/2, 
                    width: @width+app.stroke_width*2, height: @width+app.stroke_width*2 do
            
            arrow app.stroke_width+app.shape_width/2, app.stroke_width+app.shape_width/2, app.shape_width, 
                    stroke: app.stroke_color, strokewidth: app.stroke_width, fill: app.fill_color
            @brd = border darkorange, dash: :onedot, hidden: true
            
            hover {  }
            leave {  }
            click { |b,l,t|
                if app.move_mode.active?
                    app.selected << self if app.selected.empty?
                    move(main_slot) if app.selected[0] == self
                elsif app.select_mode.active?
                    select(main_slot)
                    delete(main_slot) if b == 3
                end
            }
        end
    end
end
