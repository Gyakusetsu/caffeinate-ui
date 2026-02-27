import Foundation

protocol UserDefaultsProtocol {
    func data(forKey: String) -> Data?
    func string(forKey: String) -> String?
    func integer(forKey: String) -> Int
    func set(_ value: Any?, forKey: String)
    func set(_ value: Int, forKey: String)
}

extension UserDefaults: UserDefaultsProtocol {}
