#
# particle.rb - Physics Particle Code
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

module ChatChart
class Particle

    DT = 0.50        # time delta
    G = -20.0        # universal constant of gravity
    M = 300.0         # electron charge bond constant
    Z = 0.90         # friction
    D = 8.00         # bond distance

    EPSILON = 0.03
    NORMMIN = 0.002

    attr_accessor :p # position
    attr_accessor :m # mass
    attr_accessor :v # velocity
    attr_accessor :a # acceleration
    attr_accessor :b # bond

    def hash
        object_id.hash
    end

    def self.[](*ns)
        self.new P[*ns].vector
    end

    def initialize(p=P[0.0,0.0])
        @m = 1.0
        @v = P[0.0,0.0]
        @p = p
    end

    def acceleration(p)
        force(p) / @m
    end

    # electron bond attraction
    def bond(p)
        v = p.p - self.p
        return P.zero if v == P.zero
        return P.zero if v.aspect.norm < D - EPSILON
        v0 = v.aspect.norm + D
        v.unit * M / (v0 * v0)
    end        

    def n_body_acceleration(ps)
        v = ps.inject(P[].vector) { |acc,p| acc += acceleration p }
        v.aspect.norm < NORMMIN ? P.zero : v
    end

    def n_body_bond(ps)
        v = ps.inject(P[].vector) { |acc,p| acc += bond p }
        v.aspect.norm < NORMMIN ? P.zero : v
    end

    # monopole short acting repulsive nuclear force
    def force(p)
        v = p.p - self.p
        return P.zero if v == P.zero
        return P.zero if v.aspect.norm > D + EPSILON
        v0 = v.aspect.norm + D
        v.unit * G * @m * p.m / (v0 * v0)
    end
end

class GParticle < Particle
    DT = 0.5         # time delta
    G = 50.0         # universal constant of gravity
    Z = 0.98         # friction
    D = 3.00         # bond distance
    # monopole short acting repulsive nuclear force
    def force(p)
        v = p.p - self.p
        return P.zero if v == P.zero
        v0 = v.aspect.norm + D
        v.unit * G * @m * p.m / (v0 * v0)
    end
end
end
