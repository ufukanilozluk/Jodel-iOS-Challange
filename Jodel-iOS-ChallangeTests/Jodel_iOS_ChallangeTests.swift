import XCTest
@testable import Jodel_iOS_Challange

final class JodeliOSChallangeTests: XCTestCase {
  func testJsonCanBeParsed() throws {
    guard let pathString = Bundle(for: type(of: self)).path(forResource: "Test", ofType: "json") else {
      fatalError("Json not found")
    }
    guard let json = try? String(contentsOfFile: pathString, encoding: .utf8) else {
      fatalError("Unable to convert json to String")
    }
    let jsonData = json.data(using: .utf8)!
    let galleryData = try! JSONDecoder().decode(GalleryData.self, from: jsonData)
    XCTAssertEqual("Color", galleryData.photos.photo[0].title)
    XCTAssertEqual("Owens River and Sea Grass", galleryData.photos.photo[1].title)
    }
}
