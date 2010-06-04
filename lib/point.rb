#
# Point
# point.rb - Simple 2-D Point
#
# Copyright(c) 2009 by Christopher Abad
# aempirei@gmail.com
# http://www.twentygoto10.com/
#
# this code is licensed under the "don't be a retarded asshole" license.
# if i don't like how you use this software i can tell you to fuck off
# and you can't use it, otherwise you can use it.
#

module ChatChart
class P
    attr_accessor :x
    attr_accessor :y

    def initialize(*ns)
        @x = ns[-2] || 0
        @y = ns[-1] || 0
    end

    def self.[](*ns)
        new *ns
    end

    I = P[1,0]
    J = P[0,1]

    def self.zero
        return P[]
    end

    def randomize!(width,height)
        @x = rand width
        @y = rand height
        self
    end

    def self.random(width,height)
        new.randomize! width, height 
    end

    def quantize!
        self << self.quantize
    end

    def quantize
        P[@x.round.to_i, @y.round.to_i]
    end

    def vector
        P[@x.to_f,@y.to_f]
    end

    def to_s
        "(%05.1f,%05.1f)" % [@x,@y]
    end

    def to_a
        [@x,@y]
    end

    def eql?(p)
        p.is_a?(P) and (@x == p.x) and (@y == p.y)
    end

    def hash
        [@x,@y].hash
    end

    def <=>(p)
        (@x * @x + @y * @y) <=> (p.x * p.x + p.y * p.y)
    end

    # vector addition
    def +(p)
        P[@x + p.x, @y + p.y]
    end

    # both scalar product and dot product
    def *(v)
        case v
            when P
                (@x * v.x + @y * v.y)
            else
                P[@x * v, @y * v]
        end            
    end

    def /(v)
        self * (1.0 / v.to_f)
    end

    def unit
        return P.zero if self == P.zero
        self / norm
    end

    def comp(b)
        norm * cos(b)
    end

    def monic
        self.vector / @x
    end

    def proj(b)
        b.unit * (self * b.unit)
    end

    def cos(b)
        unit * b.unit
    end

    S2 = Math::sqrt(2.0)

    def aspect(k=1.3)
        P[@x, @y * k]
    end

    def norm(v=2)
        case v
            when 1
                (@x.abs + @y.abs).to_f
            when 2
                Math::hypot @x, @y
            when Numeric
                (@x.abs ** v + @y.abs ** v) ** (1.0 / v)
            when :ascii
                aspect.norm
            when :min
                [@x.abs,@y.abs].min
            when :max
                [@x.abs,@y.abs].max
            when :h
                norm(:min) * (S2 - 1) + norm(:max)
            else
                1.0
        end
    end

    def <<(p)
        @x = p.x
        @y = p.y
        self
    end

    def u! ; self << self.u ; end
    def d! ; self << self.d ; end
    def l! ; self << self.l ; end
    def r! ; self << self.r ; end

    def u ; P[@x,@y-1] ; end
    def d ; P[@x,@y+1] ; end
    def l ; P[@x-1,@y] ; end
    def r ; P[@x+1,@y] ; end

    def ==(p) ; eql?(p)    ; end
    def %(p)  ; P[@x,p.y]  ; end
    def -@    ; P[-@x,-@y] ; end
    def +@    ; self       ; end
    def ~@    ; P[@y,@x]   ; end
    def -(p)  ; self + -p  ; end
end
end
