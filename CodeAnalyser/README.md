# CodeAnalyser

A description of this package.

#### How to use

###### Create and Start

```swift
CodeAnalyser()
	.start(startPath: "../somepath")
```

###### Lazy evaluation
CodeAnalyser is completely lazy, its not until you run
```swift
.unsafeRun()
```
will the code be evaluated. 


###### Gettings the result

```swift
let (languageSummary: [LanguageSummary], statistics: [Statistics]) = CodeAnalyser()
	.start(startPath: "../somepath")
	.unsafeRun()
```

###### Filetype
An enum to show wich language (or all/none)
```swift
public enum Filetype {
	case all
	case kotlin
	case swift
	case objectiveC
	case none
}
```

###### Language Summary
Language Summary holds the information about every language. 
Filetype will tell you which language it is.
```swift
public struct LanguageSummary {
	public let classes: Int
	public let structs: Int
	public let enums: Int
	public let interfaces: Int
	public let functions: Int
	public let imports: Int
	public let extensions: Int
	public let linecount: Int
	public let filecount: Int
	public let filetype: Filetype
}
```

###### Statistics
Will return the percentage based on linecount.  Filetype will tell you which language it is.
```swift
public struct Statistics {
	public let filetype: Filetype
	public let lineCountPercentage: Double
}
```
