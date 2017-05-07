package doom.html;

import doom.core.VNode;
import doom.core.AttributeValue;
import js.html.Event;
using thx.Strings;

@:autoBuild(doom.html.macro.Styles.buildNamespace())
class BaseElement<ElementType: BaseElement<ElementType>> implements doom.core.Renderable {
  var attributes: Map<String, AttributeValue>;
  var tag: String;

  public function new(tag: String) {
    this.tag = tag;
    this.attributes = new Map();
    setStringAttribute("class", classes());
  }

  public function render(): VNode
    return Html.el(tag, attributes, []);

  public function classes(): String
    return ""; // this is automatically generated by the Styles macro

  public function selector(): String {
    var parts = classes().trim().split(" ").filter(function(cls) return cls != "");
    if(parts.length == 0) return "";
    return parts.map(function(part) return '.$part').join("");
  }

  public function id(value: String): ElementType
    return setStringAttribute("id", value);

  public function setBoolAttribute(name, val: Bool): ElementType {
    attributes.set(name, val);
    return self();
  }

  public function enableAttribute(name): ElementType
    return setBoolAttribute(name, true);

  public function disableAttribute(name): ElementType
    return setBoolAttribute(name, false);

  public function setStringAttribute(name, val: String): ElementType {
    attributes.set(name, val);
    return self();
  }

  public function appendStringAttribute(name, val: String): ElementType {
    return switch attributes.get(name) {
      case null, BoolAttribute(_), EventAttribute(_): setStringAttribute(name, val);
      case StringAttribute(s): setStringAttribute(name, '$s $val');
    };
  }

  public function setEventAttribute(name, f: EventHandler) {
    attributes.set(name, EventAttribute(f));
    return self();
  }

  public function appendEventAttribute(name, fn: EventHandler)
    return switch attributes.get(name) {
      case null, BoolAttribute(_), StringAttribute(_): setEventAttribute(name, fn);
      case EventAttribute(f): setEventAttribute(name, function(el: js.html.Element, e: Event) {
        f(cast el, cast e);
        fn(cast el, cast e);
      });
    };

  public function click(fn: EventHandler)
    return appendEventAttribute("click", fn);

  public function ariaLabel(value: String)
    return setStringAttribute("aria-label", value);

  public function role(value: String)
    return setStringAttribute("role", value);

  public function addClass(c: String): ElementType
    return appendStringAttribute("class", c);

  public function removeClass(c: String): ElementType
    return filterClass(function(cls) return cls != c);

  public function filterClass(f: String -> Bool): ElementType
    return switch attributes.get("class") {
      case null, BoolAttribute(_), EventAttribute(_):
        self();
      case StringAttribute(classes):
        var nclasses = classes.split(" ").filter(f).join(" ");
        if(nclasses != classes)
          self();
        else
          setStringAttribute("class", nclasses);
    };

  public function addNSClass(ns: String, c: String): ElementType {
    removeNSClass(ns);
    return addClass('$ns-$c');
  }

  public function removeNSClass(ns: String): ElementType {
    ns = '$ns-';
    return filterClass(function(cls) return !cls.startsWith(ns));
  }

  public function disabled()
    return enableAttribute("disabled");

  inline function self(): ElementType
    return cast this;
}
