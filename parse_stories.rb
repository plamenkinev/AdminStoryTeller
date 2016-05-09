require 'nokogiri'
require 'tenjin'

class Report
	attr_reader :project, :stories, :file_name

	def initialize(file_name)
		@project = ""
		@stories = Array.new
		@file_name = file_name
		create_stories()
	end

	def print_report
		stories.each do |story|
			story.print_story
			30.times { print "=" }
			puts; puts
		end
	end

	def to_html
		html_file_name = file_name.split(".")[0] + ".out.html"
		html_file = File.open(html_file_name, "w")

		context = {
			:project => @project,
			:stories => @stories,
		}

		engine = Tenjin::Engine.new()
		html = engine.render('64-bit.out.rbhtml', context)

		html_file.puts html
	end

	private def create_stories()
		# Creating a Nokogiri document
		page = Nokogiri::HTML(open(file_name))

		# Selecting the project name
		@project = page.css("h2")[0].text.split(":")[2]

		# Selecting the body of table only
		table_body = page.css("tbody")

		# Selecting all rows
		rows = table_body.css("tr")

		rows.each do |row|
			stories.push(Story.new(row))
		end
	end
end

class Story
	attr_reader :story_id, :description, :closed_date, :estimated_hours, :spent_hours, :names

	def initialize(row)
		# Selecting all cells
		cells = row.css("td")
		
		# Parsing the cells
		@story_id = cells[3].text.strip
		@description = cells[4].text.strip
		@closed_date = cells[5].text.strip
		@estimated_hours = cells[8].text.strip
		@spent_hours = cells[9].text.strip
		@names = cells[11].text.strip
	end

	def print_story
		# Printing the story
		puts "Story: #{story_id} - #{description}"
		puts "Closed on #{closed_date}"
		puts "Estimated: #{estimated_hours} hours, spent: #{spent_hours} hours"
		puts "People that have booked on that story : #{names}"
		if (spent_hours.to_f > estimated_hours.to_f)
			puts "OVERSPENT"
		end
		if (spent_hours.to_f > 40)
			puts "OVERBOOKED"
		end
	end
end

# file_name with stories from Admin will be provided as an argument to the script
file_name = ARGV[0]

report = Report.new(file_name)
report.to_html