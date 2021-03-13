# CodeAnalyser

A description of this package.

#### How to use

###### Create and Start

```swift
CodeAnalyser()
	.start(startPath: "../somepath")
```

###### Lazy evaluation
Code analyser is completely lazy, its not until you run
```swift
.unsafeRun()```
the code will be evaluated. 


###### Gettings the result

```swift
let (languageSummary: [LanguageSummary], statistics: [Statistics]) = CodeAnalyser()
	.start(startPath: "../somepath")
	.unsafeRun()```


