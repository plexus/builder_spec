A comparison of Ruby implementations of the Builder pattern for constructing XML/HTML.

```
Nokogiri::XML::Builder
  using a block parameter on every call
  bare method calls, always using a block
  using << for literal XML/HTML
  using a block parameter only on the outer block
  bare method calls, without a block argument
  method calls ending in underscore
  method calls ending in exclamation marks
  can access outside scope when using a block argument
  can access outside scope without a block argument
  set class and id using method calls

Hpricot::Builder
  using a block parameter on every call
  bare method calls, always using a block
  using << for literal XML/HTML
  using tag!
  using text! for text that gets escaped

Builder::XmlMarkup
  using a block parameter on every call
  bare method calls, always using a block
  using << for literal XML/HTML
  using a block parameter only on the outer block
  bare method calls, without a block argument
  using tag!
  using text! for text that gets escaped

Finished in 0.00605 seconds
22 examples, 0 failures
```
