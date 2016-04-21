# encoding: UTF-8

require 'shapes_common'

class StarWidget < Shoes::Widget
    include ShapesCommon
    
    ## TODO size and placements are rough approximation !
    def initialize(w, h)
        @width = @height = w
        
        @selecting = false
        @moving = false
    end
    
    def paint(button, left, top)
        main_slot = flow left: left-@width-app.stroke_width*3, top: top-@width-app.stroke_width*3, 
                    width: app.shape_width*2+app.stroke_width*6, height: app.shape_width*2+app.stroke_width*6 do
            
            star app.stroke_width*3+app.shape_width, app.stroke_width*3+app.shape_width, app.shape_count, app.shape_width, app.shape_height, 
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
    
    def move(slot)
        @moving = !@moving
        
        if @moving
            @brd.show
            anim = animate(25) do |fr|
                b,l,t = mouse
                slot.move l-(app.canvas_left+@width+app.stroke_width*3), t-(app.canvas_top+@width+app.stroke_width*3)
                if not @moving
                    anim.stop; anim.remove; anim = nil
                    @brd.hide
                    app.selected.delete(self)
                end
            end
        end
    end
end
