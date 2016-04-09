# encoding: UTF-8

#
# Credits, inspiration
# https://github.com/elm-city-craftworks/practicing-ruby-examples/tree/master/v6/003
#

require "FivePhilo_Celluloid"

Shoes.app title: "Symposium", width: 500 do
    
    @philos_names = %w{Heraclitus Nietsche Aristotle Epictetus Hypatia_of_Alexandria}
    philosophers = @philos_names.map { |name| Philosopher.new(name) }
    
    @seats = philosophers.size
    @waiter = Waiter.new(@seats)
    @philos, @chopsticks, @chopsticks_busy, @soups, @thoughts = [], [], [], [], []
    
    @scenery = stack do
        ## table
        oval 250, 250, 300, center: true, fill: brown, stroke: black
        
        transform :center
        radians = 360/@seats * Math::PI/180
        
        ## philosophers + bowls + thoughts
        @seats.times do |i|
            # rotate, all transforms are cumulative !!
            rotate 360/@seats
            
            @philos << (ph = oval 250, 250, 100, 50, center: true, fill: sandybrown, stroke: gray)
            bw = oval 250, 250, 52, center: true, fill: black, stroke: black
            @soups << (sp = oval left: 250, top: 250, radius: 25, center: true, fill: green, stroke: black(0))
            
            x = Math.sin((i+1) * radians) * 150
            y = Math.cos((i+1) * radians) * 150
            ph.move x+250, y+250
            bw.move (x/1.7).to_i+250, (y/1.7).to_i+250
            sp.move (x/1.7).to_i+250, (y/1.7).to_i+250
            
            @thoughts << (th = image 200,200, top: 0, left: 0 do
                oval 100, 100, 10, center: true, fill: white, stroke: black
                oval 106, 110, 20, center: true, fill: white, stroke: black, strokewidth: 2
                oval 138, 130, 80, 38, center: true, fill: white, stroke: black, strokewidth: 2
                oval 138, 135, 45, 50, center: true, fill: white, stroke: black, strokewidth: 2
                oval 125, 127, 45, 50, center: true, fill: white, stroke: black, strokewidth: 2
                oval 145, 127, 45, 50, center: true, fill: white, stroke: black, strokewidth: 2
                oval 138, 130, 70, 50, center: true, fill: white, stroke: black, strokewidth: 2
                glow 6, inner: true
                shadow -5, 3, fill: black(0.2)
            end)
            th.move (x*1.24).to_i+150, (y*1.24).to_i+150
        end
        
        ## chopsticks
        rotate 360/@seats/2
        @seats.times do |i|
            rotate 360/@seats
            @chopsticks << (ch = rect 250, 250, 5, 75, center: true, 
                                        fill: gold, stroke: gray)
            angle = (i+1) * radians + ((360/@seats/2)*Math::PI/180)
            x = Math.sin(angle) * 90
            y = Math.cos(angle) * 90
            ch.move x+250, y+250
            
            chb_right = rect 250, 250, 5, 75, center: true, hidden: true,
                                        fill: gold, stroke: gray
            rotate -360/@seats
            chb_left = rect 250, 250, 5, 75, center: true, hidden: true,
                                        fill: gold, stroke: gray
            rotate 360/@seats
            @chopsticks_busy << [chb_left, chb_right]
            anglebusy = (i+1) * radians
            xb = Math.sin(anglebusy) * 100
            yb = Math.cos(anglebusy) * 100
            [chb_left, chb_right].each { |c| c.move xb+250, yb+250 }
        end
        
        start { @waiter.table.chopsticks.each { |c| c.drawn = true }
                @thoughts.each &:hide 
              }
    end
    
    button "Spirit and Matter" do
        break deadlocktocome if @seats < 3
        
        @soups.each { |sp| sp.style(radius: 25) }
        @thoughts.each { |t| t.scale 1.0; t.hide }
        @waiter.table.chopsticks.each { |c| c.drawn = true }
        @naps = []
        @shhh ||= para "Philosophers nap time ...", top: 450, align: "center"
        @shhh.hide
        philosophers.each_with_index do |philosopher, i|
            @philos[i].style(fill: sandybrown)
            
            philosopher.async.dine(@waiter, i) 
        end
    end
    
    para "a Philosophers Diner"
    
    def deadlocktocome
        error "Two philosophers left alone could lead to deadlocks ;-)"
        Shoes.show_log
    end
    
    def update(event, *args)
        if event == "sleep"
            idx = @philos_names.index args[0]
            @thoughts[idx].hide
            @philos[idx].style(fill: gray)
            @naps << @philos_names
            @shhh.show if @naps.size == @seats
            
        elsif event == "think"
            idx = @philos_names.index args[0]
            @thoughts[idx].show
        else
            idx0 = @waiter.table.chopsticks.index args[0] # left
            idx1 = @waiter.table.chopsticks.index args[1] # right (is the reference)
            @thoughts[idx1].hide
            
            if event == "take"
                [idx0,idx1].each {|i| @chopsticks[i].hide}
                @chopsticks_busy[idx1].each &:show
                args.each { |c| c.drawn = false }
                
            else
                @chopsticks_busy[idx1].each &:hide
                [idx0,idx1].each {|i| @chopsticks[i].show}
                args.each { |c| c.drawn = true }
                
                @soups[idx1].style(radius: @soups[idx1].style[:radius]-5)
            end
        end
    end    
    
    philosophers.each { |p| p.add_observer(self) }
    
end


