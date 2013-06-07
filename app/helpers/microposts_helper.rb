module MicropostsHelper

	def wrap(content)
		sanitize(raw(content.split.map{ |s| wrap_long_string(s) }.join(' ')))
	end

	def add_reply_links_to(content)
		reply_tags = extract_reply_tags(content)
		unless reply_tags.empty?
			reply_tags.each do |reply_tag|
				user = user_from_reply_tag(reply_tag)
				unless user.nil?
					content = raw(content.gsub(/#{reply_tag}/, "#{ link_to reply_tag,
						user_path(user) }"))
				end
			end
		end
		sanitize(content)
	end

	private

		def wrap_long_string(text, max_width = 30)
			zero_width_space = "&#8203;"
			regex = /.{1,#{max_width}}/
			(text.length < max_width) ? text :
			text.scan(regex).join(zero_width_space)
		end

		def extract_reply_tags(content)
			content.scan(Micropost.REPLY_REGEX)
		end

		def user_from_reply_tag(reply_tag)
			User.find_by(username: reply_tag[1..-1])
		end
end
