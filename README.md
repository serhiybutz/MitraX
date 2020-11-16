<p align="center">
<img width="200" height="193" src="Logo.png" />
</p>


<h1><a href="https://github.com/SergeBouts/MitraX">MitraX</a></h1>

The *MitraX* package provides a *shared-memory* synchronization manager (*Shared Manager*) that implements a [*mutex-to-operation* strategy](https://sergebouts.github.io/swift-shared-memory-manager/#mutex-to-operation-strategy) (as opposed to the traditional [*mutex-to-memory* strategy](https://sergebouts.github.io/swift-shared-memory-manager/#mutex-to-memory-strategy)). It can be thought of as an efficient automatically provided *safety net* for *shared-memory* operations and is a breeze to work with.


<p>
<img src="https://img.shields.io/badge/Swift-5.1-orange" alt="Swift" />
<img src="https://img.shields.io/badge/platform-macOS%20|%20iOS-orange.svg" alt="Platform" />
<img src="https://img.shields.io/badge/Swift%20Package%20Manager-compatible-orange" alt="SPM" />
<a href="https://github.com/SergeBouts/MitraX/blob/master/LICENSE">
<img src="https://img.shields.io/badge/licence-MIT-orange" alt="License" />
</a>
</p>

This is an alternative implementation of the original [Mitra](https://github.com/SergeBouts/Mitra) module.  For more documentation, see [here](https://github.com/SergeBouts/Mitra).

## Installation

### Swift Package as dependency in Xcode 11+

1. Go to "File" -> "Swift Packages" -> "Add Package Dependency"
2. Paste MitraX repository URL into the search field:

`https://github.com/SergeBouts/MitraX.git`

3. Click "Next"

4. Ensure that the "Rules" field is set to something like this: "Version: Up To Next Major: 0.1.1"

5. Click "Next" to finish

For more info, check out [here](https://developer.apple.com/documentation/xcode/adding_package_dependencies_to_your_app).



## License

This project is licensed under the MIT license.
