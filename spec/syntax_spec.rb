require 'nokogiri'
require 'hpricot'
require 'builder'
require 'hexp'

shared_examples_for 'works on all builders' do
  it 'can be used with a block parameter to call build methods on' do
    expect(
      build do |xml|
        xml.div do |xml|
          xml.br {}
        end
      end
    ).to match xml_parts %w[ <div> <br/> </div> ]
  end

  it 'can use bare method calls, when using a block with each call' do
    expect(
      build do
        div do
          br {}
        end
      end
    ).to match xml_parts %w[<div> <br/> </div>]
  end

  it 'can take attributes' do
    expect(
      build do
        div class: "strong" do
          br {}
        end
      end
    ).to match xml_parts %w[<div class="strong" > <br/> </div>]
  end
end

shared_examples_for 'works on all except Hexp' do
  it 'using << for literal XML/HTML' do
    expect(
      build do
        div do |xml|
          xml << "<strong>foo</strong>"
        end
      end
    ).to match xml_parts %w[<div> <strong> foo </strong> </div>]
  end
end

shared_examples_for 'works on Nokogiri and Builder' do
  it 'using a block parameter only on the outer block' do
    expect(
      build do |xml|
        xml.div do
          xml.br
        end
      end
    ).to match xml_parts %w[ <div> <br/> </div> ]
  end

  it 'bare method calls, without a block argument' do
    expect(
      build do
        div do
          br
        end
      end
    ).to match xml_parts %w[<div> <br/> </div>]
  end
end

shared_examples_for 'works on Hpricot and Builder' do
  it 'using tag!' do
    expect(
      build do
        tag! :div do
          tag! :br
        end
      end
    ).to match xml_parts %w[<div> <br/> </div>]
  end

  it 'using text! for text that gets escaped' do
    expect(
      build do
        div do
          text! '=<">= <=== Crab emoticon'
        end
      end
    ).to match xml_parts ['<div>', '=&lt;"&gt;=', '&lt;===', 'Crab', 'emoticon', '</div>']
  end
end

shared_examples_for 'works only on Nokogiri' do
  it 'method calls ending in underscore' do
    expect(
      build do
        p_ do
          br_
        end
      end
    ).to match xml_parts %w[<p> <br/> </p>]
  end

  it 'method calls ending in exclamation marks' do
    expect(
      build do
        p! do
          br!
        end
      end
    ).to match xml_parts %w[<p> <br/> </p>]
  end

  def hello
    'Hello'
  end

  it 'can access outside scope when using a block argument' do
    expect(
      build do |xml|
        xml.div hello
      end
    ).to match xml_parts %w[<div> Hello </div>]
  end

  it 'can access outside scope without a block argument' do
    expect(
      build do
        div hello
      end
    ).to match xml_parts %w[<div> Hello </div>]
  end

  it 'set class and id using method calls' do
    # This is supposed to work on Hpricot as well, but it doesn't
    expect(
      build do
        div.the_class.the_id!
      end
    ).to match xml_parts %w[<div class="the_class" id="the_id" />]
  end

end

describe 'Nokogiri::XML::Builder' do
  def build(&block)
    Nokogiri::XML::Builder.new(&block).to_xml
  end

  include_examples 'works on all builders'
  include_examples 'works on all except Hexp'
  include_examples 'works on Nokogiri and Builder'
  include_examples 'works only on Nokogiri'
end

describe 'Hpricot::Builder' do
  def build(&block)
    Hpricot(&block).to_html
  end

  include_examples 'works on all builders'
  include_examples 'works on all except Hexp'
  include_examples 'works on Hpricot and Builder'
end

describe 'Builder::XmlMarkup' do
  def build(&block)
    builder = Builder::XmlMarkup.new
    builder.instance_eval(&block)
    builder.target!
  end

  include_examples 'works on all builders'
  include_examples 'works on all except Hexp'
  include_examples 'works on Nokogiri and Builder'
  include_examples 'works on Hpricot and Builder'
end

describe 'Hexp::Builder' do
  def build(&block)
    Hexp::Builder.new(&block).to_html
  end

  include_examples 'works on all builders'
end

# Given a list of xml tokens, return a regexp that matches an XML/HTML
# representation, ignoring minor syntactic differences.
#
# * ignore whitespace
# * match both `<br/>`, `<br />` and `<br></br>` in the case of self-closing tags
# * match both " and &quot;
#
def xml_parts(parts)
  choice = ->(*args) { "(#{args.join('|')})" }
  Regexp.new(
    parts.map do |part|
      if part =~ /<(\w+)\/>/
        choice.("<#{$1} ?/>", "<#{$1}>", "<#{$1}></#{$1}>")
      else
        Regexp.escape(part).gsub('"', choice.('"', '&quot;'))
      end
    end.join('\s*')
  )
end
