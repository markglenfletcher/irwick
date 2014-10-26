class IrcPlugin
	def self.valid_plugin?(plugin_class)
		begin
			plugin_const = Object.const_get(plugin_class)
			if plugin_const.ancestors.include?(self)
				plugin_const
			else
				false
			end
		rescue NameError => e
			false
		end
	end

	def method_missing(method_name, *arguments, &block)
		if (method_name =~ /on_\w*/)
			nil
		else
			super
		end
	end

	def respond_to_missing?(method_name, include_private = false)
		method_name.to_s.start_with?('on_') || super
	end
end