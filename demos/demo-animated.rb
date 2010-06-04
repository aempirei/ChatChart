#!/usr/bin/ruby
#
# autograph.rb - Animated Autographer Sample
#
# this will do some animated automatic graph layout.
# make sure your terminal is the right size.
# i think the drawing window is set to 70x30
#
# Copyright(c) 2009 by Christopher Abad
# aempirei@gmail.com
# http://www.twentygoto10.com/
#
# this code is licensed under the "don't be a retarded asshole" license.
# if i don't like how you use this software i can tell you to fuck off
# and you can't use it, otherwise you can use it.
#
# == Usage ==
#
# autograph.rb [OPTIONS]
#
# -h, --help:
#    show help
#
# -1, --taxicab:
#    draw using taxicab topology
#
# -2, --hockey:
#    draw using hockey-stick topology
#

require 'rubygems'
require 'chatchart'
require 'getoptlong'
require 'rdoc/usage'

g = ChatChart::Graph.new << [
       :course - :name0  ,
       :course - :code   ,
       :course - :'C-I'  ,
       :course - :'S-C'  ,
    :institute - :name1  ,
    :institute - :'S-I'  ,
    :institute - :'C-I'  ,
      :student - :grade  ,
      :student - :name2  ,
      :student - :number ,
      :student - :'S-C'  ,
      :student - :'S-I'  ,
      :a - :b,
      :a - :c,
      :a - :d,
      :b - :q,
      :b - :w,
      :b - :e,
]

opts = GetoptLong.new(
    [ '--help'   , '-h', GetoptLong::NO_ARGUMENT ],
    [ '--hockey' , '-2', GetoptLong::NO_ARGUMENT ],
    [ '--taxicab', '-1', GetoptLong::NO_ARGUMENT ]
)

linestyle = ChatChart::L1Line

opts.each do |opt,arg|
    case opt
        when '--hockey'
            linestyle = ChatChart::HLine
        when '--taxicab'
            linestyle = ChatChart::L1Line
        when '--help'
            RDoc::usage
    end
end

COLS = 70
ROWS = 30

HOME = "\033[H"
BOLD = "\033[1m"
NORM = "\033[0m"
CLRSCR = "\033[2J"

CURSOR_ON = "\033[?25h"
CURSOR_OFF = "\033[?25l"

WINDOW = [ ChatChart::P[0,0], ChatChart::P[COLS,ROWS] ]

Kernel::at_exit { puts CURSOR_ON + "\033[50;1H" + NORM }

Kernel::trap('INT') { |signo| exit }

puts CURSOR_OFF + CLRSCR

# loop do

ChatChart::RandomLayout[ g, COLS, ROWS ]

C_SZ = 50
es = []
ses = 0

loop do
    ChatChart::SmartLayout[ g, 1 ]
    es << g.energy
    if es.length >= C_SZ
        es = es[-C_SZ,C_SZ]
        pses = ses
        ses = es[-C_SZ,C_SZ].inject(0.0) { |sum,e| sum += e }.to_f / C_SZ
        de = ses - pses
    else
        ses = 0
        de = 0
    end

    c = g.to_canvas(linestyle) << ChatChart::Title[ "delta-energy: %+.3f" % [ de ], proc { |p| p.r }, 1, 1 ]
    puts HOME + c.window(*WINDOW)
end
