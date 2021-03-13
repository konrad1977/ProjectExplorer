//
//  
//

import Foundation

extension Filetype {
	public var structs: String {
        switch self {
        case .kotlin:
            return "data class "
        case .swift:
            return "struct "
        case .objectiveC:
            return "struct "
        default:
            return "structs/data classes"
        }
    }
}
