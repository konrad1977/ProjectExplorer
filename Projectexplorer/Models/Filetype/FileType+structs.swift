//
//  
//

import Foundation

extension Filetype {

    var structs: String {
        switch self {
        case .kotlin:
            return "data class "
        case .swift:
            return "structs "
        case .objectiveC:
            return "struct "
        default:
            return ""
        }
    }
}
