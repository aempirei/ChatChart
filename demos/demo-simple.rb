#!/usr/bin/ruby
#
# sample.rb - ChatChart Sample Driver
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

COLS = 60
ROWS = 14

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
]

ChatChart::RandomLayout[ g, COLS, ROWS ]

print g.to_canvas << ChatChart::Title[ 'SHIT FOR BRAINS'.reverse, proc { |p| p.l.d }, -2, 0 ]
