//
//  
//

import Foundation

extension Filetype {

    var enums: String {
        switch self {
        case .kotlin:
            return "enum class "
        case .swift:
            return "enum "
        case .objectiveC:
            return "enum "
        default:
            return ""
        }
    }
}
