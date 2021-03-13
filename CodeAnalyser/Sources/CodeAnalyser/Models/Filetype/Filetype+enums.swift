//
//  
//

import Foundation

extension Filetype {
	public var enums: String {
        switch self {
        case .kotlin:
            return "enum class "
        case .swift:
            return "enum "
        case .objectiveC:
            return "enum "
        default:
            return "enum/enum classes"
        }
    }
}
