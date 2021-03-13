# CodeAnalyser

A description of this package.

#### How to use

###### Create and Start

`CodeAnalyser()
	.start(startPath: "../somepath")`
	

###### Lazy evaluation
Code analyser is completely lazy, its not until you run
`.unsafeRun()` the code will be evaluated. 


###### Gettings the result

`let (languageSummary: [LanguageSummary], statistics: [Statistics]) = CodeAnalyser()
	.start(startPath: "../somepath")
	.unsafeRun()`


