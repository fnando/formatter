has_markup
==========

has_markup is a ActiveRecord plugin that integrates
[Tidy](http://sourceforge.net/projects/tidy),
[Markdown](http://github.com/rtomayko/rdiscount),
[Textile](http://redcloth.org/) and `sanitize` helper method into a single
plugin.

Installation
------------

Install the plugin with 
	
	script/plugin install git://github.com/fnando/has_markup.git

Install the markup language you want to use. If you want to use Markdown, 
install it using 

	sudo gem install rdiscount

If you prefer Textile, install it using
	
	sudo gem install RedCloth

To have Tidy support, download the source at 
<http://sourceforge.net/projects/tidy> and compile it using

	tar xvf tidy4aug00.tgz
	cd tidy4aug00
	make
	sudo make install
	
There are also binaries for different systems, so find out what's the best one 
for you!

Usage
-----

All you need to do is call the method `has_markup` from your model.

	class Post < ActiveRecord::Base
	  has_markup :content,
	    :format       => :markdown,
	    :tidy         => true,
	    :tags         => %w(p a em strong ul li),
	    :attributes   => %w(href)
	end

The example above expects the table `posts` to have two columns: `content` 
and `formatted_content`. Is filtering the allowed tags and attributes. If you
don't want to limit the allowed HTML, just go with something like this

	class Post < ActiveRecord::Base
	  has_markup :content,
	    :format       => :textile,
	    :tidy         => true
	end
	
You can instantiate a markup object any time:

	markup = Markup.new(:markdown, 'some text')
	markup = Markup.new(:textile,  'some text')
	puts markup.to_html

To sanitize a given HTML, use the `html` method:

	Sanitize.html('<script>alert(document.cookie)</script>')

If you want to normalize HTML, you can use

	Sanitize.tidy('some text', options)
	
where `options` is a hash with all possible tidy arguments. You can check the 
list here: <http://tidy.sourceforge.net/docs/tidy_man.html>. Remember to 
replace `-` by `_`.

### TIDY NOTES

has_markup will try to discovery where the tidy library is located.
You can set it anytime by declaring the constant `TIDY_PATH`.

When `Sanitize.html` is called, Tidy is executed twice:
before the sanitization process and after the text has been 
filtered.

Copyright (c) 2008 Nando Vieira, released under the MIT license
