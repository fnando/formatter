require "spec_helper"
require "rdiscount"
require "RedCloth"

# unset models used for testing purposes
Object.unset_class("Post")

TIDY_PATH = "/usr/lib/libtidy.dylib"

MARKDOWN_CONTENT = %(
Some title
==========

Some **formatted** _text_ for the masses <http://example.com>.

* Item A
* Item B

Another [example][link]

![Title](img.jpg "Title")

<script>alert("something");</script>

[link]: http://example.com/  "Example"
)

TEXTILE_CONTENT = %(
h1. Some title

Some *formatted* _text_ for the masses "http://example.com":http://example.com.

* Item A
* Item B

Another "example (Example)":http://example.com

!img.jpg(Title)!

<script>alert("something");</script>
)

class Post < ActiveRecord::Base
  has_markup :content,
    :format       => :markdown,
    :tidy         => true,
    :tags         => %w(p a em strong ul li),
    :attributes   => %w(href)
    
  has_markup :excerpt,
    :format       => :html,
    :tidy         => true
end

class Comment < ActiveRecord::Base
  has_markup :content,
    :format       => :textile,
    :tidy         => true,
    :tags         => %w(p a em strong ul li),
    :attributes   => %w(href)
end

class Task < ActiveRecord::Base
  has_markup :content,
    :format   => :textile,
    :sanitize => false
end

describe "has_markup" do
  it "should set class method" do
    Post.should respond_to(:has_markup)
    Post.should respond_to(:has_markup_options)
  end
  
  it "should generate formatted content" do
    post = create_post
    post.formatted_content.should_not be_blank
    post.formatted_excerpt.should_not be_blank
  end
  
  it "should format content using markdown" do
    post = create_post(:content => MARKDOWN_CONTENT)
    text = post.formatted_content
    
    text.should have_tag("strong", "formatted")
    text.should have_tag("em", "text")
    text.should have_tag("a[href=http://example.com]", "http://example.com")
    text.should have_tag("ul", 1)
    text.should have_tag("p", 2)
    
    text.should_not have_tag("h1", "Some title")
    text.should_not have_tag("script")
    text.should_not have_tag("a[title=Example]")
    text.should_not have_tag("img")
  end
  
  it "should format content using textile" do
    post = create_comment(:content => TEXTILE_CONTENT)
    text = post.formatted_content

    text.should have_tag("strong", "formatted")
    text.should have_tag("em", "text")
    text.should have_tag("a[href=http://example.com]", "http://example.com")
    text.should have_tag("ul", 1)
    text.should have_tag("p", 2)

    text.should_not have_tag("h1", "Some title")
    text.should_not have_tag("script")
    text.should_not have_tag("a[title=Example]")
    text.should_not have_tag("img")
  end
  
  it "should keep content when format is :html" do
    post = create_post(:excerpt => "<p>some text</p>")
    
    Markdown.stub!(:new).and_return(mock("content", :null_object => true))
    Markdown.should_not_receive(:new).with(:html, post.excerpt)
    
    text = post.formatted_excerpt
    text.should have_tag("p", "some text")
  end
  
  it "should parse content when attribute has changed" do
    post = create_post
    Markdown.should_not_receive(:new)
    post.save
  end
  
  it "should parse content when formatted attribute is blank" do
    post = create_post
    post.formatted_content = ""
    post.save
    post.formatted_content.should_not be_blank
  end
  
  it "should strip tags" do
    Sanitize.strip_tags("<strong>test</strong>").should == "test"
    Sanitize.strip_tags("<b>test</strong>").should == "test"
  end
  
  it "should not sanitize" do
    Sanitize.should_not_receive(:html)
    create_task
  end
  
  private
    def create_post(options={})
      Post.create({
        :title => "Some title", 
        :content => "some content", 
        :excerpt => "some content"
      }.merge(options))
    end
    
    def create_comment(options={})
      Comment.create({
        :content => "some content"
      }.merge(options))
    end
    
    def create_task(options={})
      Task.create({
        :content => "some content"
      }.merge(options))
    end
end