#Dependencies
require 'csv'
require 'sunlight'
#Class Definition
class EventManager
	INVALID_ZIPCODE = "00000"
	INVALID_NUMBER = "0000000000"
	Sunlight::Base.api_key = "e179a6973728c4dd3fb1204283aaccb5"

	def initialize filename
		puts "EventManager Initialized."
		#filename = "event_attendees.csv"
		@file = CSV.open(filename, {:headers => true, :header_converters => :symbol})
	end

	def print_names
		@file.each do |line|
			puts line[:first_name] + " " + line[:last_name]
		end
	end

	def print_numbers
		 @file.each do |line|
		 	numbers = clean_numbers(line[:homephone])
		 	puts numbers
		 end
	end

	def print_zipcode
		@file.each do |line|
			zipcode = line[:zipcode]
			zipcode = clean_zipcode(zipcode)
			puts zipcode
		end
	end

	def clean_numbers original

			number = original
			number = number.delete(".").delete("(").delete(")").delete("-").delete(" ")
			if number.length == 10
			 elsif number.length == 11
			 		if number[0] == 1
			 			number[1..-1]
			 		else
			 			number = INVALID_NUMBER
			 		end	
			 else
			 	number = INVALID_NUMBER
			end
			return number
	
	end	

	def clean_zipcode original
			zipcode = original
			if zipcode.nil?
				zipcode = INVALID_ZIPCODE	
			elsif zipcode.length < 5
				until zipcode.length == 5
				 zipcode = "0" + zipcode
				end 	
			elsif zipcode == 5
			end			
			return zipcode
	end

	def output_data 
		output = CSV.open("event_clean_attendees.csv","w")

		@file.each do |line|
		if @file.lineno == 2
			output << line.headers
		end
			line[:homephone] = clean_numbers(line[:homephone])
			line[:zipcode]	= clean_zipcode(line[:zipcode])
			output << line
		end	
	end

	def rep_lookup
		20.times do
			line = @file.readline

			representative = "unknown"
			#API goes here
			legislators = Sunlight::Legislator.all_in_zipcode(clean_zipcode(line[:zipcode]))
			names = legislators.collect do |leg|
				first_name = leg.firstname
				first_initial = first_name[0]
				last_name = leg.lastname
				title = leg.title
				party = leg.party
				title+". "+first_initial + ". " + last_name +"("+party+")" 
			end
			
			legislators.each do |leg|
				puts "#{line[:last_name]}, #{line[:first_name]}, #{line[:zipcode]}, #{names.join(", ")}"
			end	
			
		end
	end

	def create_form_letters
		letter = File.open("form_letter.html", "r").read
		5.times do
			line = @file.readline

			custom_letter =	letter.gsub("#first_name", "#{line[:first_name]}")
			custom_letter = custom_letter.gsub("#last_name", "#{line[:last_name]}")
			custom_letter = custom_letter.gsub("#street", "#{line[:street]}")
			custom_letter = custom_letter.gsub("#city", "#{line[:city]}")
			custom_letter = custom_letter.gsub("#state", "#{line[:state]}")
			custom_letter = custom_letter.gsub("#zipcode", "#{clean_zipcode(line[:zipcode])}")
			
			filename = "output/thanks_#{line[:last_name]}_#{line[:first_name]}.html"
			output = File.new(filename,"w")
			output.write(custom_letter)


		end


	end
end

#script
manager = EventManager.new('event_attendees.csv')
manager.create_form_letters
