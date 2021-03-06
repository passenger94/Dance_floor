# encoding: UTF-8

require 'shapes_common'

class PolygonWidget < Shoes::Widget
    include ShapesCommon
    
    def initialize
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

        if button == 2
            @points.pop
            @temps.each &:remove; @temps.clear
            
            points_tr = @points.transpose
            minx = points_tr[0].min
            miny = points_tr[1].min
            @width = points_tr[0].max - minx
            @height = points_tr[1].max - miny
            startx = (@ox > minx ? @ox-minx : 0) + app.stroke_width
            starty = (@oy > miny ? @oy-miny : 0) + app.stroke_width
            
            main_slot = flow left: minx-app.stroke_width*2, top: miny-app.stroke_width*2, 
                        width: @width+app.stroke_width*2, height: @height+app.stroke_width*2 do
                
                shape stroke: app.stroke_color, strokewidth: app.stroke_width,
                      fill: app.fill_color do 
                    
                    move_to startx, starty
                    @points.each { |p| line_to p[0]-(@ox-startx), p[1]-(@oy-starty) }
                    line_to startx, starty
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
            
            @points.clear
            app.multi_step = nil
        end
    end
    
end
