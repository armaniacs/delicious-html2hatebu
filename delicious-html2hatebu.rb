# -*- coding: utf-8 -*-
#
# delicious-html2hatebu
#   - A Converter to Change from del.icio.us Bookmarks Format to Hatena Bookmark in order to migration from del.icio.us to hatena.
#
# == Synopsis
#
#   delicious-html2hatebu [user] [html bookmarks file] > [xml bookmarks file]
#
# == Author
#
# ARAKI Yasuhiro <ar@debian.org>
# Copyright (c) 2010 ARAKI Yasuhiro
#
# It is free software, and is distributed under the Ruby license.
#
# == Notice
#
#  This code is derived from delicious-html2xml. 
#  Bellow lines are original version of desription notice.
#########################################
# delicious-html2xml
#   - A Converter to Change del.icio.us Bookmarks Format from HTML to XML
#
# == Synopsis
#
#   delicious-html2xml [user] [html bookmarks file] > [xml bookmarks file]
#
# == Description
#
# This is a ruby library to convert del.icio.us bookmarks format 
# from HTML (posts/all) to XML.
#
# == Author
#
# Motohiro MATSUDA <matsuda@sw.it.aoyama.ac.jp>
#
# Copyright (c) 2008 Motohiro MATSUDA.
#
# It is free software, and is distributed under the Ruby license.
# See the COPYING file in the standard Ruby distribution for details.
#
# == Version
#
# 2008-01-07
#	* release 0.1.0 (release-0_1_0)
#
#########################################
# delicious-html2hatebu.rb

require "date"
require "rubygems"
require 'hpricot'
require 'rexml/document'

#parse args
user = ARGV[0]
html_filename = ARGV[1]

day = Time.now
day.strftime("%Y-%m-%dT%XZ")

str = <<EOF
<DL>
</DL>
EOF
new_doc = REXML::Document.new(str)

file = open(html_filename, "r")
doc = Hpricot(file)
bookmarks = (doc/:dl)[0].children


#convert
bookmarks.each_with_index do |bookmark, i|
  data = []

  case bookmark.name
  when 'dt'
    a = (bookmark/:a)[0]
    data << a.inner_html
    data << a["href"]
    data << a["last_visit"]
    data << a["add_date"]
    data << a["tags"]

    if !bookmarks[i+1].nil? && bookmarks[i+1].name == 'dd'
      data << bookmarks[i+1].inner_html
    end
  else
    next
  end

  new_dt = REXML::Element.new("DT")

  new_bookmark = REXML::Element.new("A")
  new_bookmark.add_attribute "HREF", data[1]
  new_bookmark.add_attribute "ADD_DATE", data[3]
  new_bookmark.add_attribute "LAST_VISIT", data[2]
  new_bookmark.add_text data[0]

  if data[4].length > 1
    data[4] = data[4].split(",").join(" ")
    new_bookmark.add_attribute "TAGS", data[4]
  end

  new_dt.add_element new_bookmark
  new_doc.root.add_element new_dt
  new_doc.root.add_text "\n"

  new_ex = REXML::Element.new("DD")
  new_ex.add_text data[5]
  new_doc.root.add_element new_ex
  new_doc.root.add_text "\n"
end

#output

str2 = <<EOF
<!DOCTYPE NETSCAPE-Bookmark-file-1>
<!-- This is an automatically generated file.
     It will be read and overwritten.
     DO NOT EDIT! -->
<META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=UTF-8">
<TITLE>"#{user}" のブックマーク</TITLE>
<H1 LAST_MODIFIED="#{day.to_i}">"#{user}" のブックマーク</H1>

EOF
puts str2
puts new_doc
