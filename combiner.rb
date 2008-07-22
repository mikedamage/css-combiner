#!/usr/bin/env ruby
##
# = CGI File Combiner
# Author:: Mike Green
# Copyright:: Copyright (C) 2008, Mike Green
# License:: GNU General Public License
#
# == Summary
# Takes filenames as parameters, concatenates them, and returns them to cut down on HTTP requests.
##

require 'cgi'
require 'rubygems'
require 'cgi_exception'

class Combiner
	SINGLE_LINE = Regexp.new(/\/\/.*$/)
	MULTI_LINE = Regexp.new(/\/\*.*?\*\//m)
	WHITESPACE = Regexp.new(/[\t+|\n+]/)
	
	attr_reader :parameters

	def initialize(params)
		@params = params
		@format = @params['format']
		@files = @params['files']
	end

	def output_cgi
		if arguments_valid?
			@output = strip_whitespace( strip_multi_line_comments( strip_single_line_comments( combine_files( @files ) ) ) )
			
			case @format
				when "js" then puts "Content-Type: text/javascript"
				when "css" then puts "Content-Type: text/css"
			end
			puts ""
			puts @output
		end
	end

	protected
	
	def arguments_valid?
		if @params.has_key?("format") && @params.has_key?("files")
			return true
		end
	end

	def combine_files(files)
		combined = Array.new
		files.each do |file|
			File.open(file) {|f| combined << f.read }
		end
		combined.join("\n")
	end

	def strip_single_line_comments(string)
		string.gsub(SINGLE_LINE, "\n")
	end

	def strip_multi_line_comments(string)
		string.gsub(MULTI_LINE, "\ ")
	end
	
	def strip_whitespace(string)
		string.gsub(WHITESPACE, "\ ")
	end
end

cgi = CGI.new
params = cgi.params
c = Combiner.new(params)
c.output_cgi