# encoding: UTF-8

require 'shapes_common'

class CurveWidget < Shoes::Widget
    include ShapesCommon
    
    def initialize(options={})
        @temps = []
        @points = []   
        @ox, @oy = 0, 0
        
        @selecting = false
        @moving = false
    end
    
    def paint(button, left, top)
        
        @points.push [left, top]
        @temps << oval(left, top, 4, fill: black)
        
        if @points.size == 1
            @ox, @oy = left, top
        end
        
        if @points.size == 3
            @temps.each &:remove; @temps.clear
            
            points_tr = @points.transpose
            minx = points_tr[0].min
            miny = points_tr[1].min
            @width = points_tr[0].max - minx
            @height = points_tr[1].max - miny
            startx = (@ox > minx ? @ox-minx : 0) + app.stroke_width
            starty = (@oy > miny ? @oy-miny : 0) + app.stroke_width
            
            coords = @points.each_with_object([]) { |p,m| m << (p[0]-(@ox-startx)) << (p[1]-(@oy-starty)) }
            
            main_slot = flow left: minx-app.stroke_width*2, top: miny-app.stroke_width*2, 
                        width: @width+app.stroke_width*2, height: @height+app.stroke_width*2 do
                
                shape stroke: app.stroke_color, strokewidth: app.stroke_width do 
                    nofill
                    move_to coords[0], coords[1]
                    curve_to *coords
                end
                @brd = border darkorange, dash: :onedot, hidden: true
                
                hover { |slot| 
                }
                leave { |slot|
                }
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
            
            app.multi_step = nil
            
        elsif @points.size > 3
            @points.clear
            @points.push [left, top]
            @ox, @oy = left, top
        end
    end
end

