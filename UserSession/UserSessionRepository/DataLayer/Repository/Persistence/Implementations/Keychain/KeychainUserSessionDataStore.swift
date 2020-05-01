/// Copyright (c) 2019 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import Foundation

public class KeychainUserSessionDataStore: UserSessionDataStore {

  // MARK: - Properties
  let userSessionCoder: UserSessionCoding

  // MARK: - Methods
  public init(userSessionCoder: UserSessionCoding) {
    self.userSessionCoder = userSessionCoder
  }

  public func readUserSession() -> UserSession? {
    return self.readUserSessionSync()
  }

  public func save(userSession: UserSession) {
    let data = userSessionCoder.encode(userSession: userSession)
    let item = KeychainItemWithData(data: data)
    if let _ = self.readUserSession() {
      do {
        try Keychain.update(item: item)
      }
      catch {
        print("Can't update user session: \(error)")
      }
    }
    else {
      do {
        try Keychain.save(item: item)
      }
      catch {
        print("Can't save user session: \(error)")
      }
    }
  }

  public func delete(){
    DispatchQueue.global().async {
      self.deleteSync()
    }
  }
}

extension KeychainUserSessionDataStore {
  
  func readUserSessionSync() -> UserSession? {
    do {
      let query = KeychainItemQuery()
      if let data = try Keychain.findItem(query: query) {
        let userSession = self.userSessionCoder.decode(data: data)
        return userSession
      } else {
        return nil
      }
    } catch {
      return nil
    }
  }

  func deleteSync() {
    do {
      let item = KeychainItem()
      try Keychain.delete(item: item)
    } catch {
    }
  }
}

enum KeychainUserSessionDataStoreError: Error {

  case typeCast
  case unknown
}
