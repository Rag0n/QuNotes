import Foundation


/// Delays execution for giving time
///
/// - Parameters:
///   - interval: time for which execution needs to be delayed
///   - block: code to be executed after delay
public func delay(for interval: DispatchTimeInterval, block: @escaping () -> ()) {
    DispatchQueue.main.asyncAfter(deadline: .now() + interval, execute: block)
}
