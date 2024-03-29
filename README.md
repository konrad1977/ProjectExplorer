

# pinfo

A simple CLI tool to analyse your code structures over mulitple projects. Support for Swift, Kotlina and Objective-C.

It uses https://github.com/konrad1977/CodeAnalyser as its engine. Which is blazingly fast. 
It can analyse about **250 000** lines per second on an 8 year old MacBook Pro. 

This project was initialy created for helping me understand monads better. 

<p align="center">
  <img src="https://raw.githubusercontent.com/konrad1977/ProjectExplorer/main/screenshots/first.png" alt="Icon"/>
</p>


`pinfo --linecount 5 --lang swift`

`--linecount 100` will print the 100 biggest files in the project

`--lang swift`, objc will filter out all other types of files and only analyse swift and objective-c files (h, and m)

<p>
  <img src="https://raw.githubusercontent.com/konrad1977/ProjectExplorer/main/screenshots/second.png" alt="Icon"/>
</p>

#### Supported filetypes:

- Kotlin (.kt, .kts, .ktm)
- Swift (.swift)
- Objective-C (.m, .h)

##### Limitation
- Quick and dirty detection of types
