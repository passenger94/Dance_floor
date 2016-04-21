# encoding: UTF-8

module ShapesCommon
    
    def self.included(base)
        base.send :define_method, :to_s, proc { "#{base.to_s}_#{self.object_id}" }
    end
    
    def delete(slot)
        if confirm "about to delete #{self}, Sure? "
            # trying to delete self directly doesn't work
            # main_slot is shadowing self !!
            # main_slot is NOT a child of self !! we have two slots, probably main_slot over self
            slot.remove
            self.remove
        end
    end
    
    def select(slot)
        @selecting = !@selecting
        
        @selecting ? @brd.show : @brd.hide
    end
    
    def move(slot)
        @moving = !@moving
        
        if @moving
            @brd.show
            anim = animate(25) do |fr|
                b,l,t = mouse
                slot.move l-(app.canvas_left+@width/2), t-(app.canvas_top+@height/2)
                if not @moving
                    anim.stop; anim.remove; anim = nil
                    @brd.hide
                    app.selected.delete(self)
                end
            end
        end
    end
end
