import Foundation



func matchRange (string: String, regex: NSRegularExpression) -> Range<String.Index>? {
  let sr = NSRange(location: 0, length: countElements(string))
  let range = regex.rangeOfFirstMatchInString(string, options: nil, range: sr)
  if range.location != NSNotFound && range.length != 0 {
    let start = advance(string.startIndex, range.location)
    let end = advance(start, range.length)
    return Range(start: start, end: end)
  } else {
    return nil
  }
}



func matches (string: String, regex: NSRegularExpression) -> Bool {
  return matchRange(string, regex) != nil
}



func regex (pattern: String, options: String = "") -> NSRegularExpression! {
  if matches(options, invalidOptionsPattern) {
    return nil
  }
  let opts = reduce(options, NSRegularExpressionOptions()) {
    acc, opt in
    acc | (regexOptions[opt] ?? NSRegularExpressionOptions())
  }
  return NSRegularExpression(pattern: pattern, options: opts, error: nil)
}

let invalidOptionsPattern =
        NSRegularExpression(pattern: "[^ixsm]", options: nil, error: nil)!

let regexOptions: [Character: NSRegularExpressionOptions] = [
  "i": .CaseInsensitive,
  "x": .AllowCommentsAndWhitespace,
  "s": .DotMatchesLineSeparators,
  "m": .AnchorsMatchLines
]



func replace (regex: NSRegularExpression, template: String) (string: String)
    -> String {
  var s = NSMutableString(string: string)
  let range = NSRange(location: 0, length: countElements(string))
  regex.replaceMatchesInString(s, options: nil, range: range,
      withTemplate: template)
  return s
}

func replace (regex: NSRegularExpression, block: [String] -> String)
    (string: String) -> String {
  var s = NSMutableString(string: string)
  let range = NSRange(location: 0, length: countElements(string))
  var offset = 0
  regex.enumerateMatchesInString(string, options: nil, range: range) {
    result, _, _ in
    var captures = [String](count: result.numberOfRanges, repeatedValue: "")
    for i in 0..<result.numberOfRanges {
      if let r = result.rangeAtIndex(i).toRange() {
        let start = advance(string.startIndex, r.startIndex)
        let end = advance(string.startIndex, r.endIndex)
        captures[i] = string[start..<end]
      }
    }
    let replacement = block(captures)
    let offsetRange = NSRange(location: result.range.location + offset,
        length: result.range.length)
    offset += countElements(replacement) - result.range.length
    s.replaceCharactersInRange(offsetRange, withString: replacement)
  }
  return s
}

func splitLead (regex: NSRegularExpression) (string: String)
    -> (String, String) {
  switch matchRange(string, regex) {
  case .None: return ("", string)
  case .Some(let range):
    return (string.substringToIndex(range.endIndex),
        string.substringFromIndex(range.endIndex))
  }
}

func splitTrail (regex: NSRegularExpression) (string: String)
    -> (String, String) {
  switch matchRange(string, regex) {
  case .None: return (string, "")
  case .Some(let range):
    return (string.substringToIndex(range.startIndex),
        string.substringFromIndex(range.startIndex))
  }
}
