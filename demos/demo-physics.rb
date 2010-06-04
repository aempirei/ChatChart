#!/usr/bin/ruby
#
# fizzix.rb - Physics Test Code
#
# Copyright(c) 2009 by Christopher Abad
# aempirei@gmail.com
# http://www.twentygoto10.com/
#
# this code is licensed under the "don't be a retarded asshole" license.
# if i don't like how you use this software i can tell you to fuck off
# and you can't use it, otherwise you can use it.
#

require 'rubygems'
require 'chatchart'
require 'particle'

include ChatChart

COLS = 100
ROWS = 30
P_SZ = 10

HOME = "\033[H"
BOLD = "\033[1m"
NORM = "\033[0m"

CURSOR_ON = "\033[?25h"
CURSOR_OFF = "\033[?25l"

WINDOW = [ P[0,0], P[COLS,ROWS] ]

ps = []

P_SZ.times { ps << GParticle.new(P.random(COLS, ROWS).vector) }

c = Canvas.new

Kernel::at_exit { puts CURSOR_ON + "\033[50;1H" + NORM }
Kernel::trap('INT') { |signo| exit }

puts CURSOR_OFF + BOLD

loop do
    ps.each { |p| c << Dot[' ', p.p.quantize] }
    # calculate the instantaneous acceleration
    ps.each { |p| p.a = p.n_body_acceleration(ps.reject { |q| q.object_id == p.object_id }) }
    # update the velocities
    ps.each { |p| p.v += p.a * GParticle::DT ; p.v *= GParticle::Z }
    # project new positions
    ps.each { |p| p.p += p.v * GParticle::DT }
    ps.each { |p| c << Dot['@', p.p.quantize] }
    puts HOME + c.window(*WINDOW)
end
