# encoding: UTF-8

$: << File.expand_path("lib", File.dirname(__FILE__))

require 'polyline'
require 'segment'
require 'curve'
require 'polygon'
require 'ellipse'
require 'rectangle'
require 'star'
require 'arrow'
require 'widgets'


Shoes.app title: 'Drawing Shapes', width: 910, height: 515 do
    
    @polyline = PolylineWidget
    @segment = SegmentWidget
    @curve = CurveWidget
    @polygone = PolygonWidget
    @ellipse = EllipseWidget
    @rectangle = RectangleWidget
    @star = StarWidget
    @arrow = ArrowWidget
    
    CANVAS_LEFT = 120
    CANVAS_TOP = 20
    @drawings_muted = false
    @selected = []
    
    ### UI
    background gray
    
    ## left side panel, shapes and tools
    stack width: CANVAS_LEFT, margin: [5, CANVAS_TOP+5, 0, 0] do
        [@polyline, @segment, @curve, @polygone, @ellipse, @rectangle, @star, @arrow].each do |shp|
            button(shp.to_s.sub("Widget", ''), width: 100) { set_shape_params shp }
        end
        
        button("Clear", margin_top: 30) { @drawings.clear { background white } }
        
        @select_mode = select_tool margin: [25,5,0,0]
        @move_mode = move_tool margin: [25,5,0,0]
        @tool_modes = {"select" => @select_mode, "move" => @move_mode}
        
        button("Quit", left: 5, bottom: 15) { exit }
        
    end
    
    ## drawing area
    @drawings = flow(width: 640, height: 480, margin_top: CANVAS_TOP) { background white }
    
    @drawings.click do |button, left, top|
        unless @drawings_muted
            @drawings.append do 
                
                factory = "#{@current_shape.to_s.sub('Widget', '_widget').downcase}"
                
                if [@polyline, @segment, @curve, @polygone].include? @current_shape
                    # shape needs multi steps to be created, there is no relevant preexisting size
                    @multi_step ||= send(factory)
                    @multi_step.paint(button, left-CANVAS_LEFT, top-CANVAS_TOP)
                else
                    # One shot shape creation, We know beforehand the size of the shape
                    send(factory, shape_width, shape_height)
                        .paint(button, left-CANVAS_LEFT, top-CANVAS_TOP)
                end
            end
        end
    end
    
    ## right side panel, parameters tweaking
    stack width: 120, margin: [10, CANVAS_TOP, 0, 0] do
        @keep_brush = check_text "keep brush", active: true
        @stroke_dim = dim_widget text: "strokewidth", width: 130, el_width: 35
        @stroke_w = color_widget text: " stroke"
        @fill_w = color_widget text: " fill"
        @shape_dim_w = dim_widget text: "width", width: 130, el_width: 50, max: 1000.0
        @shape_dim_h = dim_widget text: "height", width: 130, max: 800.0
        @shape_dim_spikes = dim_widget text: "spikes", width: 130, max: 50.0
    end
    
    ## status panel
    flow margin: [CANVAS_LEFT,5,5,0] do
        background gray 150
        border gray 100
        @status = inscription "", stroke: darkred, margin: [3,0,0,3]
    end
    
    
    
    def canvas_left; CANVAS_LEFT end
    def canvas_top; CANVAS_TOP end
    
    class << self
        attr_reader :current_shape, :drawings, :selected, :select_mode, :move_mode
        attr_accessor :drawings_muted, :multi_step
    end
    
    def stroke_color; @stroke_w.color end
    def stroke_color=(val); @stroke_w.color = val end
    def fill_color; @fill_w.color end
    def fill_color=(val); @fill_w.color = val end
    def stroke_width; @stroke_dim.size end
    def stroke_width=(val); @stroke_dim.size = val end
    def shape_width; @shape_dim_w.size end
    def shape_width=(val); @shape_dim_w.size = val end
    def shape_height; @shape_dim_h.size end
    def shape_height=(val); @shape_dim_h.size = val end
    def shape_count; @shape_dim_spikes.size end
    def shape_count=(val); @shape_dim_spikes.size = val end
    
    def unfinished_shape
        set_status "#{@current_shape.to_s.sub("Widget", '')} is not yet finished ! " \
                   "Try middle mouse button click ..."
    end
    
    @tool_modes.each do |name, mode|
        app.instance_eval %{
            def #{name}_mode=(bool)
                if bool
                    if multi_step
                        @#{name}_mode.activate ## ! triggers deactivation at this point
                        return unfinished_shape
                    end
                    @drawings_muted = true
                    @tool_modes.each { |n,mod| mod.deactivate unless mod == @#{name}_mode }
                else
                    @drawings_muted = false
                end
            end
        }
    end
    
    
    def set_shape_params(current)
        
        return unfinished_shape if multi_step
        
        @current_shape = current
        @tool_modes.each { |name,mode| mode.deactivate }
        @drawings_muted = false
        
        unless @keep_brush.checked?
            @stroke_w.color = black
            @stroke_dim.size = 1
            @fill_w.color = black
        end
        
        params = 
        if [EllipseWidget, RectangleWidget].include? current_shape
            [ @fill_w, @shape_dim_w, @shape_dim_h ].each &:show
            @shape_dim_spikes.hide
            {"width" => 100, "height" => 45}
            
        elsif current_shape == StarWidget
            [@fill_w, @shape_dim_w, @shape_dim_h, @shape_dim_spikes
            ].each &:show
            {"count" => 5, "outer" => 60, "inner" => 35}
            
        elsif current_shape == ArrowWidget
            [ @fill_w, @shape_dim_w].each &:show
            [@shape_dim_h, @shape_dim_spikes].each &:hide
            {"width" => 60}
            
        elsif current_shape == PolygonWidget
            [@shape_dim_w, @shape_dim_h, @shape_dim_spikes
            ].each &:hide
            @fill_w.show
            {"blank" => nil}
            
        elsif [PolylineWidget, SegmentWidget, CurveWidget].include? current_shape
            [@fill_w, @shape_dim_w, @shape_dim_h, @shape_dim_spikes
            ].each &:hide
            {"blank" => nil}
        end
                
        params.each do |param, value|
            case param
            when "outer"
                @shape_dim_w.size = value
                @shape_dim_w.text = "outer"
            when "inner"
                @shape_dim_h.size = value
                @shape_dim_h.text = "inner"
            when "blank"
                check_labels
            else
                send "shape_#{param}=", value
                check_labels
            end
        end
        
    end
    
    def check_labels
        @shape_dim_w.text = "width" if @shape_dim_w.text == "outer"
        @shape_dim_h.text = "height" if @shape_dim_h.text == "inner"
    end
    
    # timeout unit is seconds
    def set_status(message, timeout=3)
        @status.text = message
        anim = animate(2) do |fr|
            if fr == timeout*2
                @status.text = ""
                anim.stop; anim.remove; anim = nil
            end
        end
    end
end



