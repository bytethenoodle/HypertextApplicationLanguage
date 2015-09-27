// HypertextApplicationLanguage NamespaceManager.swift
//
// Copyright © 2015, Roy Ratcliffe, Pioneering Software, United Kingdom
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the “Software”), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED “AS IS,” WITHOUT WARRANTY OF ANY KIND, EITHER
// EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT. IN NO
// EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES
// OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
// ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
// DEALINGS IN THE SOFTWARE.
//
//------------------------------------------------------------------------------

import Foundation

/// Handles *compact* URIs, a.k.a. CURIEs. Representations and representation
/// factories have CURIEs handled by a name-space manager instance.
public class NamespaceManager {

  /// Defines the relative reference token, the placeholder used in CURIEs.
  public static let Rel = "{rel}"

  /// Retains one relative hypertext reference for one name.
  var refForName = [String: String]()

  /// - returns: Answers a hash of relative references by their name.
  public var namespaces: [String: String] {
    return refForName
  }

  public init() {}

  /// Adds a name-space to this manager.
  /// - parameter name: Names the CURIE. This appears in CURIE references as the
  ///   prefix before the colon. The relative reference comes after the colon.
  /// - parameter ref: Gives the CURIE's relative reference. It must include the
  ///   `{rel}` placeholder identifying where to substitute the CURIE argument,
  ///   the value that replaces the placeholder.
  public func withNamespace(name: String, ref: String) -> NamespaceManager {
    refForName[name] = ref
    return self
  }

  /// Converts an expanded hypertext reference to a CURIE'd reference based on
  /// the current set of CURIE specifications, the name-spaces.
  /// - returns: Answers the CURIE'd reference corresponding to the given
  ///   hypertext reference, or +nil+ if there is no matching CURIE.
  public func curie(href: String) -> String? {
    for (name, ref) in refForName {
      guard let range = ref.rangeOfString(NamespaceManager.Rel) else { continue }
      let left = ref.substringToIndex(range.startIndex)
      let right = ref.substringFromIndex(range.endIndex)
      if href.hasPrefix(left) && href.hasSuffix(right) {
        let leftDistance = ref.startIndex.distanceTo(range.startIndex)
        let rightDistance = range.endIndex.distanceTo(ref.endIndex)
        let startIndex = href.startIndex.advancedBy(leftDistance)
        let endIndex = href.endIndex.advancedBy(-rightDistance)
        return name + ":" + href.substringWithRange(startIndex..<endIndex)
      }
    }
    return nil
  }

  /// Converts a CURIE'd reference to a hypertext reference.
  /// - parameter curie: The argument is a string comprising a name prefix
  /// followed by a colon delimiter, followed by a CURIE argument.
  ///
  /// Splits the name at the first colon. The prefix portion before the colon
  /// identifies the name of the CURIE. The portion after the colon replaces the
  /// `{rel}` placeholder. This is a very basic way to parse a CURIE, but it
  /// works.
  public func href(curie: String) -> String? {
    guard let range = curie.rangeOfString(":") else { return nil }
    let name = curie.substringToIndex(range.startIndex)
    guard var ref = refForName[name] else { return nil }
    guard let relRange = ref.rangeOfString(NamespaceManager.Rel) else { return nil }
    let arg = curie.substringFromIndex(range.endIndex)
    ref.replaceRange(relRange, with: arg)
    return ref
  }

}