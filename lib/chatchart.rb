#
# ChatChart
# chatchart.rb - ASCII Graphs
#
# use this to create an ascii graph described using a simple array of
# vertex adjacencies. just check out the sample driver (sample.rb)
#
# Copyright(c) 2009 by Christopher Abad
# aempirei@gmail.com
# http://www.twentygoto10.com/
#
# this code is licensed under the "don't be a retarded asshole" license.
# if i don't like how you use this software i can tell you to fuck off
# and you can't use it, otherwise you can use it.
#

require 'point'
require 'particle'

class Symbol
    def <=>(b)
        self.to_s <=> b.to_s
    end
    def -(b)
        ChatChart::Edge[self,b]
    end
end

class Circuit
    def self.[](p)
        edges = []
        p.split(//).each_cons(2) { |a,b| edges << a.to_sym - b.to_sym }
        edges
    end
end

module ChatChart

# a canvas is the primary drawing space

class Canvas < Hash
    def [](p)
        raise 'non-point' unless p.is_a? P
        super(p)
    end

    def <<(g)
        case g
            when Proc
                g.call(self)
            else
                raise 'non-curve-proc' unless g < Curve
        end
        self
    end

    def []=(p,v)
        raise 'non-point' unless p.is_a? P
        raise 'non-char' unless v.is_a?(String) and v.length == 1
        super(p,v)
    end

    def bounds
        xs = keys.map { |p| p.x }.sort
        ys = keys.map { |p| p.y }.sort

        return [ P[xs.first,ys.first], P[xs.last,ys.last] ]
    end

    def window(ul,lr)
        str = ''
        ul = ul.quantize
        lr = lr.quantize
        ((ul.y)..(lr.y)).each do |y|
            ((ul.x)..(lr.x)).each do |x|
                p = P[x,y]
                if has_key?(p)
                    str << self[p]
                else
                    str << ' '
                end
            end
            str << "\n"
        end
        return str
    end

    def to_s
        window *bounds
    end
end

# the curve is a general path through the canvas space, which consists of some geometric description
# and the [] operator which returns a proc that accepts a single canvas parameter which is then drawn to

class Curve
    def self.[](*geometry)
        proc { |canvas| self.draw(canvas, *geometry) }
    end
    def self.draw(canvas, *geometry)
        raise 'undefined method'
    end
    def self.get_point(*geometry)
        case geometry.first
            when P
                geometry.first
            when Integer
                P[geometry.first, geometry.last]
            else
                raise 'invalid-geometry'
        end
    end
    def self.get_points(*geometry)
        return [] if geometry.empty?
        case geometry.first
            when P
                [ geometry.shift.dup ] + get_points(*geometry)
            when Integer
                [ P[geometry.shift, geometry.shift] ] + get_points(*geometry)
            else
                raise 'invalid-geometry'
        end
    end
    def self.get_interval(*geometry)
        points = get_points(*geometry)
        points.first .. points.last
    end
end

# titles are just an instance of a general curve, where there is
# some geometry describing their origin and a block describing
# their differential motion

class Title < Curve
    def self.[](title, blk, *geometry)
        proc { |canvas| self.draw(canvas, title, *geometry, &blk) }
    end

    def self.draw(canvas, title, *geometry, &blk)
        p = get_point(*geometry).quantize
        title.to_s.split(//).each do |ch|
            canvas[p] = ch
            p = blk.call(p)
        end
    end
end

class Dot < Curve
    def self.[](dot, *geometry)
        proc { |canvas| self.draw(canvas, dot, *geometry) }
    end

    def self.draw(canvas, dot, *geometry)
        p = get_point(*geometry)
        canvas[p] = dot
    end
end

# lines are just an instance of a general curve, where there is some geometry describing their path

class Line < Curve
    def self.[](*geometry)
        proc { |canvas| self.draw(canvas, *geometry) }
    end
end

# L1-norm (taxicab norm) lines are drawn up/down then left/right from origin (a) to destination (b)

class L1Line < Line
    def self.draw(canvas, *geometry)

        a,b = get_points(*geometry)
        a.quantize!
        b.quantize!
        c = a % b

        y1,y2 = [a.y,c.y].sort

        (y1..y2).each do |y|
            p = P[c.x,y]
            next if p == c
            canvas[p] = '|'
        end

        x1,x2 = [b.x,c.x].sort

        (x1..x2).each do |x|
            p = P[x,c.y]
            next if p == c
            canvas[p] = '-'
        end

        canvas[c] = '+'
        canvas[a] = 'o'
        canvas[b] = 'o'
    end
end

# a hockey line is somewhere between an L1-norm and L2-norm topology where the topology
# is constructed from 0, 45, and 90 degree edges with unit projections onto x and y and
# where length of a vector v is calculated as follows:
# v = <dx,dy>
# dz = min(dx,dy)
# dw = |dx-dy|
# |v| = |<dz,dz>|+dw

class HLine < Line
    def self.draw(canvas, *geometry)

        a,b = get_points(*geometry)
        a.quantize!
        b.quantize!

        v = b-a

        amstep = (v.proj(P::J).unit + v.proj(P::I).unit)
        amstep.quantize!
        am = amstep * v.norm(:min)
        am.quantize!

        mb = v-am
        mbstep = mb.unit.quantize

        pos = a

        while pos != a + am
            pos += amstep
            canvas[pos] = (amstep.monic == P[1,1]) ? '\\' : '/'
        end

        while pos != b
            pos += mbstep
            canvas[pos] = (mbstep.x == 0.0) ? '|' : '-'
        end

        canvas[a + am] = '+'
        canvas[a] = 'o'
        canvas[b] = 'o'
    end
end

class WiggleLine < Line
end

class Edge
    attr_accessor :from
    attr_accessor :to

    def self.[](a,b)
        new(a,b)
    end

    def initialize(a,b)
        raise 'invalid-edge' unless a.is_a? Symbol and b.is_a? Symbol
        @from,@to = [a,b].sort
    end

    def name
        "#{from} -- #{to}".to_sym
    end

    def to_a
        [from,to]
    end

    def hash
        to_a.hash
    end
    
    def neighbor(v)
        v == to ? from : to
    end

    # check for edge endpoint inclusion of a vertex (or by name of vertex)
    def ===(v)
        case v
            when Array
                v.inject(false) { |acc,w| acc ||= (self === w) }
            when Vertex
                self === v.name
            when Symbol
                @from == v or @to == v
            else
                raise 'invalid-comparison'
        end
    end
    # compare two edges (undirected)
    def ==(e)
        raise 'invalid-comparison' unless e.is_a? Edge
        from == e.from and to == e.to
    end
end

class Vertex
    attr_reader :p
    attr_reader :name
    def initialize(name)
        raise 'non-symbol' unless name.is_a? Symbol
        @p = Particle[]
        @name = name
    end
    def initialize_copy(orig)
        @p = @p.dup
    end
    def hash
        @name.hash
    end
    # compare vertices, which allows for comparison against symbols, which is the vertex name type
    def ===(v)
        case v
            when Array
                v.inject(false) { |acc,w| acc ||= (self === w) }
            when Symbol
                self.name == v
            when Vertex
                self == v
            else
                raise 'invalid-comparison'
        end
    end
    def ==(v)
        raise 'invalid-comparison' unless v.is_a? Vertex
        self.name == v.name
    end
end

# graphs are collections of vertices and edges without layout information

class Graph
    attr_reader :e      # edges
    attr_reader :v      # vertices
    attr_accessor :root # root node name
    def initialize(root=nil)
        @e = {}
        @v = {}
        @root = case root
            when Symbol
                root
            when Vertex
                root.name
            when NilClass
                # do nothing
            else
                raise 'invalid-root-node'
        end
        self << root if root
    end
    def initialize_copy(orig)
        @e = @e.dup
        @v = @v.dup
    end
    def <<(elem)
        case elem
        when Graph
            self << elem.v.values << elem.e.values
        when Array
            elem.each { |q| self << q }
        when Edge
            @e[elem.name] = elem.dup
            self << elem.from unless @v[elem.from]
            self << elem.to unless @v[elem.to]
        when Vertex
            @v[elem.name] = elem.dup
        when Symbol
            self << Vertex.new(elem)
        when NilClass
            # do nothing
        else
            raise 'non-graph-element'
        end
        self
    end
    def to_s
        v_str = @v.keys.map { |s| "\t#{s};\n" }.join 
        e_str = @e.keys.map { |s| "\t#{s};\n" }.join 
        "#{self.class.name.downcase} g {\n#{e_str}#{v_str}};\n"
    end
    def to_canvas(linestyle = L1Line)
        canvas = Canvas.new
        @e.values.each { |e| canvas << linestyle[ @v[e.from].p.p, @v[e.to].p.p ] }
        @v.values.each { |v| canvas << Title[ v.name, proc { |p| p.r }, v.p.p ] }
        canvas
    end

    def find_edges(*vs)
        @e.values.select { |e| e === vs }
    end

    def neighborhood(v)
        find_edges(v).map { |e| @v[e.neighbor(v)] }
    end

    def [](*vs)
        Graph.new(vs.first) << find_edges(*vs)
    end

    def degree(v)
        find_edges(v).length
    end

    def pop(*vs)
        # pop assumes vertices come in as their name, not a full vertex object
        k1hood = self[*vs]                      # get k-1 N
        vs.each { |v| @v.delete v }             # delete k-1 N vertices
        k1hood.e.keys.each { |e| @e.delete e }  # delete k-1 N edges
        k1hood                                  # return k-1 N
    end

    def span(plan)

        remaining = dup
        popped = remaining.pop plan.get_root(remaining)
        tree = Graph.new << popped.root

        until remaining.v.empty?
            border = self[*tree.v.keys][*remaining.v.keys]  # find edges on the border between the tree and the remaining graph
            edge = plan.get_edge(border)                    # choose one edge and new node to add to the tree
            tree << edge                                    # add to the tree
            remaining.pop(edge.from, edge.to)               # remove k-1 N from remaining graph
        end

        tree
    end

    def energy
        @v.values.inject(0.0) { |sum,v| sum += (v.p.v * v.p.m).norm }
    end
end

# edge/node selection plan for things like spanning trees
class Plan
end

class FirstPlan < Plan
    def self.get_edge(graph)
        graph.e.values.first
    end
    def self.get_root(graph)
        graph.v.keys.first
    end
end

# layouts take graphs and output canvases, when then can be printed or whatever

class Layout
    def self.[](*as)
        self.layout(*as)
        self
    end
    def self.layout(*as)
        raise 'undefined method'
    end
end

# random layout places vertices at random and then connects them via L1-norm edges

class RandomLayout < Layout
    def self.layout(g,width,height)
        g.v.values.each { |v| v.p.p.randomize!(width,height) }
        self
    end
end

class SmartLayout < Layout

    CW_SZ = 200 # convolution window size

    def self.layout(g,iter=nil)

        RandomLayout[g, 40, 24] if iter.nil?

        es = []
        ps = g.v.values.map { |v| v.p }
        ses = 0 

        while iter.nil? or (iter -= 1) >= 0;

            # update the gravity field
            ps.each { |p| p.a = p.n_body_acceleration(ps.reject { |q| q.object_id == p.object_id }) }

            # update the bond field
            g.v.keys.each do |v|
                p = g.v[v].p
                qs = g.neighborhood v
                p.b = p.n_body_bond(qs.map { |q| q.p })
            end

            # update the velocities
            ps.each do |p|
                p.v *= Particle::Z
                p.v += p.a * Particle::DT
                p.v += p.b * Particle::DT
            end

            # project new positions
            ps.each { |p| p.p += p.v * Particle::DT }

            # check system energy delta or iteration count

            es << g.energy

            if es.length >= CW_SZ
                es = es[-CW_SZ,CW_SZ]
                pses = ses
                ses = es[-CW_SZ,CW_SZ].inject(0.0) { |sum,e| sum += e }.to_f / CW_SZ
                de = ses - pses
                break if de.abs < 0.005
            else
                ses = 1000
                de = 1000
            end
        end

        self
    end
end

end # module ChatChart
